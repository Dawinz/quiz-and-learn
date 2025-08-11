class UserModel {
  final String id;
  final String name;
  final String email;
  final int totalCoins;
  final List<String> roles;
  final bool isActive;
  final DateTime? lastLogin;
  final bool emailVerified;
  final String? profilePicture;
  final String? phone;
  final String? referralCode;
  final int referralCount;
  final double referralEarnings;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.totalCoins,
    required this.roles,
    required this.isActive,
    this.lastLogin,
    required this.emailVerified,
    this.profilePicture,
    this.phone,
    this.referralCode,
    required this.referralCount,
    required this.referralEarnings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map["id"]?.toString() ?? "",
      name: map["name"]?.toString() ?? "",
      email: map["email"]?.toString() ?? "",
      totalCoins: map["totalCoins"]?.toInt() ?? 0,
      roles: List<String>.from(map["roles"] ?? []),
      isActive: map["isActive"] ?? false,
      lastLogin: map["lastLogin"] != null
          ? DateTime.tryParse(map["lastLogin"].toString())
          : null,
      emailVerified: map["emailVerified"] ?? false,
      profilePicture: map["profilePicture"]?.toString(),
      phone: map["phone"]?.toString(),
      referralCode: map["referralCode"]?.toString(),
      referralCount: map["referralCount"]?.toInt() ?? 0,
      referralEarnings: (map["referralEarnings"] ?? 0).toDouble(),
      createdAt: DateTime.tryParse(map["createdAt"].toString()) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map["updatedAt"].toString()) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "totalCoins": totalCoins,
      "roles": roles,
      "isActive": isActive,
      "lastLogin": lastLogin?.toIso8601String(),
      "emailVerified": emailVerified,
      "profilePicture": profilePicture,
      "phone": phone,
      "referralCode": referralCode,
      "referralCount": referralCount,
      "referralEarnings": referralEarnings,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    int? totalCoins,
    List<String>? roles,
    bool? isActive,
    DateTime? lastLogin,
    bool? emailVerified,
    String? profilePicture,
    String? phone,
    String? referralCode,
    int? referralCount,
    double? referralEarnings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      totalCoins: totalCoins ?? this.totalCoins,
      roles: roles ?? this.roles,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      emailVerified: emailVerified ?? this.emailVerified,
      profilePicture: profilePicture ?? this.profilePicture,
      phone: phone ?? this.phone,
      referralCode: referralCode ?? this.referralCode,
      referralCount: referralCount ?? this.referralCount,
      referralEarnings: referralEarnings ?? this.referralEarnings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
