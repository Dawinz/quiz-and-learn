enum WithdrawalMethod { mpesa, tigopesa, airtel, halopesa, usdt }

enum WithdrawalStatus { pending, completed, declined }

class WithdrawalModel {
  final String id;
  final String userId;
  final WithdrawalMethod method;
  final String account;
  final int amount;
  final WithdrawalStatus status;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? notes;

  WithdrawalModel({
    required this.id,
    required this.userId,
    required this.method,
    required this.account,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.processedAt,
    this.notes,
  });

  factory WithdrawalModel.fromMap(Map<String, dynamic> map, String id) {
    return WithdrawalModel(
      id: id,
      userId: map['userId'] ?? '',
      method: WithdrawalMethod.values.firstWhere(
        (e) => e.toString().split('.').last == map['method'],
        orElse: () => WithdrawalMethod.mpesa,
      ),
      account: map['account'] ?? '',
      amount: map['amount'] ?? 0,
      status: WithdrawalStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => WithdrawalStatus.pending,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      processedAt: map['processedAt'] != null
          ? DateTime.parse(map['processedAt'])
          : null,
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'method': method.toString().split('.').last,
      'account': account,
      'amount': amount,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'processedAt':
          processedAt != null ? processedAt!.toIso8601String() : null,
      'notes': notes,
    };
  }

  WithdrawalModel copyWith({
    String? id,
    String? userId,
    WithdrawalMethod? method,
    String? account,
    int? amount,
    WithdrawalStatus? status,
    DateTime? createdAt,
    DateTime? processedAt,
    String? notes,
  }) {
    return WithdrawalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      method: method ?? this.method,
      account: account ?? this.account,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      notes: notes ?? this.notes,
    );
  }
}
