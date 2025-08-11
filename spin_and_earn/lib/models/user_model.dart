// import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final int coins;
  final Map<String, dynamic> goals;
  final Map<String, dynamic> spins;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.coins,
    required this.goals,
    required this.spins,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['profile']?['name'] ?? '',
      email: map['profile']?['email'] ?? '',
      phone: map['profile']?['phone'],
      coins: map['balance']?['coins'] ?? 0,
      goals: map['goals'] ?? {},
      spins: map['spins'] ?? {
        'dailyUsed': 0,
        'dailyLimit': 5,
        'lastSpinDate': null,
      },
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profile': {'name': name, 'email': email, 'phone': phone},
      'balance': {'coins': coins},
      'goals': goals,
      'spins': spins,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    int? coins,
    Map<String, dynamic>? goals,
    Map<String, dynamic>? spins,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      coins: coins ?? this.coins,
      goals: goals ?? this.goals,
      spins: spins ?? this.spins,
    );
  }

  // Spin-related getters
  int get dailyUsed => spins['dailyUsed'] ?? 0;
  int get dailyLimit => spins['dailyLimit'] ?? 5;
  DateTime? get lastSpinDate => spins['lastSpinDate'] != null 
      ? (spins['lastSpinDate'] is DateTime ? spins['lastSpinDate'] : DateTime.now())
      : null;
  int get remainingSpins => dailyLimit - dailyUsed;
  bool get canSpin => remainingSpins > 0;

  // Check if daily spins should reset
  bool get shouldResetDailySpins {
    if (lastSpinDate == null) return true;
    final now = DateTime.now();
    final lastSpin = lastSpinDate!;
    return now.year != lastSpin.year || 
           now.month != lastSpin.month || 
           now.day != lastSpin.day;
  }
} 