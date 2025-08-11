import '../models/quiz_question.dart';
import 'quiz_database_service.dart';
import 'admob_service.dart';
import 'ad_policy_compliance_service.dart';
import 'package:flutter/foundation.dart';

class QuizService {
  static final QuizService _instance = QuizService._internal();
  factory QuizService() => _instance;
  QuizService._internal() {
    _initializePolicyService();
  }

  final QuizDatabaseService _databaseService = QuizDatabaseService();
  final AdMobService _adMobService = AdMobService.instance;
  final AdPolicyComplianceService _policyService =
      AdPolicyComplianceService.instance;

  QuizSession? _currentSession;
  List<QuizQuestion> _currentQuestions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _totalPoints = 0;
  DateTime? _startTime;
  DateTime? _endTime;

  // Initialize policy service
  void _initializePolicyService() {
    _policyService.initialize();
  }

  // Ad management - now handled by AdPolicyComplianceService

  // Get current session
  QuizSession? get currentSession => _currentSession;

  // Get current question
  QuizQuestion? get currentQuestion {
    if (_currentQuestions.isEmpty ||
        _currentQuestionIndex >= _currentQuestions.length) {
      return null;
    }
    return _currentQuestions[_currentQuestionIndex];
  }

  // Get progress
  double get progress {
    if (_currentQuestions.isEmpty) return 0.0;
    return (_currentQuestionIndex + 1) / _currentQuestions.length;
  }

  // Get score
  int get score => _score;
  int get totalPoints => _totalPoints;

  // Get time elapsed
  Duration? get timeElapsed {
    if (_startTime == null) return null;
    final endTime = _endTime ?? DateTime.now();
    return endTime.difference(_startTime!);
  }

  // Get current session statistics
  Map<String, dynamic> get sessionStats {
    if (_currentQuestions.isEmpty) {
      return {
        'currentQuestionIndex': 0,
        'totalQuestions': 0,
        'score': 0,
        'totalPoints': 0,
        'progress': 0.0,
        'timeElapsed': 0,
        'accuracy': 0.0,
      };
    }

    return {
      'currentQuestionIndex': _currentQuestionIndex,
      'totalQuestions': _currentQuestions.length,
      'score': _score,
      'totalPoints': _totalPoints,
      'progress': progress,
      'timeElapsed': timeElapsed?.inSeconds ?? 0,
      'accuracy': (_score / _totalPoints) * 100,
    };
  }

  // Get available question counts
  Map<String, int> get availableQuestionCounts {
    return {
      'total': _databaseService.getTotalQuestionCount(),
      'easy':
          _databaseService.getQuestionCountByDifficulty(QuizDifficulty.easy),
      'medium':
          _databaseService.getQuestionCountByDifficulty(QuizDifficulty.medium),
      'hard':
          _databaseService.getQuestionCountByDifficulty(QuizDifficulty.hard),
    };
  }

  // Start a new quiz session
  void startQuiz({
    required QuizCategory category,
    required QuizDifficulty difficulty,
    int questionCount = 10,
  }) {
    _currentQuestions = _databaseService.getQuestionsByCategoryAndDifficulty(
      category,
      difficulty,
      limit: questionCount,
    );

    if (_currentQuestions.isEmpty) {
      // Fallback: try to get questions by category only
      _currentQuestions = _databaseService.getQuestionsByCategory(
        category,
        limit: questionCount,
      );
    }

    if (_currentQuestions.isEmpty) {
      throw Exception(
          'No questions available for the selected category and difficulty');
    }

    _currentQuestionIndex = 0;
    _score = 0;
    _totalPoints = _currentQuestions.fold(0, (sum, q) => sum + q.points);
    _startTime = DateTime.now();
    _endTime = null;

    _currentSession = QuizSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: category,
      difficulty: difficulty,
      totalQuestions: _currentQuestions.length,
      startTime: _startTime!,
    );

    // Reset ad counters for new session
    _resetAdCounters();
  }

  // Start a mixed category quiz
  void startMixedQuiz({int questionCount = 15}) {
    _currentQuestions =
        _databaseService.getRandomQuestions(count: questionCount);

    if (_currentQuestions.isEmpty) {
      throw Exception('No questions available');
    }

    _currentQuestionIndex = 0;
    _score = 0;
    _totalPoints = _currentQuestions.fold(0, (sum, q) => sum + q.points);
    _startTime = DateTime.now();
    _endTime = null;

    _currentSession = QuizSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: QuizCategory.general, // Mixed category
      difficulty: QuizDifficulty.medium, // Mixed difficulty
      totalQuestions: _currentQuestions.length,
      startTime: _startTime!,
    );

    // Reset ad counters for new session
    _resetAdCounters();
  }

  // Start a difficulty-based quiz
  void startDifficultyQuiz({
    required QuizDifficulty difficulty,
    int questionCount = 15,
  }) {
    _currentQuestions = _databaseService.getQuestionsByDifficulty(
      difficulty,
      limit: questionCount,
    );

    if (_currentQuestions.isEmpty) {
      throw Exception('No questions available for the selected difficulty');
    }

    _currentQuestionIndex = 0;
    _score = 0;
    _totalPoints = _currentQuestions.fold(0, (sum, q) => sum + q.points);
    _startTime = DateTime.now();
    _endTime = null;

    _currentSession = QuizSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: QuizCategory.general, // Mixed category
      difficulty: difficulty,
      totalQuestions: _currentQuestions.length,
      startTime: _startTime!,
    );

    // Reset ad counters for new session
    _resetAdCounters();
  }

  // Start a tag-based quiz
  void startTagQuiz({
    required List<String> tags,
    int questionCount = 10,
  }) {
    _currentQuestions = _databaseService.getQuestionsByTags(
      tags,
      limit: questionCount,
    );

    if (_currentQuestions.isEmpty) {
      throw Exception('No questions available for the selected tags');
    }

    _currentQuestionIndex = 0;
    _score = 0;
    _totalPoints = _currentQuestions.fold(0, (sum, q) => sum + q.points);
    _startTime = DateTime.now();
    _endTime = null;

    _currentSession = QuizSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: QuizCategory.general, // Mixed category
      difficulty: QuizDifficulty.medium, // Mixed difficulty
      totalQuestions: _currentQuestions.length,
      startTime: _startTime!,
    );

    // Reset ad counters for new session
    _resetAdCounters();
  }

  // Submit an answer
  bool submitAnswer(int selectedOption) {
    if (currentQuestion == null) return false;

    final isCorrect = selectedOption == currentQuestion!.correctAnswer;

    if (isCorrect) {
      _score += currentQuestion!.points;
    }

    // Record the answer
    _currentSession?.addAnswer(
      questionId: currentQuestion!.id,
      selectedAnswer: selectedOption,
      isCorrect: isCorrect,
      points: isCorrect ? currentQuestion!.points : 0,
    );

    // Trigger ad after question completion
    triggerAdAfterQuestion();

    return isCorrect;
  }

  // Move to next question
  bool nextQuestion() {
    if (_currentQuestionIndex < _currentQuestions.length - 1) {
      _currentQuestionIndex++;
      return true;
    }
    return false;
  }

  // Move to previous question
  bool previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      return true;
    }
    return false;
  }

  // Check if quiz is complete
  bool get isQuizComplete {
    return _currentQuestionIndex >= _currentQuestions.length - 1;
  }

  // Get quiz results
  QuizResult getResults() {
    _endTime = DateTime.now();

    if (_currentSession == null) {
      throw Exception('No active quiz session');
    }

    final percentage = (_score / _totalPoints) * 100;
    final passed = percentage >= 60; // 60% passing score

    return QuizResult(
      sessionId: _currentSession!.id,
      score: _score,
      totalPoints: _totalPoints,
      percentage: percentage,
      passed: passed,
      totalQuestions: _currentQuestions.length,
      correctAnswers: _currentSession!.answers.where((a) => a.isCorrect).length,
      timeElapsed: timeElapsed ?? Duration.zero,
      startTime: _startTime!,
      endTime: _endTime!,
      category: _currentSession!.category,
      difficulty: _currentSession!.difficulty,
    );
  }

  // Reset quiz
  void resetQuiz() {
    _currentSession = null;
    _currentQuestions.clear();
    _currentQuestionIndex = 0;
    _score = 0;
    _totalPoints = 0;
    _startTime = null;
    _endTime = null;
  }

  // Get available categories
  List<QuizCategory> getAvailableCategories() {
    return _databaseService.getAvailableCategories();
  }

  // Get available difficulties
  List<QuizDifficulty> getAvailableDifficulties() {
    return _databaseService.getAvailableDifficulties();
  }

  // Get question count for category and difficulty
  int getQuestionCount(QuizCategory category, QuizDifficulty difficulty) {
    final questions = _databaseService.getQuestionsByCategoryAndDifficulty(
      category,
      difficulty,
      limit: 1000, // Get all questions to count them
    );
    return questions.length;
  }

  // Ad Management Methods

  /// Check if it's time to show an ad
  bool get shouldShowAd {
    return _policyService.canShowAnyAd() &&
        _policyService.shouldShowAdAfterQuestion();
  }

  /// Get the type of ad to show based on context
  AdType get recommendedAdType {
    final recommendedType = _policyService.getRecommendedAdType();
    switch (recommendedType) {
      case 'interstitial':
        return AdType.interstitial;
      case 'rewarded':
        return AdType.rewarded;
      case 'banner':
        return AdType.banner;
      case 'native':
        return AdType.native;
      default:
        return AdType.interstitial;
    }
  }

  /// Trigger ad display after question completion
  Future<void> triggerAdAfterQuestion() async {
    _policyService.incrementQuestionCount();

    if (shouldShowAd) {
      await _showAd();
    }
  }

  /// Show the appropriate ad type
  Future<void> _showAd() async {
    if (!_adMobService.isInitialized) {
      await _adMobService.initialize();
    }

    final adType = recommendedAdType;
    bool adShown = false;

    try {
      switch (adType) {
        case AdType.interstitial:
          adShown = await _adMobService.showInterstitialBetweenLevels();
          break;
        case AdType.rewarded:
          adShown = await _adMobService.showRewardedAdForCoins();
          break;
        case AdType.banner:
          // Banner ads are handled by UI, not triggered here
          break;
        case AdType.native:
          // Native ads are handled by UI, not triggered here
          break;
      }

      if (adShown) {
        // Record ad display in policy service
        switch (adType) {
          case AdType.interstitial:
            _policyService.recordInterstitialAdShown();
            break;
          case AdType.rewarded:
            _policyService.recordRewardedAdShown();
            break;
          case AdType.banner:
          case AdType.native:
            // These are handled by UI
            break;
        }
      }
    } catch (e) {
      debugPrint('Error showing ad: $e');
    }
  }

  /// Reset ad counters for new session
  void _resetAdCounters() {
    _policyService.resetCounters();
  }

  /// Get ad statistics for current session
  Map<String, dynamic> get adStats {
    final complianceStatus = _policyService.getComplianceStatus();
    return {
      'shouldShowAd': shouldShowAd,
      'recommendedAdType': recommendedAdType.toString(),
      'complianceStatus': complianceStatus,
      'policyWarnings': _policyService.getPolicyWarnings(),
      'isPolicyCompliant': _policyService.isPolicyCompliant(),
    };
  }
}

class QuizSession {
  final String id;
  final QuizCategory category;
  final QuizDifficulty difficulty;
  final int totalQuestions;
  final DateTime startTime;
  final List<QuizAnswer> answers = [];

  QuizSession({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.totalQuestions,
    required this.startTime,
  });

  void addAnswer({
    required String questionId,
    required int selectedAnswer,
    required bool isCorrect,
    required int points,
  }) {
    answers.add(QuizAnswer(
      questionId: questionId,
      selectedAnswer: selectedAnswer,
      isCorrect: isCorrect,
      points: points,
      timestamp: DateTime.now(),
    ));
  }
}

class QuizAnswer {
  final String questionId;
  final int selectedAnswer;
  final bool isCorrect;
  final int points;
  final DateTime timestamp;

  QuizAnswer({
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.points,
    required this.timestamp,
  });
}

class QuizResult {
  final String sessionId;
  final int score;
  final int totalPoints;
  final double percentage;
  final bool passed;
  final int totalQuestions;
  final int correctAnswers;
  final Duration timeElapsed;
  final DateTime startTime;
  final DateTime endTime;
  final QuizCategory category;
  final QuizDifficulty difficulty;

  QuizResult({
    required this.sessionId,
    required this.score,
    required this.totalPoints,
    required this.percentage,
    required this.passed,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeElapsed,
    required this.startTime,
    required this.endTime,
    required this.category,
    required this.difficulty,
  });

  String get grade {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }

  String get performanceMessage {
    if (percentage >= 90) return 'Excellent! Outstanding performance!';
    if (percentage >= 80) return 'Great job! Well done!';
    if (percentage >= 70) return 'Good work! Keep it up!';
    if (percentage >= 60) return 'Not bad! You passed!';
    if (percentage >= 50) return 'Almost there! Study a bit more.';
    return 'Keep studying! You can do better next time.';
  }
}

// Ad type enumeration
enum AdType {
  interstitial,
  rewarded,
  banner,
  native,
}
