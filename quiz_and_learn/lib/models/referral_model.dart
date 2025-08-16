enum ReferralStatus { pending, completed, expired, cancelled }

class ReferralModel {
  final String id;
  final String referrerId; // User who referred
  final String referredId; // User who was referred
  final String referralCode;
  final ReferralStatus status;
  final int bonusAmount;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic> metadata;

  const ReferralModel({
    required this.id,
    required this.referrerId,
    required this.referredId,
    required this.referralCode,
    this.status = ReferralStatus.pending,
    required this.bonusAmount,
    required this.createdAt,
    this.completedAt,
    this.metadata = const {},
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      id: json['id'],
      referrerId: json['referrerId'],
      referredId: json['referredId'],
      referralCode: json['referralCode'],
      status: ReferralStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      bonusAmount: json['bonusAmount'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referrerId': referrerId,
      'referredId': referredId,
      'referralCode': referralCode,
      'status': status.toString().split('.').last,
      'bonusAmount': bonusAmount,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  ReferralModel copyWith({
    String? id,
    String? referrerId,
    String? referredId,
    String? referralCode,
    ReferralStatus? status,
    int? bonusAmount,
    DateTime? createdAt,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ReferralModel(
      id: id ?? this.id,
      referrerId: referrerId ?? this.referrerId,
      referredId: referredId ?? this.referredId,
      referralCode: referralCode ?? this.referralCode,
      status: status ?? this.status,
      bonusAmount: bonusAmount ?? this.bonusAmount,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Check if referral is expired (30 days)
  bool get isExpired {
    final expiryDate = createdAt.add(const Duration(days: 30));
    return DateTime.now().isAfter(expiryDate);
  }

  // Check if referral can be completed
  bool get canComplete {
    return status == ReferralStatus.pending && !isExpired;
  }

  // Get days until expiry
  int get daysUntilExpiry {
    final expiryDate = createdAt.add(const Duration(days: 30));
    final now = DateTime.now();
    if (now.isAfter(expiryDate)) return 0;

    final difference = expiryDate.difference(now);
    return difference.inDays;
  }

  // Get referral status message
  String get statusMessage {
    switch (status) {
      case ReferralStatus.pending:
        if (isExpired) {
          return 'Expired';
        }
        return 'Pending';
      case ReferralStatus.completed:
        return 'Completed';
      case ReferralStatus.expired:
        return 'Expired';
      case ReferralStatus.cancelled:
        return 'Cancelled';
    }
  }

  // Get status color
  String get statusColor {
    switch (status) {
      case ReferralStatus.pending:
        return isExpired ? '🔴' : '🟡';
      case ReferralStatus.completed:
        return '🟢';
      case ReferralStatus.expired:
        return '🔴';
      case ReferralStatus.cancelled:
        return '⚫';
    }
  }
}

class ReferralCode {
  final String code;
  final String userId;
  final int bonusAmount;
  final int maxUses;
  final int currentUses;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isActive;

  const ReferralCode({
    required this.code,
    required this.userId,
    required this.bonusAmount,
    this.maxUses = -1, // -1 for unlimited
    this.currentUses = 0,
    required this.createdAt,
    this.expiresAt,
    this.isActive = true,
  });

  factory ReferralCode.fromJson(Map<String, dynamic> json) {
    return ReferralCode(
      code: json['code'],
      userId: json['userId'],
      bonusAmount: json['bonusAmount'],
      maxUses: json['maxUses'] ?? -1,
      currentUses: json['currentUses'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'userId': userId,
      'bonusAmount': bonusAmount,
      'maxUses': maxUses,
      'currentUses': currentUses,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  ReferralCode copyWith({
    String? code,
    String? userId,
    int? bonusAmount,
    int? maxUses,
    int? currentUses,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isActive,
  }) {
    return ReferralCode(
      code: code ?? this.code,
      userId: userId ?? this.userId,
      bonusAmount: bonusAmount ?? this.bonusAmount,
      maxUses: maxUses ?? this.maxUses,
      currentUses: currentUses ?? this.currentUses,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Check if code can be used
  bool get canUse {
    if (!isActive) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    if (maxUses > 0 && currentUses >= maxUses) return false;
    return true;
  }

  // Check if code is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  // Get remaining uses
  int get remainingUses {
    if (maxUses == -1) return -1; // Unlimited
    return maxUses - currentUses;
  }

  // Get expiry status
  String get expiryStatus {
    if (expiresAt == null) return 'Never expires';
    if (isExpired) return 'Expired';

    final daysLeft = expiresAt!.difference(DateTime.now()).inDays;
    if (daysLeft == 0) return 'Expires today';
    if (daysLeft == 1) return 'Expires tomorrow';
    return 'Expires in $daysLeft days';
  }
}
