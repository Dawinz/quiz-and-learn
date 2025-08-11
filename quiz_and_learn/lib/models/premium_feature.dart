enum FeatureType {
  premiumQuiz,
  adRemoval,
  unlimitedQuizzes,
  advancedAnalytics,
  customThemes,
  prioritySupport
}

enum FeatureStatus {
  locked,
  unlocked,
  expired
}

class PremiumFeature {
  final String id;
  final String name;
  final String description;
  final FeatureType type;
  final int coinCost;
  final Duration? duration; // null for permanent unlock
  final String iconPath;
  final Map<String, dynamic> metadata;
  final bool isActive;

  const PremiumFeature({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.coinCost,
    this.duration,
    required this.iconPath,
    this.metadata = const {},
    this.isActive = true,
  });

  factory PremiumFeature.fromJson(Map<String, dynamic> json) {
    return PremiumFeature(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: FeatureType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      coinCost: json['coinCost'],
      duration: json['duration'] != null 
          ? Duration(days: json['duration']) 
          : null,
      iconPath: json['iconPath'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'coinCost': coinCost,
      'duration': duration?.inDays,
      'iconPath': iconPath,
      'metadata': metadata,
      'isActive': isActive,
    };
  }

  PremiumFeature copyWith({
    String? id,
    String? name,
    String? description,
    FeatureType? type,
    int? coinCost,
    Duration? duration,
    String? iconPath,
    Map<String, dynamic>? metadata,
    bool? isActive,
  }) {
    return PremiumFeature(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      coinCost: coinCost ?? this.coinCost,
      duration: duration ?? this.duration,
      iconPath: iconPath ?? this.iconPath,
      metadata: metadata ?? this.metadata,
      isActive: isActive ?? this.isActive,
    );
  }

  // Check if feature is permanent
  bool get isPermanent => duration == null;

  // Get feature icon
  String get featureIcon {
    switch (type) {
      case FeatureType.premiumQuiz:
        return '🔓';
      case FeatureType.adRemoval:
        return '🚫';
      case FeatureType.unlimitedQuizzes:
        return '♾️';
      case FeatureType.advancedAnalytics:
        return '📊';
      case FeatureType.customThemes:
        return '🎨';
      case FeatureType.prioritySupport:
        return '⭐';
    }
  }

  // Get formatted duration
  String get formattedDuration {
    if (isPermanent) return 'Permanent';
    if (duration!.inDays == 1) return '1 day';
    if (duration!.inDays < 7) return '${duration!.inDays} days';
    if (duration!.inDays < 30) return '${(duration!.inDays / 7).floor()} weeks';
    return '${(duration!.inDays / 30).floor()} months';
  }

  // Get feature category
  String get category {
    switch (type) {
      case FeatureType.premiumQuiz:
      case FeatureType.unlimitedQuizzes:
        return 'Quiz Features';
      case FeatureType.adRemoval:
      case FeatureType.customThemes:
        return 'User Experience';
      case FeatureType.advancedAnalytics:
      case FeatureType.prioritySupport:
        return 'Premium Services';
    }
  }
}

class UserPremiumFeature {
  final String id;
  final String userId;
  final String featureId;
  final FeatureStatus status;
  final DateTime unlockedAt;
  final DateTime? expiresAt;
  final int coinCost;
  final Map<String, dynamic> metadata;

  const UserPremiumFeature({
    required this.id,
    required this.userId,
    required this.featureId,
    required this.status,
    required this.unlockedAt,
    this.expiresAt,
    required this.coinCost,
    this.metadata = const {},
  });

  factory UserPremiumFeature.fromJson(Map<String, dynamic> json) {
    return UserPremiumFeature(
      id: json['id'],
      userId: json['userId'],
      featureId: json['featureId'],
      status: FeatureStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      unlockedAt: DateTime.parse(json['unlockedAt']),
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt']) 
          : null,
      coinCost: json['coinCost'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'featureId': featureId,
      'status': status.toString().split('.').last,
      'unlockedAt': unlockedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'coinCost': coinCost,
      'metadata': metadata,
    };
  }

  UserPremiumFeature copyWith({
    String? id,
    String? userId,
    String? featureId,
    FeatureStatus? status,
    DateTime? unlockedAt,
    DateTime? expiresAt,
    int? coinCost,
    Map<String, dynamic>? metadata,
  }) {
    return UserPremiumFeature(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      featureId: featureId ?? this.featureId,
      status: status ?? this.status,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      coinCost: coinCost ?? this.coinCost,
      metadata: metadata ?? this.metadata,
    );
  }

  // Check if feature is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  // Check if feature is active
  bool get isActive {
    return status == FeatureStatus.unlocked && !isExpired;
  }

  // Get time until expiry
  Duration? get timeUntilExpiry {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expiresAt!)) return Duration.zero;
    return expiresAt!.difference(now);
  }

  // Get formatted expiry time
  String get expiryStatus {
    if (expiresAt == null) return 'Permanent';
    if (isExpired) return 'Expired';
    
    final timeLeft = timeUntilExpiry!;
    if (timeLeft.inDays > 0) {
      return 'Expires in ${timeLeft.inDays} days';
    } else if (timeLeft.inHours > 0) {
      return 'Expires in ${timeLeft.inHours} hours';
    } else if (timeLeft.inMinutes > 0) {
      return 'Expires in ${timeLeft.inMinutes} minutes';
    } else {
      return 'Expires soon';
    }
  }

  // Get status icon
  String get statusIcon {
    switch (status) {
      case FeatureStatus.locked:
        return '🔒';
      case FeatureStatus.unlocked:
        return isExpired ? '⏰' : '✅';
      case FeatureStatus.expired:
        return '⏰';
    }
  }
}
