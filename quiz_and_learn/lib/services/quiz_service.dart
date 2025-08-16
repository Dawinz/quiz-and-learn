import '../models/quiz_question.dart';
import 'admob_service.dart';
import 'ad_policy_compliance_service.dart';
import 'package:flutter/foundation.dart';

class QuizService {
  static final QuizService _instance = QuizService._internal();
  factory QuizService() => _instance;
  QuizService._internal() {
    _initializePolicyService();
  }

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

  // Get available question counts (simplified)
  Map<String, int> get availableQuestionCounts {
    return {
      'total': 0, // Will be populated from backend
      'easy': 0,
      'medium': 0,
      'hard': 0,
    };
  }

  // Start a new quiz session
  Future<void> startQuiz({
    required String category,
    required QuizDifficulty difficulty,
    required int questionCount,
  }) async {
    try {
      // Reset session state
      _currentQuestionIndex = 0;
      _score = 0;
      _totalPoints = 0;
      _startTime = DateTime.now();
      _endTime = null;

      // Create new session
      _currentSession = QuizSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: category,
        difficulty: difficulty,
        questionCount: questionCount,
        startTime: _startTime!,
        status: QuizSessionStatus.inProgress,
      );

      // For now, we'll use placeholder questions
      // In a real app, these would come from the backend
      _currentQuestions = _generatePlaceholderQuestions(questionCount, difficulty);

      print('✅ Quiz started: $category - $difficulty');
    } catch (e) {
      print('❌ Failed to start quiz: $e');
      rethrow;
    }
  }

  // Generate placeholder questions for testing
  List<QuizQuestion> _generatePlaceholderQuestions(int count, QuizDifficulty difficulty) {
    final questions = <QuizQuestion>[];
    
    for (int i = 0; i < count; i++) {
      questions.add(QuizQuestion(
        id: 'placeholder_$i',
        question: 'Sample question ${i + 1}?',
        options: ['Option A', 'Option B', 'Option C', 'Option D'],
        correctAnswer: 0,
        explanation: 'This is a placeholder question for testing.',
        difficulty: difficulty,
        category: QuizCategory.general,
        points: _getPointsForDifficulty(difficulty),
        tags: ['placeholder', 'test'],
      ));
    }
    
    return questions;
  }

  // Get points for difficulty level
  int _getPointsForDifficulty(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return 10;
      case QuizDifficulty.medium:
        return 20;
      case QuizDifficulty.hard:
        return 30;
      default:
        return 10;
    }
  }

  // Submit answer for current question
  Future<bool> submitAnswer(int selectedAnswer) async {
    if (currentQuestion == null) return false;

    try {
      final isCorrect = selectedAnswer == currentQuestion!.correctAnswer;
      
      if (isCorrect) {
        _score += currentQuestion!.points;
      }
      _totalPoints += currentQuestion!.points;

      // Move to next question
      _currentQuestionIndex++;

      // Check if quiz is complete
      if (_currentQuestionIndex >= _currentQuestions.length) {
        await _completeQuiz();
      }

      return isCorrect;
    } catch (e) {
      print('❌ Error submitting answer: $e');
      return false;
    }
  }

  // Complete the quiz
  Future<void> _completeQuiz() async {
    _endTime = DateTime.now();
    
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        status: QuizSessionStatus.completed,
        endTime: _endTime,
        score: _score,
        totalPoints: _totalPoints,
      );
    }

    print('✅ Quiz completed! Score: $_score/$_totalPoints');
  }

  // Get next question
  QuizQuestion? getNextQuestion() {
    if (_currentQuestionIndex >= _currentQuestions.length) {
      return null;
    }
    return _currentQuestions[_currentQuestionIndex];
  }

  // Check if quiz is complete
  bool get isQuizComplete {
    return _currentQuestionIndex >= _currentQuestions.length;
  }

  // Get quiz results
  Map<String, dynamic> getQuizResults() {
    if (!isQuizComplete) {
      return {
        'status': 'in_progress',
        'message': 'Quiz is still in progress',
      };
    }

    final accuracy = (_score / _totalPoints) * 100;
    final timeElapsed = this.timeElapsed?.inSeconds ?? 0;

    return {
      'status': 'completed',
      'score': _score,
      'totalPoints': _totalPoints,
      'accuracy': accuracy,
      'timeElapsed': timeElapsed,
      'startTime': _startTime?.toIso8601String(),
      'endTime': _endTime?.toIso8601String(),
      'category': _currentSession?.category,
      'difficulty': _currentSession?.difficulty.toString(),
    };
  }

  // Reset quiz session
  void resetQuiz() {
    _currentSession = null;
    _currentQuestions.clear();
    _currentQuestionIndex = 0;
    _score = 0;
    _totalPoints = 0;
    _startTime = null;
    _endTime = null;
  }

  // Get quiz history (simplified)
  List<QuizSession> getQuizHistory() {
    // In a real app, this would come from local storage or backend
    return [];
  }

  // Save quiz session (simplified)
  Future<void> saveQuizSession(QuizSession session) async {
    // In a real app, this would save to local storage or backend
    print('📝 Quiz session saved: ${session.id}');
  }

  // Get quiz statistics (simplified)
  Map<String, dynamic> getQuizStatistics() {
    return {
      'totalQuizzes': 0,
      'averageScore': 0.0,
      'bestScore': 0,
      'totalTime': 0,
      'categories': {},
      'difficulties': {},
    };
  }

  // Dispose resources
  void dispose() {
    resetQuiz();
  }
}

// Quiz Session class
class QuizSession {
  final String id;
  final String category;
  final QuizDifficulty difficulty;
  final int questionCount;
  final DateTime startTime;
  final DateTime? endTime;
  final QuizSessionStatus status;
  final int? score;
  final int? totalPoints;

  QuizSession({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.questionCount,
    required this.startTime,
    this.endTime,
    this.status = QuizSessionStatus.inProgress,
    this.score,
    this.totalPoints,
  });

  QuizSession copyWith({
    String? id,
    String? category,
    QuizDifficulty? difficulty,
    int? questionCount,
    DateTime? startTime,
    DateTime? endTime,
    QuizSessionStatus? status,
    int? score,
    int? totalPoints,
  }) {
    return QuizSession(
      id: id ?? this.id,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      questionCount: questionCount ?? this.questionCount,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      score: score ?? this.score,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'difficulty': difficulty.toString(),
      'questionCount': questionCount,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'status': status.toString(),
      'score': score,
      'totalPoints': totalPoints,
    };
  }

  factory QuizSession.fromMap(Map<String, dynamic> map) {
    return QuizSession(
      id: map['id'] ?? '',
      category: map['category'] ?? '',
      difficulty: QuizDifficulty.values.firstWhere(
        (e) => e.toString() == map['difficulty'],
        orElse: () => QuizDifficulty.easy,
      ),
      questionCount: map['questionCount'] ?? 0,
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      status: QuizSessionStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => QuizSessionStatus.inProgress,
      ),
      score: map['score'],
      totalPoints: map['totalPoints'],
    );
  }
}

// Quiz Session Status enum
enum QuizSessionStatus {
  notStarted,
  inProgress,
  completed,
  abandoned,
}
