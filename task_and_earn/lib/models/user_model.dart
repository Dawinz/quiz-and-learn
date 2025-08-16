class UserModel {
  final String id;
  final String name;
  final String email;
  final int totalCoins;
  final List<String> roles;
  final bool isActive;
  final DateTime lastLogin;
  final bool emailVerified;
  final String? profilePicture;
  final String? phone;
  final String referralCode;
  final int referralCount;
  final int referralEarnings;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Additional properties for enhanced functionality
  final int currentBalance;
  final int totalEarnings;
  final int tasksCompleted;
  final int referralBonus;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.totalCoins,
    required this.roles,
    required this.isActive,
    required this.lastLogin,
    required this.emailVerified,
    this.profilePicture,
    this.phone,
    required this.referralCode,
    required this.referralCount,
    required this.referralEarnings,
    required this.createdAt,
    required this.updatedAt,
    this.currentBalance = 0,
    this.totalEarnings = 0,
    this.tasksCompleted = 0,
    this.referralBonus = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      totalCoins: map['totalCoins']?.toInt() ?? 0,
      roles: List<String>.from(map['roles'] ?? []),
      isActive: map['isActive'] ?? true,
      lastLogin: DateTime.tryParse(map['lastLogin'] ?? '') ?? DateTime.now(),
      emailVerified: map['emailVerified'] ?? false,
      profilePicture: map['profilePicture'],
      phone: map['phone'],
      referralCode: map['referralCode'] ?? '',
      referralCount: map['referralCount']?.toInt() ?? 0,
      referralEarnings: map['referralEarnings']?.toInt() ?? 0,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      currentBalance:
          map['currentBalance']?.toInt() ?? map['totalCoins']?.toInt() ?? 0,
      totalEarnings:
          map['totalEarnings']?.toInt() ?? map['totalCoins']?.toInt() ?? 0,
      tasksCompleted: map['tasksCompleted']?.toInt() ?? 0,
      referralBonus: map['referralBonus']?.toInt() ??
          map['referralEarnings']?.toInt() ??
          0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'totalCoins': totalCoins,
      'roles': roles,
      'isActive': isActive,
      'lastLogin': lastLogin.toIso8601String(),
      'emailVerified': emailVerified,
      'profilePicture': profilePicture,
      'phone': phone,
      'referralCode': referralCode,
      'referralCount': referralCount,
      'referralEarnings': referralEarnings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'currentBalance': currentBalance,
      'totalEarnings': totalEarnings,
      'tasksCompleted': tasksCompleted,
      'referralBonus': referralBonus,
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
    int? referralEarnings,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? currentBalance,
    int? totalEarnings,
    int? tasksCompleted,
    int? referralBonus,
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
      currentBalance: currentBalance ?? this.currentBalance,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      referralBonus: referralBonus ?? this.referralBonus,
    );
  }
}
