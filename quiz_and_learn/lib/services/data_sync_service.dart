import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'backend_service.dart';
import 'user_preferences_service.dart';

class DataSyncService {
  static final DataSyncService _instance = DataSyncService._internal();
  factory DataSyncService() => _instance;
  DataSyncService._internal();

  final BackendService _backendService = BackendService();
  final UserPreferencesService _userPreferencesService = UserPreferencesService();

  Timer? _syncTimer;
  bool _isInitialized = false;
  bool _isSyncing = false;

  // Sync intervals
  static const Duration _autoSyncInterval = Duration(minutes: 15);
  static const Duration _manualSyncTimeout = Duration(minutes: 5);

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _userPreferencesService.initialize('default_user');
      _startAutoSync();
      _isInitialized = true;
      print('✅ Data sync service initialized');
    } catch (e) {
      print('❌ Failed to initialize data sync service: $e');
    }
  }

  void _startAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_autoSyncInterval, (_) {
      if (!_isSyncing) {
        _performAutoSync();
      }
    });
  }

  Future<void> _performAutoSync() async {
    if (_isSyncing) return;

    try {
      _isSyncing = true;
      await _syncUserPreferences();
      print('✅ Auto-sync completed');
    } catch (e) {
      print('❌ Auto-sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> performManualSync() async {
    if (_isSyncing) {
      throw Exception('Sync already in progress');
    }

    try {
      _isSyncing = true;
      
      // Set a timeout for manual sync
      final syncFuture = _performFullSync();
      final result = await syncFuture.timeout(_manualSyncTimeout);
      
      print('✅ Manual sync completed');
      return result;
    } catch (e) {
      print('❌ Manual sync failed: $e');
      rethrow;
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _performFullSync() async {
    final syncTasks = [
      'user_preferences',
    ];

    for (final task in syncTasks) {
      try {
        switch (task) {
          case 'user_preferences':
            await _syncUserPreferences();
            break;
        }
        print('✅ Synced: $task');
      } catch (e) {
        print('❌ Failed to sync $task: $e');
        // Continue with other sync tasks
      }
    }
  }

  // Sync user preferences
  Future<void> _syncUserPreferences() async {
    try {
      // Get local preferences
      final localPreferences = _userPreferencesService.currentPreferences;
      if (localPreferences == null) return;

      // Sync to backend
      await _backendService.updateUserPreferences(localPreferences);

      print('✅ User preferences synced');
    } catch (e) {
      print('Error syncing user preferences: $e');
    }
  }

  // Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final isOnline = await _backendService.healthCheck();
      final lastSync = await _getLastSyncTimestamp();

      return {
        'isOnline': isOnline,
        'lastSync': lastSync?.toIso8601String(),
        'pendingItems': 0,
        'isSyncing': _isSyncing,
        'nextAutoSync': _getNextAutoSyncTime().toIso8601String(),
      };
    } catch (e) {
      return {
        'isOnline': false,
        'lastSync': null,
        'pendingItems': 0,
        'isSyncing': _isSyncing,
        'error': e.toString(),
        'nextAutoSync': _getNextAutoSyncTime().toIso8601String(),
      };
    }
  }

  Future<DateTime?> _getLastSyncTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getString('last_sync_timestamp');
      return timestamp != null ? DateTime.parse(timestamp) : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _setLastSyncTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_sync_timestamp', DateTime.now().toIso8601String());
    } catch (e) {
      print('Error saving sync timestamp: $e');
    }
  }

  Future<int> _getPendingItemsCount() async {
    // For now, return 0 since we're not tracking pending items
    return 0;
  }

  DateTime _getNextAutoSyncTime() {
    if (_syncTimer == null) return DateTime.now();
    // This is a simplified calculation - in a real app you'd track the actual next sync time
    return DateTime.now().add(_autoSyncInterval);
  }

  // Clear all local data
  Future<void> clearAllLocalData() async {
    try {
      await _userPreferencesService.clearPreferences();
      await _setLastSyncTimestamp();
      print('✅ All local data cleared');
    } catch (e) {
      print('❌ Error clearing local data: $e');
      rethrow;
    }
  }

  // Get sync statistics
  Future<Map<String, dynamic>> getSyncStatistics() async {
    try {
      final lastSync = await _getLastSyncTimestamp();
      final isOnline = await _backendService.healthCheck();

      return {
        'lastSync': lastSync?.toIso8601String(),
        'pendingItems': 0,
        'isOnline': isOnline,
        'autoSyncEnabled': _syncTimer != null,
        'autoSyncInterval': _autoSyncInterval.inMinutes,
        'totalSyncs': await _getTotalSyncCount(),
      };
    } catch (e) {
      return {
        'lastSync': null,
        'pendingItems': 0,
        'isOnline': false,
        'autoSyncEnabled': false,
        'autoSyncInterval': _autoSyncInterval.inMinutes,
        'totalSyncs': 0,
        'error': e.toString(),
      };
    }
  }

  Future<int> _getTotalSyncCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('total_sync_count') ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _incrementSyncCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt('total_sync_count') ?? 0;
      await prefs.setInt('total_sync_count', currentCount + 1);
    } catch (e) {
      print('Error incrementing sync count: $e');
    }
  }

  // Dispose resources
  void dispose() {
    _syncTimer?.cancel();
    _isInitialized = false;
  }
}

