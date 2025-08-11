class QuizStreak {
  final String userId;
  final int currentStreak;
  final int longestStreak;
  final int totalQuizzesCompleted;
  final DateTime lastQuizDate;
  final Map<String, int> categoryStreaks;
  final Map<String, int> difficultyStreaks;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QuizStreak({
    required this.userId,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalQuizzesCompleted,
    required this.lastQuizDate,
    required this.categoryStreaks,
    required this.difficultyStreaks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuizStreak.fromJson(Map<String, dynamic> json) {
    return QuizStreak(
      userId: json['userId'],
      currentStreak: json['currentStreak'],
      longestStreak: json['longestStreak'],
      totalQuizzesCompleted: json['totalQuizzesCompleted'],
      lastQuizDate: DateTime.parse(json['lastQuizDate']),
      categoryStreaks: Map<String, int>.from(json['categoryStreaks']),
      difficultyStreaks: Map<String, int>.from(json['difficultyStreaks']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalQuizzesCompleted': totalQuizzesCompleted,
      'lastQuizDate': lastQuizDate.toIso8601String(),
      'categoryStreaks': categoryStreaks,
      'difficultyStreaks': difficultyStreaks,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  QuizStreak copyWith({
    String? userId,
    int? currentStreak,
    int? longestStreak,
    int? totalQuizzesCompleted,
    DateTime? lastQuizDate,
    Map<String, int>? categoryStreaks,
    Map<String, int>? difficultyStreaks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuizStreak(
      userId: userId ?? this.userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalQuizzesCompleted: totalQuizzesCompleted ?? this.totalQuizzesCompleted,
      lastQuizDate: lastQuizDate ?? this.lastQuizDate,
      categoryStreaks: categoryStreaks ?? this.categoryStreaks,
      difficultyStreaks: difficultyStreaks ?? this.difficultyStreaks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if user can continue streak today
  bool get canContinueStreak {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastQuiz = DateTime(lastQuizDate.year, lastQuizDate.month, lastQuizDate.day);
    
    // Can continue if last quiz was yesterday or today
    return lastQuiz.isAtSameMomentAs(today) || 
           lastQuiz.isAtSameMomentAs(today.subtract(const Duration(days: 1)));
  }

  // Check if streak is broken
  bool get isStreakBroken {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastQuiz = DateTime(lastQuizDate.year, lastQuizDate.month, lastQuizDate.day);
    
    // Streak is broken if last quiz was more than 1 day ago
    return lastQuiz.isBefore(today.subtract(const Duration(days: 1)));
  }

  // Get streak status message
  String get streakStatus {
    if (currentStreak == 0) return 'Start your streak today!';
    if (isStreakBroken) return 'Streak broken! Start a new one.';
    if (canContinueStreak) return 'Keep the streak going!';
    return 'Great job! Come back tomorrow to continue.';
  }
}
