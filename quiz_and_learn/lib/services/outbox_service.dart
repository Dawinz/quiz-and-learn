import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';

class OutboxService {
  static final OutboxService _instance = OutboxService._internal();
  factory OutboxService() => _instance;
  OutboxService._internal();

  bool _isInitialized = false;
  late final ApiClient _apiClient;
  static const String _outboxKey = 'outbox_operations';

  bool get isInitialized => _isInitialized;

  /// Initialize the outbox service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _apiClient = ApiClient();
      await _apiClient.initialize();
      _isInitialized = true;
      debugPrint('OutboxService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing OutboxService: $e');
      _isInitialized = true;
    }
  }

  /// Submit a write operation with idempotency
  Future<OutboxResult> submitWrite({
    required String endpoint,
    required Map<String, dynamic> data,
    String? operationType,
    Map<String, String>? additionalHeaders,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Generate idempotency key
      final idempotencyKey = _generateIdempotencyKey();

      // Create operation record
      final operation = OutboxOperation(
        id: idempotencyKey,
        endpoint: endpoint,
        data: data,
        operationType: operationType ?? 'write',
        status: OutboxStatus.pending,
        createdAt: DateTime.now(),
        retryCount: 0,
      );

      // Store operation in outbox
      await _storeOperation(operation);

      // Attempt to execute immediately
      final result = await _executeOperation(operation, additionalHeaders);

      if (result.success) {
        // Mark as completed
        await _markOperationCompleted(operation.id);
        return OutboxResult(
          success: true,
          idempotencyKey: idempotencyKey,
          response: result.response,
        );
      } else {
        // Keep in outbox for retry
        return OutboxResult(
          success: false,
          idempotencyKey: idempotencyKey,
          error: result.error,
          willRetry: true,
        );
      }
    } catch (e) {
      debugPrint('Error submitting write operation: $e');
      return OutboxResult(
        success: false,
        error: e.toString(),
        willRetry: false,
      );
    }
  }

  /// Execute a pending operation
  Future<OperationExecutionResult> _executeOperation(
    OutboxOperation operation,
    Map<String, String>? additionalHeaders,
  ) async {
    try {
      // Prepare headers with idempotency key
      final headers = <String, String>{
        'Idempotency-Key': operation.id,
        'Content-Type': 'application/json',
        ...?additionalHeaders,
      };

      // Execute the request
      final response = await _apiClient.post(
        operation.endpoint,
        data: operation.data,
        headers: headers,
      );

      return OperationExecutionResult(
        success: true,
        response: response,
      );
    } catch (e) {
      debugPrint('Error executing operation ${operation.id}: $e');
      return OperationExecutionResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Retry failed operations
  Future<void> retryFailedOperations() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final pendingOperations = await _getPendingOperations();

      for (final operation in pendingOperations) {
        if (operation.retryCount < 3) {
          // Increment retry count
          operation.retryCount++;
          await _updateOperation(operation);

          // Wait before retry (exponential backoff)
          final delay = Duration(seconds: pow(2, operation.retryCount).toInt());
          await Future.delayed(delay);

          // Attempt execution
          final result = await _executeOperation(operation, null);

          if (result.success) {
            await _markOperationCompleted(operation.id);
          } else if (operation.retryCount >= 3) {
            await _markOperationFailed(
                operation.id, result.error ?? 'Max retries exceeded');
          }
        }
      }
    } catch (e) {
      debugPrint('Error retrying failed operations: $e');
    }
  }

  /// Store operation in outbox
  Future<void> _storeOperation(OutboxOperation operation) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final outboxJson = prefs.getString(_outboxKey) ?? '[]';
      final outbox = List<Map<String, dynamic>>.from(jsonDecode(outboxJson));

      outbox.add(operation.toJson());

      await prefs.setString(_outboxKey, jsonEncode(outbox));
      debugPrint('Stored operation in outbox: ${operation.id}');
    } catch (e) {
      debugPrint('Error storing operation: $e');
    }
  }

  /// Get pending operations
  Future<List<OutboxOperation>> _getPendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final outboxJson = prefs.getString(_outboxKey) ?? '[]';
      final outbox = List<Map<String, dynamic>>.from(jsonDecode(outboxJson));

      return outbox
          .map((op) => OutboxOperation.fromJson(op))
          .where((op) => op.status == OutboxStatus.pending)
          .toList();
    } catch (e) {
      debugPrint('Error getting pending operations: $e');
      return [];
    }
  }

  /// Update operation
  Future<void> _updateOperation(OutboxOperation operation) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final outboxJson = prefs.getString(_outboxKey) ?? '[]';
      final outbox = List<Map<String, dynamic>>.from(jsonDecode(outboxJson));

      final index = outbox.indexWhere((op) => op['id'] == operation.id);
      if (index != -1) {
        outbox[index] = operation.toJson();
        await prefs.setString(_outboxKey, jsonEncode(outbox));
      }
    } catch (e) {
      debugPrint('Error updating operation: $e');
    }
  }

  /// Mark operation as completed
  Future<void> _markOperationCompleted(String operationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final outboxJson = prefs.getString(_outboxKey) ?? '[]';
      final outbox = List<Map<String, dynamic>>.from(jsonDecode(outboxJson));

      final index = outbox.indexWhere((op) => op['id'] == operationId);
      if (index != -1) {
        outbox[index]['status'] = OutboxStatus.completed.name;
        outbox[index]['completedAt'] = DateTime.now().toIso8601String();
        await prefs.setString(_outboxKey, jsonEncode(outbox));
        debugPrint('Marked operation as completed: $operationId');
      }
    } catch (e) {
      debugPrint('Error marking operation as completed: $e');
    }
  }

  /// Mark operation as failed
  Future<void> _markOperationFailed(String operationId, String error) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final outboxJson = prefs.getString(_outboxKey) ?? '[]';
      final outbox = List<Map<String, dynamic>>.from(jsonDecode(outboxJson));

      final index = outbox.indexWhere((op) => op['id'] == operationId);
      if (index != -1) {
        outbox[index]['status'] = OutboxStatus.failed.name;
        outbox[index]['error'] = error;
        outbox[index]['failedAt'] = DateTime.now().toIso8601String();
        await prefs.setString(_outboxKey, jsonEncode(outbox));
        debugPrint('Marked operation as failed: $operationId');
      }
    } catch (e) {
      debugPrint('Error marking operation as failed: $e');
    }
  }

  /// Generate idempotency key
  String _generateIdempotencyKey() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = random.nextInt(1000000);
    return 'op_${timestamp}_$randomPart';
  }

  /// Get outbox statistics
  Future<OutboxStats> getStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final outboxJson = prefs.getString(_outboxKey) ?? '[]';
      final outbox = List<Map<String, dynamic>>.from(jsonDecode(outboxJson));

      final operations =
          outbox.map((op) => OutboxOperation.fromJson(op)).toList();

      return OutboxStats(
        total: operations.length,
        pending:
            operations.where((op) => op.status == OutboxStatus.pending).length,
        completed: operations
            .where((op) => op.status == OutboxStatus.completed)
            .length,
        failed:
            operations.where((op) => op.status == OutboxStatus.failed).length,
      );
    } catch (e) {
      debugPrint('Error getting outbox stats: $e');
      return OutboxStats(total: 0, pending: 0, completed: 0, failed: 0);
    }
  }

  /// Clear completed operations (older than 7 days)
  Future<void> clearCompletedOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final outboxJson = prefs.getString(_outboxKey) ?? '[]';
      final outbox = List<Map<String, dynamic>>.from(jsonDecode(outboxJson));

      final cutoffDate = DateTime.now().subtract(const Duration(days: 7));
      final filteredOutbox = outbox.where((op) {
        if (op['status'] == OutboxStatus.completed.name) {
          final completedAt = DateTime.tryParse(op['completedAt'] ?? '');
          return completedAt == null || completedAt.isAfter(cutoffDate);
        }
        return true;
      }).toList();

      await prefs.setString(_outboxKey, jsonEncode(filteredOutbox));
      debugPrint('Cleared old completed operations');
    } catch (e) {
      debugPrint('Error clearing completed operations: $e');
    }
  }

  /// Clear all operations (for testing)
  Future<void> clearAllOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_outboxKey);
      debugPrint('Cleared all outbox operations');
    } catch (e) {
      debugPrint('Error clearing all operations: $e');
    }
  }
}

class OutboxOperation {
  final String id;
  final String endpoint;
  final Map<String, dynamic> data;
  final String operationType;
  OutboxStatus status;
  final DateTime createdAt;
  DateTime? completedAt;
  DateTime? failedAt;
  String? error;
  int retryCount;

  OutboxOperation({
    required this.id,
    required this.endpoint,
    required this.data,
    required this.operationType,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.failedAt,
    this.error,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'endpoint': endpoint,
      'data': data,
      'operationType': operationType,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'failedAt': failedAt?.toIso8601String(),
      'error': error,
      'retryCount': retryCount,
    };
  }

  factory OutboxOperation.fromJson(Map<String, dynamic> json) {
    return OutboxOperation(
      id: json['id'],
      endpoint: json['endpoint'],
      data: Map<String, dynamic>.from(json['data']),
      operationType: json['operationType'],
      status: OutboxStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OutboxStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      failedAt:
          json['failedAt'] != null ? DateTime.parse(json['failedAt']) : null,
      error: json['error'],
      retryCount: json['retryCount'] ?? 0,
    );
  }
}

enum OutboxStatus {
  pending,
  completed,
  failed,
}

class OutboxResult {
  final bool success;
  final String? idempotencyKey;
  final Map<String, dynamic>? response;
  final String? error;
  final bool willRetry;

  OutboxResult({
    required this.success,
    this.idempotencyKey,
    this.response,
    this.error,
    this.willRetry = false,
  });
}

class OperationExecutionResult {
  final bool success;
  final Map<String, dynamic>? response;
  final String? error;

  OperationExecutionResult({
    required this.success,
    this.response,
    this.error,
  });
}

class OutboxStats {
  final int total;
  final int pending;
  final int completed;
  final int failed;

  OutboxStats({
    required this.total,
    required this.pending,
    required this.completed,
    required this.failed,
  });
}
