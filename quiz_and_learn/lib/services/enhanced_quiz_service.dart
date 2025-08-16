import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/quiz_question.dart';

class EnhancedQuizService extends ChangeNotifier {
  static final EnhancedQuizService _instance = EnhancedQuizService._internal();
  factory EnhancedQuizService() => _instance;
  EnhancedQuizService._internal();

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
  List<Map<String, dynamic>> _currentAnswers = [];
  Map<String, dynamic> _sessionStats = {};

  // User data
  String? _currentUserId;

  // Getters
  QuizSession? get currentSession => _currentSession;
  QuizQuestion? get currentQuestion {
    if (_currentQuestions.isEmpty ||
        _currentQuestionIndex >= _currentQuestions.length) {
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

  // Set current user
  void setCurrentUser(String userId) {
    _currentUserId = userId;
    notifyListeners();
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
      // Get placeholder questions for now
      _currentQuestions =
          _generatePlaceholderQuestions(category, difficulty, questionCount);

      if (_currentQuestions.isEmpty) {
        throw Exception(
            'No questions available for the selected category and difficulty');
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

  // Generate placeholder questions
  List<QuizQuestion> _generatePlaceholderQuestions(
      QuizCategory category, QuizDifficulty difficulty, int count) {
    final questions = <QuizQuestion>[];

    for (int i = 0; i < count; i++) {
      questions.add(QuizQuestion(
        id: 'placeholder_${category.name}_${difficulty.name}_$i',
        question:
            'Sample question ${i + 1} for ${category.name} (${difficulty.name})?',
        options: ['Option A', 'Option B', 'Option C', 'Option D'],
        correctAnswer: 0,
        explanation: 'This is a placeholder question for testing purposes.',
        category: category,
        difficulty: difficulty,
        points: difficulty == QuizDifficulty.easy
            ? 10
            : difficulty == QuizDifficulty.medium
                ? 20
                : 30,
        tags: ['placeholder', category.name, difficulty.name],
      ));
    }

    return questions;
  }

  // Start quiz timer
  void _startQuizTimer() {
    _quizTimer?.cancel();
    _quizTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isTimerActive) {
        timer.cancel();
        return;
      }
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
      if (!_isTimerActive) {
        timer.cancel();
        return;
      }
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
  Future<void> submitAnswer(int selectedAnswer,
      {bool autoSubmit = false}) async {
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
    final answer = {
      'questionId': question.id,
      'question': question.question,
      'selectedAnswer': selectedAnswer,
      'correctAnswer': question.correctAnswer,
      'isCorrect': isCorrect,
      'timeSpent': timeSpent.inSeconds,
      'options': question.options,
    };
    _currentAnswers.add(answer);

    // Stop question timer
    _questionTimer?.cancel();

    // Update session stats
    _updateSessionStats();

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
      if (_currentSession?.questionTimeLimit != null &&
          _currentSession!.questionTimeLimit! > 0) {
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

    // Update session stats
    _updateSessionStats();

    notifyListeners();
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
  Map<String, dynamic> getResults() {
    return {
      'score': _score,
      'totalQuestions': _currentQuestions.length,
      'correctAnswers':
          _currentAnswers.where((a) => a['isCorrect'] == true).length,
      'accuracy': _totalPoints > 0 ? (_score / _totalPoints) * 100 : 0.0,
      'timeTaken': timeElapsed?.inSeconds ?? 0,
      'answers': _currentAnswers,
      'pointsEarned': _score,
    };
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

      if (_currentSession!.timeLimit != null &&
          _currentSession!.timeLimit! > 0 &&
          _quizTimeRemaining > 0) {
        _startQuizTimer();
      }

      if (_currentSession!.questionTimeLimit != null &&
          _currentSession!.questionTimeLimit! > 0 &&
          _questionTimeRemaining > 0) {
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
    _isTimerActive = false;
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
