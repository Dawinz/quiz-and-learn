import 'package:flutter/material.dart';

enum AchievementType {
  streak,
  score,
  category,
  difficulty,
  speed,
  accuracy,
  special
}

enum AchievementTier {
  bronze,
  silver,
  gold,
  platinum,
  diamond
}

class QuizAchievement {
  final String id;
  final String title;
  final String description;
  final String iconPath;
  final AchievementType type;
  final AchievementTier tier;
  final int requirement;
  final int pointsReward;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final Map<String, dynamic> metadata;

  const QuizAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.type,
    required this.tier,
    required this.requirement,
    required this.pointsReward,
    this.isUnlocked = false,
    this.unlockedAt,
    this.metadata = const {},
  });

  factory QuizAchievement.fromJson(Map<String, dynamic> json) {
    return QuizAchievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconPath: json['iconPath'],
      type: AchievementType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      tier: AchievementTier.values.firstWhere(
        (e) => e.toString().split('.').last == json['tier'],
      ),
      requirement: json['requirement'],
      pointsReward: json['pointsReward'],
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null 
          ? DateTime.parse(json['unlockedAt']) 
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconPath': iconPath,
      'type': type.toString().split('.').last,
      'tier': tier.toString().split('.').last,
      'requirement': requirement,
      'pointsReward': pointsReward,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  QuizAchievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconPath,
    AchievementType? type,
    AchievementTier? tier,
    int? requirement,
    int? pointsReward,
    bool? isUnlocked,
    DateTime? unlockedAt,
    Map<String, dynamic>? metadata,
  }) {
    return QuizAchievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      type: type ?? this.type,
      tier: tier ?? this.tier,
      requirement: requirement ?? this.requirement,
      pointsReward: pointsReward ?? this.pointsReward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Get tier color
  Color get tierColor {
    switch (tier) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.platinum:
        return const Color(0xFFE5E4E2);
      case AchievementTier.diamond:
        return const Color(0xFFB9F2FF);
    }
  }

  // Get tier name
  String get tierName {
    return tier.toString().split('.').last.toUpperCase();
  }

  // Check if achievement can be unlocked
  bool canUnlock(int currentValue) {
    return !isUnlocked && currentValue >= requirement;
  }
}

// Predefined achievements
class QuizAchievements {
  static const List<QuizAchievement> all = [
    // Streak achievements
    QuizAchievement(
      id: 'streak_3',
      title: 'Getting Started',
      description: 'Complete quizzes for 3 days in a row',
      iconPath: 'assets/icons/streak_bronze.png',
      type: AchievementType.streak,
      tier: AchievementTier.bronze,
      requirement: 3,
      pointsReward: 50,
    ),
    QuizAchievement(
      id: 'streak_7',
      title: 'Week Warrior',
      description: 'Complete quizzes for 7 days in a row',
      iconPath: 'assets/icons/streak_silver.png',
      type: AchievementType.streak,
      tier: AchievementTier.silver,
      requirement: 7,
      pointsReward: 100,
    ),
    QuizAchievement(
      id: 'streak_30',
      title: 'Monthly Master',
      description: 'Complete quizzes for 30 days in a row',
      iconPath: 'assets/icons/streak_gold.png',
      type: AchievementType.streak,
      tier: AchievementTier.gold,
      requirement: 30,
      pointsReward: 500,
    ),
    QuizAchievement(
      id: 'streak_100',
      title: 'Century Streak',
      description: 'Complete quizzes for 100 days in a row',
      iconPath: 'assets/icons/streak_platinum.png',
      type: AchievementType.streak,
      tier: AchievementTier.platinum,
      requirement: 100,
      pointsReward: 1000,
    ),

    // Score achievements
    QuizAchievement(
      id: 'score_1000',
      title: 'Point Collector',
      description: 'Earn 1,000 total points',
      iconPath: 'assets/icons/score_bronze.png',
      type: AchievementType.score,
      tier: AchievementTier.bronze,
      requirement: 1000,
      pointsReward: 50,
    ),
    QuizAchievement(
      id: 'score_10000',
      title: 'Point Master',
      description: 'Earn 10,000 total points',
      iconPath: 'assets/icons/score_silver.png',
      type: AchievementType.score,
      tier: AchievementTier.silver,
      requirement: 10000,
      pointsReward: 200,
    ),
    QuizAchievement(
      id: 'score_100000',
      title: 'Point Legend',
      description: 'Earn 100,000 total points',
      iconPath: 'assets/icons/score_gold.png',
      type: AchievementType.score,
      tier: AchievementTier.gold,
      requirement: 100000,
      pointsReward: 1000,
    ),

    // Category achievements
    QuizAchievement(
      id: 'category_all',
      title: 'Jack of All Trades',
      description: 'Complete quizzes in all categories',
      iconPath: 'assets/icons/category_bronze.png',
      type: AchievementType.category,
      tier: AchievementTier.bronze,
      requirement: 15, // Total number of categories
      pointsReward: 100,
    ),

    // Difficulty achievements
    QuizAchievement(
      id: 'difficulty_hard',
      title: 'Hard Mode Hero',
      description: 'Complete 50 hard difficulty quizzes',
      iconPath: 'assets/icons/difficulty_silver.png',
      type: AchievementType.difficulty,
      tier: AchievementTier.silver,
      requirement: 50,
      pointsReward: 300,
    ),

    // Speed achievements
    QuizAchievement(
      id: 'speed_fast',
      title: 'Speed Demon',
      description: 'Complete a quiz in under 2 minutes',
      iconPath: 'assets/icons/speed_bronze.png',
      type: AchievementType.speed,
      tier: AchievementTier.bronze,
      requirement: 120, // seconds
      pointsReward: 50,
    ),

    // Accuracy achievements
    QuizAchievement(
      id: 'accuracy_perfect',
      title: 'Perfect Score',
      description: 'Get 100% accuracy on a quiz',
      iconPath: 'assets/icons/accuracy_gold.png',
      type: AchievementType.accuracy,
      tier: AchievementTier.gold,
      requirement: 100, // percentage
      pointsReward: 200,
    ),

    // Special achievements
    QuizAchievement(
      id: 'first_quiz',
      title: 'First Steps',
      description: 'Complete your first quiz',
      iconPath: 'assets/icons/special_bronze.png',
      type: AchievementType.special,
      tier: AchievementTier.bronze,
      requirement: 1,
      pointsReward: 25,
    ),
    QuizAchievement(
      id: 'quiz_master',
      title: 'Quiz Master',
      description: 'Complete 1000 quizzes',
      iconPath: 'assets/icons/special_diamond.png',
      type: AchievementType.special,
      tier: AchievementTier.diamond,
      requirement: 1000,
      pointsReward: 5000,
    ),
  ];

  // Get achievements by type
  static List<QuizAchievement> getByType(AchievementType type) {
    return all.where((achievement) => achievement.type == type).toList();
  }

  // Get achievements by tier
  static List<QuizAchievement> getByTier(AchievementTier tier) {
    return all.where((achievement) => achievement.tier == tier).toList();
  }

  // Get unlocked achievements
  static List<QuizAchievement> getUnlocked(List<QuizAchievement> userAchievements) {
    return userAchievements.where((achievement) => achievement.isUnlocked).toList();
  }

  // Get locked achievements
  static List<QuizAchievement> getLocked(List<QuizAchievement> userAchievements) {
    return all.where((achievement) => 
      !userAchievements.any((userAchievement) => 
        userAchievement.id == achievement.id && userAchievement.isUnlocked
      )
    ).toList();
  }
}
