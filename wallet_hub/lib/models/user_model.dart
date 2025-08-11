class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final int coins;
  final Map<String, dynamic> goals;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.coins,
    required this.goals,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['profile']['name'] ?? '',
      email: map['profile']['email'] ?? '',
      phone: map['profile']['phone'],
      coins: map['balance']['coins'] ?? 0,
      goals: map['goals'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profile': {'name': name, 'email': email, 'phone': phone},
      'balance': {'coins': coins},
      'goals': goals,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    int? coins,
    Map<String, dynamic>? goals,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      coins: coins ?? this.coins,
      goals: goals ?? this.goals,
    );
  }
}
