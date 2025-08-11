enum TransactionType { earn, spend, withdrawal, refund, bonus, referral }

enum TransactionStatus { pending, completed, failed, cancelled }

class TransactionModel {
  final String id;
  final String userId;
  final TransactionType type;
  final int amount;
  final DateTime date;
  final String? method;
  final TransactionStatus status;
  final String? description;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.date,
    this.method,
    required this.status,
    this.description,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) {
    try {
      return TransactionModel(
        id: id,
        userId: map['userId']?.toString() ?? '',
        type: TransactionType.values.firstWhere(
          (e) =>
              e.toString().split('.').last ==
              (map['type']?.toString() ?? 'earn'),
          orElse: () => TransactionType.earn,
        ),
        amount: (map['amount'] is int)
            ? map['amount']
            : int.tryParse(map['amount']?.toString() ?? '0') ?? 0,
        date: DateTime.tryParse(map['createdAt']?.toString() ??
                map['date']?.toString() ??
                '') ??
            DateTime.now(),
        method: map['source'] is String ? map['source'] : null,
        status: TransactionStatus.values.firstWhere(
          (e) =>
              e.toString().split('.').last ==
              (map['status']?.toString() ?? 'completed'),
          orElse: () => TransactionStatus.completed,
        ),
        description: map['description']?.toString(),
      );
    } catch (e) {
      // Return a default transaction if parsing fails
      return TransactionModel(
        id: id,
        userId: '',
        type: TransactionType.earn,
        amount: 0,
        date: DateTime.now(),
        method: null,
        status: TransactionStatus.completed,
        description: 'Error parsing transaction',
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.toString().split('.').last,
      'amount': amount,
      'date': date.toIso8601String(),
      'method': method,
      'status': status.toString().split('.').last,
      'description': description,
    };
  }
}
