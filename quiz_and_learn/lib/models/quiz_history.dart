import 'quiz_question.dart';

class QuizHistory {
  final String id;
  final String userId;
  final String category;
  final QuizDifficulty difficulty;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final double accuracy;
  final Duration timeTaken;
  final DateTime completedAt;
  final List<QuizAnswer> answers;
  final int pointsEarned;
  final bool isCompleted;

  const QuizHistory({
    required this.id,
    required this.userId,
    required this.category,
    required this.difficulty,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.accuracy,
    required this.timeTaken,
    required this.completedAt,
    required this.answers,
    required this.pointsEarned,
    required this.isCompleted,
  });

  factory QuizHistory.fromJson(Map<String, dynamic> json) {
    return QuizHistory(
      id: json['id'],
      userId: json['userId'],
      category: json['category'],
      difficulty: QuizDifficulty.values.firstWhere(
        (e) => e.toString().split('.').last == json['difficulty'],
      ),
      score: json['score'],
      totalQuestions: json['totalQuestions'],
      correctAnswers: json['correctAnswers'],
      accuracy: json['accuracy'].toDouble(),
      timeTaken: Duration(seconds: json['timeTakenSeconds']),
      completedAt: DateTime.parse(json['completedAt']),
      answers: (json['answers'] as List)
          .map((a) => QuizAnswer.fromJson(a))
          .toList(),
      pointsEarned: json['pointsEarned'],
      isCompleted: json['isCompleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'category': category,
      'difficulty': difficulty.toString().split('.').last,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'accuracy': accuracy,
      'timeTakenSeconds': timeTaken.inSeconds,
      'completedAt': completedAt.toIso8601String(),
      'answers': answers.map((a) => a.toJson()).toList(),
      'pointsEarned': pointsEarned,
      'isCompleted': isCompleted,
    };
  }

  QuizHistory copyWith({
    String? id,
    String? userId,
    String? category,
    QuizDifficulty? difficulty,
    int? score,
    int? totalQuestions,
    int? correctAnswers,
    double? accuracy,
    Duration? timeTaken,
    DateTime? completedAt,
    List<QuizAnswer>? answers,
    int? pointsEarned,
    bool? isCompleted,
  }) {
    return QuizHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      accuracy: accuracy ?? this.accuracy,
      timeTaken: timeTaken ?? this.timeTaken,
      completedAt: completedAt ?? this.completedAt,
      answers: answers ?? this.answers,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class QuizAnswer {
  final String questionId;
  final String question;
  final int selectedAnswer;
  final int correctAnswer;
  final bool isCorrect;
  final Duration timeSpent;
  final List<String> options;

  const QuizAnswer({
    required this.questionId,
    required this.question,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.timeSpent,
    required this.options,
  });

  factory QuizAnswer.fromJson(Map<String, dynamic> json) {
    return QuizAnswer(
      questionId: json['questionId'],
      question: json['question'],
      selectedAnswer: json['selectedAnswer'],
      correctAnswer: json['correctAnswer'],
      isCorrect: json['isCorrect'],
      timeSpent: Duration(seconds: json['timeSpentSeconds']),
      options: List<String>.from(json['options']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'question': question,
      'selectedAnswer': selectedAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
      'timeSpentSeconds': timeSpent.inSeconds,
      'options': options,
    };
  }
}
