class ReferralCodeResponse {
  final bool success;
  final String referralCode;
  final int referralCount;
  final int totalEarnings;

  ReferralCodeResponse({
    required this.success,
    required this.referralCode,
    required this.referralCount,
    required this.totalEarnings,
  });

  factory ReferralCodeResponse.fromJson(Map<String, dynamic> json) {
    return ReferralCodeResponse(
      success: json['success'] ?? false,
      referralCode: json['referralCode'] ?? '',
      referralCount: json['referralCount'] ?? 0,
      totalEarnings: json['totalEarnings'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'referralCode': referralCode,
      'referralCount': referralCount,
      'totalEarnings': totalEarnings,
    };
  }
}

class ReferralUsageResponse {
  final bool success;
  final String message;
  final String referrerId;
  final int rewardAmount;

  ReferralUsageResponse({
    required this.success,
    required this.message,
    required this.referrerId,
    required this.rewardAmount,
  });

  factory ReferralUsageResponse.fromJson(Map<String, dynamic> json) {
    return ReferralUsageResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      referrerId: json['referrerId'] ?? '',
      rewardAmount: json['rewardAmount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'referrerId': referrerId,
      'rewardAmount': rewardAmount,
    };
  }
}

class ReferralValidationResponse {
  final bool success;
  final bool isValid;
  final String referrerId;

  ReferralValidationResponse({
    required this.success,
    required this.isValid,
    required this.referrerId,
  });

  factory ReferralValidationResponse.fromJson(Map<String, dynamic> json) {
    return ReferralValidationResponse(
      success: json['success'] ?? false,
      isValid: json['isValid'] ?? false,
      referrerId: json['referrerId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'isValid': isValid,
      'referrerId': referrerId,
    };
  }
}

class ReferralInfoResponse {
  final bool success;
  final bool hasReferralCode;
  final String? referralCode;
  final int referralCount;
  final int totalEarnings;
  final List<ReferralRecord> referrals;

  ReferralInfoResponse({
    required this.success,
    required this.hasReferralCode,
    this.referralCode,
    required this.referralCount,
    required this.totalEarnings,
    required this.referrals,
  });

  factory ReferralInfoResponse.fromJson(Map<String, dynamic> json) {
    return ReferralInfoResponse(
      success: json['success'] ?? false,
      hasReferralCode: json['hasReferralCode'] ?? false,
      referralCode: json['referralCode'],
      referralCount: json['referralCount'] ?? 0,
      totalEarnings: json['totalEarnings'] ?? 0,
      referrals: (json['referrals'] as List<dynamic>?)
              ?.map((e) => ReferralRecord.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'hasReferralCode': hasReferralCode,
      'referralCode': referralCode,
      'referralCount': referralCount,
      'totalEarnings': totalEarnings,
      'referrals': referrals.map((e) => e.toJson()).toList(),
    };
  }
}

class ReferralRecord {
  final String id;
  final String referredUserId;
  final String referredEmail;
  final DateTime createdAt;
  final String status;
  final int rewardAmount;
  final bool isPaid;

  ReferralRecord({
    required this.id,
    required this.referredUserId,
    required this.referredEmail,
    required this.createdAt,
    required this.status,
    required this.rewardAmount,
    required this.isPaid,
  });

  factory ReferralRecord.fromJson(Map<String, dynamic> json) {
    return ReferralRecord(
      id: json['id'] ?? '',
      referredUserId: json['referredUserId'] ?? '',
      referredEmail: json['referredEmail'] ?? '',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'pending',
      rewardAmount: json['rewardAmount'] ?? 0,
      isPaid: json['isPaid'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referredUserId': referredUserId,
      'referredEmail': referredEmail,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'rewardAmount': rewardAmount,
      'isPaid': isPaid,
    };
  }
}
