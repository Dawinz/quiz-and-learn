// import 'package:cloud_firestore/cloud_firestore.dart';

class SpinRewardModel {
  final String id;
  final String userId;
  final int amount;
  final DateTime date;
  final String source;

  SpinRewardModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.date,
    required this.source,
  });

  factory SpinRewardModel.fromMap(Map<String, dynamic> map, String id) {
    return SpinRewardModel(
      id: id,
      userId: map['userId'] ?? '',
      amount: map['amount'] ?? 0,
      date: map['date'] is DateTime ? map['date'] : DateTime.now(),
      source: map['source'] ?? 'Spin & Earn',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'date': date.toIso8601String(),
      'source': source,
      'type': 'earning',
    };
  }

  SpinRewardModel copyWith({
    String? id,
    String? userId,
    int? amount,
    DateTime? date,
    String? source,
  }) {
    return SpinRewardModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      source: source ?? this.source,
    );
  }
} 