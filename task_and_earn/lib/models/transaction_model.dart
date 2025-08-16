import 'package:flutter/material.dart';

class TransactionModel {
  final String id;
  final String type;
  final int amount;
  final String description;
  final DateTime timestamp;
  final String status;
  final String? referenceId;
  final String? notes;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
    required this.status,
    this.referenceId,
    this.notes,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id']?.toString() ?? '',
      type: map['type'] ?? '',
      amount: map['amount']?.toInt() ?? 0,
      description: map['description'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      status: map['status'] ?? '',
      referenceId: map['referenceId'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'referenceId': referenceId,
      'notes': notes,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? type,
    int? amount,
    String? description,
    DateTime? timestamp,
    String? status,
    String? referenceId,
    String? notes,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      referenceId: referenceId ?? this.referenceId,
      notes: notes ?? this.notes,
    );
  }

  bool get isCredit => amount > 0;
  bool get isDebit => amount < 0;
  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF4CAF50); // Green
      case 'pending':
        return const Color(0xFFFF9800); // Orange
      case 'failed':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  IconData get typeIcon {
    switch (type.toLowerCase()) {
      case 'task_completed':
        return Icons.task_alt;
      case 'referral_bonus':
        return Icons.people;
      case 'daily_bonus':
        return Icons.card_giftcard;
      case 'withdrawal':
        return Icons.account_balance;
      case 'deposit':
        return Icons.account_balance_wallet;
      default:
        return Icons.attach_money;
    }
  }

  String get formattedAmount {
    if (isCredit) {
      return '+$amount';
    } else if (isDebit) {
      return '$amount';
    } else {
      return '0';
    }
  }

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays != 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours != 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes != 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
