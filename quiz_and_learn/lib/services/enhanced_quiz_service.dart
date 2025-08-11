import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/quiz_question.dart';
import '../models/quiz_history.dart';
import '../models/quiz_streak.dart';
import '../models/quiz_achievement.dart';
import 'quiz_database_service.dart';

class EnhancedQuizService extends ChangeNotifier {
  static final EnhancedQuizService _instance = EnhancedQuizService._internal();
  factory EnhancedQuizService() => _instance;
  EnhancedQuizService._internal();

  final QuizDatabaseService _databaseService = QuizDatabaseService();

  // Quiz session management
  QuizSession? _currentSession;
  List<QuizQuestion> _currentQuestions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _totalPoints = 0;
  DateTime? _startTime;
  DateTime? _endTime;
  DateTime? _questionStartTime;

  // Timer management
  Timer? _quizTimer;
  Timer? _questionTimer;
  int _quizTimeRemaining = 0; // Total quiz time remaining
  int _questionTimeRemaining = 0; // Current question time remaining
  bool _isTimerActive = false;

  // Progress tracking
  List<QuizAnswer> _currentAnswers = [];
  Map<String, dynamic> _sessionStats = {};

  // User data
  String? _currentUserId;
  QuizStreak? _userStreak;
  List<QuizAchievement> _userAchievements = [];

  // Getters
  QuizSession? get currentSession => _currentSession;
  QuizQuestion? get currentQuestion {
    if (_currentQuestions.isEmpty || _currentQuestionIndex >= _currentQuestions.length) {
      return null;
    }
    return _currentQuestions[_currentQuestionIndex];
  }
  
  double get progress {
    if (_currentQuestions.isEmpty) return 0.0;
    return (_currentQuestionIndex + 1) / _currentQuestions.length;
  }
  
  int get score => _score;
  int get totalPoints => _totalPoints;
  int get quizTimeRemaining => _quizTimeRemaining;
  int get questionTimeRemaining => _questionTimeRemaining;
  bool get isTimerActive => _isTimerActive;
  
  Duration? get timeElapsed {
    if (_startTime == null) return null;
    final endTime = _endTime ?? DateTime.now();
    return endTime.difference(_startTime!);
  }

  Duration? get currentQuestionTime {
    if (_questionStartTime == null) return null;
    return DateTime.now().difference(_questionStartTime!);
  }

  Map<String, dynamic> get sessionStats => _sessionStats;
  QuizStreak? get userStreak => _userStreak;
  List<QuizAchievement> get userAchievements => _userAchievements;

  // Set current user
  void setCurrentUser(String userId) {
    _currentUserId = userId;
    _loadUserData();
  }

  // Load user data
  Future<void> _loadUserData() async {
    if (_currentUserId == null) return;
    
    try {
      // TODO: Implement when database methods are available
      // _userStreak = await _databaseService.getUserStreak(_currentUserId!);
      // _userAchievements = await _databaseService.getUserAchievements(_currentUserId!);
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user data: $e');
      }
    }
  }

  // Start quiz with timer
  Future<void> startQuiz({
    required QuizCategory category,
    required QuizDifficulty difficulty,
    int questionCount = 10,
    int timeLimit = 0, // 0 for no limit
    int questionTimeLimit = 0, // 0 for no limit
  }) async {
    try {
      // Get questions from database
      _currentQuestions = _databaseService.getQuestionsByCategoryAndDifficulty(
        category,
        difficulty,
        limit: questionCount,
      );

      if (_currentQuestions.isEmpty) {
        throw Exception('No questions available for the selected category and difficulty');
      }

      // Initialize quiz session
      _currentSession = QuizSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: category,
        difficulty: difficulty,
        startTime: DateTime.now(),
        questionCount: questionCount,
        timeLimit: timeLimit,
        questionTimeLimit: questionTimeLimit,
      );

      // Reset quiz state
      _currentQuestionIndex = 0;
      _score = 0;
      _totalPoints = 0;
      _startTime = DateTime.now();
      _endTime = null;
      _currentAnswers = [];

      // Set up timers
      if (timeLimit > 0) {
        _quizTimeRemaining = timeLimit;
        _startQuizTimer();
      }

      if (questionTimeLimit > 0) {
        _questionTimeRemaining = questionTimeLimit;
        _startQuestionTimer();
      }

      _isTimerActive = true;
      _updateSessionStats();
      notifyListeners();

    } catch (e) {
      if (kDebugMode) {
        print('Error starting quiz: $e');
      }
      rethrow;
    }
  }

  // Start quiz timer
  void _startQuizTimer() {
    _quizTimer?.cancel();
    _quizTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_quizTimeRemaining > 0) {
        _quizTimeRemaining--;
        notifyListeners();
      } else {
        _endQuiz();
        timer.cancel();
      }
    });
  }

  // Start question timer
  void _startQuestionTimer() {
    _questionTimer?.cancel();
    _questionStartTime = DateTime.now();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_questionTimeRemaining > 0) {
        _questionTimeRemaining--;
        notifyListeners();
      } else {
        // Time's up for current question
        _handleTimeUp();
        timer.cancel();
      }
    });
  }

  // Handle time up for question
  void _handleTimeUp() {
    if (currentQuestion != null) {
      // Auto-submit wrong answer (time penalty)
      submitAnswer(-1, autoSubmit: true);
    }
  }

  // Submit answer
  Future<void> submitAnswer(int selectedAnswer, {bool autoSubmit = false}) async {
    if (currentQuestion == null) return;

    final question = currentQuestion!;
    final isCorrect = selectedAnswer == question.correctAnswer;
    final timeSpent = currentQuestionTime ?? Duration.zero;

    // Calculate points (with time penalty for auto-submit)
    int pointsEarned = isCorrect ? question.points : 0;
    if (autoSubmit) {
      pointsEarned = 0; // No points for time-up
    }

    // Update score
    if (isCorrect) {
      _score += pointsEarned;
    }
    _totalPoints += question.points;

    // Record answer
    final answer = QuizAnswer(
      questionId: question.id,
      question: question.question,
      selectedAnswer: selectedAnswer,
      correctAnswer: question.correctAnswer,
      isCorrect: isCorrect,
      timeSpent: timeSpent,
      options: question.options,
    );
    _currentAnswers.add(answer);

    // Stop question timer
    _questionTimer?.cancel();

    // Update session stats
    _updateSessionStats();

    // Check for achievements
    await _checkAchievements();

    notifyListeners();

    // Wait before moving to next question
    await Future.delayed(const Duration(seconds: 2));
    
    if (_currentQuestionIndex < _currentQuestions.length - 1) {
      nextQuestion();
    } else {
      _endQuiz();
    }
  }

  // Move to next question
  bool nextQuestion() {
    if (_currentQuestionIndex < _currentQuestions.length - 1) {
      _currentQuestionIndex++;
      
      // Reset question timer if enabled
      if (_currentSession?.questionTimeLimit != null && _currentSession!.questionTimeLimit! > 0) {
        _questionTimeRemaining = _currentSession!.questionTimeLimit!;
        _startQuestionTimer();
      }
      
      _updateSessionStats();
      notifyListeners();
      return true;
    }
    return false;
  }

  // End quiz
  Future<void> _endQuiz() async {
    _isTimerActive = false;
    _quizTimer?.cancel();
    _questionTimer?.cancel();
    _endTime = DateTime.now();

    // Save quiz history
    if (_currentUserId != null) {
      await _saveQuizHistory();
    }

    // Update user streak
    await _updateUserStreak();

    // Check for new achievements
    await _checkAchievements();

    notifyListeners();
  }

  // Save quiz history
  Future<void> _saveQuizHistory() async {
    if (_currentUserId == null || _currentSession == null) return;

    final history = QuizHistory(
      id: _currentSession!.id,
      userId: _currentUserId!,
      category: _currentSession!.category.toString().split('.').last,
      difficulty: _currentSession!.difficulty,
      score: _score,
      totalQuestions: _currentQuestions.length,
      correctAnswers: _currentAnswers.where((a) => a.isCorrect).length,
      accuracy: (_score / _totalPoints) * 100,
      timeTaken: timeElapsed ?? Duration.zero,
      completedAt: DateTime.now(),
      answers: _currentAnswers,
      pointsEarned: _score,
      isCompleted: true,
    );

    // TODO: Implement when database methods are available
    // await _databaseService.saveQuizHistory(history);
  }

  // Update user streak
  Future<void> _updateUserStreak() async {
    if (_currentUserId == null) return;

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (_userStreak == null) {
        // Create new streak
        _userStreak = QuizStreak(
          userId: _currentUserId!,
          currentStreak: 1,
          longestStreak: 1,
          totalQuizzesCompleted: 1,
          lastQuizDate: today,
          categoryStreaks: {},
          difficultyStreaks: {},
          createdAt: now,
          updatedAt: now,
        );
      } else {
        // Update existing streak
        final lastQuiz = DateTime(
          _userStreak!.lastQuizDate.year,
          _userStreak!.lastQuizDate.month,
          _userStreak!.lastQuizDate.day,
        );

        if (lastQuiz.isAtSameMomentAs(today)) {
          // Already completed a quiz today
          _userStreak = _userStreak!.copyWith(
            totalQuizzesCompleted: _userStreak!.totalQuizzesCompleted + 1,
            updatedAt: now,
          );
        } else if (lastQuiz.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
          // Continue streak
          final newStreak = _userStreak!.currentStreak + 1;
          _userStreak = _userStreak!.copyWith(
            currentStreak: newStreak,
            longestStreak: newStreak > _userStreak!.longestStreak ? newStreak : _userStreak!.longestStreak,
            totalQuizzesCompleted: _userStreak!.totalQuizzesCompleted + 1,
            lastQuizDate: today,
            updatedAt: now,
          );
        } else {
          // Break streak
          _userStreak = _userStreak!.copyWith(
            currentStreak: 1,
            totalQuizzesCompleted: _userStreak!.totalQuizzesCompleted + 1,
            lastQuizDate: today,
            updatedAt: now,
          );
        }
      }

      // TODO: Implement when database methods are available
      // await _databaseService.saveUserStreak(_userStreak!);
      notifyListeners();

    } catch (e) {
      if (kDebugMode) {
        print('Error updating user streak: $e');
      }
    }
  }

  // Check for achievements
  Future<void> _checkAchievements() async {
    if (_currentUserId == null) return;

    try {
      final newAchievements = <QuizAchievement>[];

      for (final achievement in QuizAchievements.all) {
        if (achievement.isUnlocked) continue;

        bool shouldUnlock = false;
        int currentValue = 0;

        switch (achievement.type) {
          case AchievementType.streak:
            if (_userStreak != null) {
              currentValue = _userStreak!.currentStreak;
              shouldUnlock = achievement.canUnlock(currentValue);
            }
            break;

          case AchievementType.score:
            // TODO: Implement when database methods are available
            currentValue = _score;
            shouldUnlock = achievement.canUnlock(currentValue);
            break;

          case AchievementType.category:
            // TODO: Implement when database methods are available
            currentValue = 1; // Placeholder
            shouldUnlock = achievement.canUnlock(currentValue);
            break;

          case AchievementType.difficulty:
            // TODO: Implement when database methods are available
            currentValue = 1; // Placeholder
            shouldUnlock = achievement.canUnlock(currentValue);
            break;

          case AchievementType.speed:
            // Check current question time
            if (currentQuestionTime != null) {
              currentValue = currentQuestionTime!.inSeconds;
              shouldUnlock = achievement.canUnlock(currentValue);
            }
            break;

          case AchievementType.accuracy:
            // Check current quiz accuracy
            if (_totalPoints > 0) {
              currentValue = ((_score / _totalPoints) * 100).round();
              shouldUnlock = achievement.canUnlock(currentValue);
            }
            break;

          case AchievementType.special:
            // Handle special achievements
            if (achievement.id == 'first_quiz') {
              currentValue = 1; // Placeholder
              shouldUnlock = achievement.canUnlock(currentValue);
            } else if (achievement.id == 'quiz_master') {
              currentValue = 1; // Placeholder
              shouldUnlock = achievement.canUnlock(currentValue);
            }
            break;
        }

        if (shouldUnlock) {
          final unlockedAchievement = achievement.copyWith(
            isUnlocked: true,
            unlockedAt: DateTime.now(),
          );
          newAchievements.add(unlockedAchievement);
          
          // Add to user achievements
          _userAchievements.add(unlockedAchievement);
          
          // TODO: Implement when database methods are available
          // await _databaseService.saveUserAchievement(_currentUserId!, unlockedAchievement);
        }
      }

      if (newAchievements.isNotEmpty) {
        notifyListeners();
        // You can show achievement notifications here
      }

    } catch (e) {
      if (kDebugMode) {
        print('Error checking achievements: $e');
      }
    }
  }

  // Update session stats
  void _updateSessionStats() {
    _sessionStats = {
      'currentQuestionIndex': _currentQuestionIndex,
      'totalQuestions': _currentQuestions.length,
      'score': _score,
      'totalPoints': _totalPoints,
      'progress': progress,
      'timeElapsed': timeElapsed?.inSeconds ?? 0,
      'accuracy': _totalPoints > 0 ? (_score / _totalPoints) * 100 : 0.0,
      'quizTimeRemaining': _quizTimeRemaining,
      'questionTimeRemaining': _questionTimeRemaining,
      'isTimerActive': _isTimerActive,
    };
  }

  // Get quiz results
  QuizResults getResults() {
    return QuizResults(
      score: _score,
      totalQuestions: _currentQuestions.length,
      correctAnswers: _currentAnswers.where((a) => a.isCorrect).length,
      accuracy: _totalPoints > 0 ? (_score / _totalPoints) * 100 : 0.0,
      timeTaken: timeElapsed ?? Duration.zero,
      answers: _currentAnswers,
      pointsEarned: _score,
    );
  }

  // Pause quiz
  void pauseQuiz() {
    _isTimerActive = false;
    _quizTimer?.cancel();
    _questionTimer?.cancel();
    notifyListeners();
  }

  // Resume quiz
  void resumeQuiz() {
    if (_currentSession != null) {
      _isTimerActive = true;
      
      if (_currentSession!.timeLimit != null && _currentSession!.timeLimit! > 0 && _quizTimeRemaining > 0) {
        _startQuizTimer();
      }
      
      if (_currentSession!.questionTimeLimit != null && _currentSession!.questionTimeLimit! > 0 && _questionTimeRemaining > 0) {
        _startQuestionTimer();
      }
      
      notifyListeners();
    }
  }

  // Reset quiz
  void resetQuiz() {
    _quizTimer?.cancel();
    _questionTimer?.cancel();
    _isTimerActive = false;
    _currentQuestions.clear();
    _currentQuestionIndex = 0;
    _score = 0;
    _totalPoints = 0;
    _startTime = null;
    _endTime = null;
    _currentAnswers.clear();
    _quizTimeRemaining = 0;
    _questionTimeRemaining = 0;
    _currentSession = null;
    _sessionStats.clear();
    notifyListeners();
  }

  // Dispose
  @override
  void dispose() {
    _quizTimer?.cancel();
    _questionTimer?.cancel();
    super.dispose();
  }
}

// Quiz session class
class QuizSession {
  final String id;
  final QuizCategory category;
  final QuizDifficulty difficulty;
  final DateTime startTime;
  final int questionCount;
  final int? timeLimit; // Total quiz time limit
  final int? questionTimeLimit; // Individual question time limit

  const QuizSession({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.startTime,
    required this.questionCount,
    this.timeLimit,
    this.questionTimeLimit,
  });
}

// Quiz results class
class QuizResults {
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final double accuracy;
  final Duration timeTaken;
  final List<QuizAnswer> answers;
  final int pointsEarned;

  const QuizResults({
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.accuracy,
    required this.timeTaken,
    required this.answers,
    required this.pointsEarned,
  });
}
