enum TransactionType {
  earned,
  spent,
  bonus,
  referral,
  achievement,
  dailyLogin,
  quizCompletion,
  premiumUnlock,
  adRemoval,
  refund
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled
}

class CoinTransaction {
  final String id;
  final String userId;
  final TransactionType type;
  final int amount;
  final int balanceAfter;
  final String description;
  final Map<String, dynamic> metadata;
  final TransactionStatus status;
  final DateTime timestamp;
  final String? referenceId; // For linking to specific actions

  const CoinTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.description,
    this.metadata = const {},
    this.status = TransactionStatus.completed,
    required this.timestamp,
    this.referenceId,
  });

  factory CoinTransaction.fromJson(Map<String, dynamic> json) {
    return CoinTransaction(
      id: json['id'],
      userId: json['userId'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      amount: json['amount'],
      balanceAfter: json['balanceAfter'],
      description: json['description'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
      referenceId: json['referenceId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'amount': amount,
      'balanceAfter': balanceAfter,
      'description': description,
      'metadata': metadata,
      'status': status.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'referenceId': referenceId,
    };
  }

  CoinTransaction copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    int? amount,
    int? balanceAfter,
    String? description,
    Map<String, dynamic>? metadata,
    TransactionStatus? status,
    DateTime? timestamp,
    String? referenceId,
  }) {
    return CoinTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      referenceId: referenceId ?? this.referenceId,
    );
  }

  // Get transaction icon based on type
  String get transactionIcon {
    switch (type) {
      case TransactionType.earned:
        return '💰';
      case TransactionType.spent:
        return '💸';
      case TransactionType.bonus:
        return '🎁';
      case TransactionType.referral:
        return '👥';
      case TransactionType.achievement:
        return '🏆';
      case TransactionType.dailyLogin:
        return '📅';
      case TransactionType.quizCompletion:
        return '✅';
      case TransactionType.premiumUnlock:
        return '🔓';
      case TransactionType.adRemoval:
        return '🚫';
      case TransactionType.refund:
        return '↩️';
    }
  }

  // Get transaction color based on type
  bool get isPositive {
    return type == TransactionType.earned ||
           type == TransactionType.bonus ||
           type == TransactionType.referral ||
           type == TransactionType.achievement ||
           type == TransactionType.dailyLogin ||
           type == TransactionType.quizCompletion ||
           type == TransactionType.refund;
  }

  // Get formatted amount with sign
  String get formattedAmount {
    final sign = isPositive ? '+' : '-';
    return '$sign$amount';
  }

  // Get transaction category for grouping
  String get category {
    switch (type) {
      case TransactionType.earned:
      case TransactionType.bonus:
      case TransactionType.referral:
      case TransactionType.achievement:
      case TransactionType.dailyLogin:
      case TransactionType.quizCompletion:
        return 'Earnings';
      case TransactionType.spent:
      case TransactionType.premiumUnlock:
      case TransactionType.adRemoval:
        return 'Spending';
      case TransactionType.refund:
        return 'Refunds';
    }
  }
}
