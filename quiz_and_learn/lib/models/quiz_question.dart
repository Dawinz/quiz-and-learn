enum QuizDifficulty { easy, medium, hard }
enum QuizCategory { 
  general, 
  science, 
  history, 
  geography, 
  mathematics, 
  literature,
  technology,
  sports,
  entertainment,
  health,
  environment,
  economics,
  politics,
  art,
  music
}

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final QuizCategory category;
  final QuizDifficulty difficulty;
  final String explanation;
  final int points;
  final List<String> tags;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.category,
    required this.difficulty,
    required this.explanation,
    required this.points,
    required this.tags,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
      category: QuizCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
      ),
      difficulty: QuizDifficulty.values.firstWhere(
        (e) => e.toString().split('.').last == json['difficulty'],
      ),
      explanation: json['explanation'],
      points: json['points'],
      tags: List<String>.from(json['tags']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'category': category.toString().split('.').last,
      'difficulty': difficulty.toString().split('.').last,
      'explanation': explanation,
      'points': points,
      'tags': tags,
    };
  }
}

class QuizSet {
  final String id;
  final String title;
  final String description;
  final QuizCategory category;
  final QuizDifficulty difficulty;
  final List<QuizQuestion> questions;
  final int timeLimit; // in seconds, 0 for no limit
  final int passingScore; // percentage to pass

  const QuizSet({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.questions,
    this.timeLimit = 0,
    this.passingScore = 60,
  });

  int get totalPoints => questions.fold(0, (sum, q) => sum + q.points);
}
