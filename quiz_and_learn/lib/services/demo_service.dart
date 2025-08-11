import 'dart:async';
import '../models/user_model.dart';

class DemoService {
  static const bool _isDemoMode = true;
  
  // Simulate network delay
  static Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  // Demo user data
  static final Map<String, dynamic> _demoUser = {
    "id": "demo_user_123",
    "name": "Demo User",
    "email": "demo@example.com",
    "totalCoins": 150,
    "roles": ["user"],
    "isActive": true,
    "lastLogin": DateTime.now().toIso8601String(),
    "emailVerified": true,
    "profilePicture": null,
    "phone": null,
    "referralCode": "DEMO123",
    "referralCount": 5,
    "referralEarnings": 50.0,
    "createdAt": DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
    "updatedAt": DateTime.now().toIso8601String(),
  };

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    await _simulateDelay();
    
    // Simulate validation
    if (email.isEmpty || password.isEmpty) {
      throw Exception("Email and password are required");
    }
    
    if (password.length < 6) {
      throw Exception("Password must be at least 6 characters");
    }

    // Simulate successful login
    return {
      "success": true,
      "data": {
        "token": "demo_token_${DateTime.now().millisecondsSinceEpoch}",
        "user": _demoUser,
      }
    };
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? referralCode,
  }) async {
    await _simulateDelay();
    
    // Simulate validation
    if (name.isEmpty) {
      throw Exception("Name is required");
    }
    
    if (email.isEmpty) {
      throw Exception("Email is required");
    }
    
    if (password.length < 6) {
      throw Exception("Password must be at least 6 characters");
    }

    // Simulate successful registration
    final newUser = Map<String, dynamic>.from(_demoUser);
    newUser["name"] = name;
    newUser["email"] = email;
    newUser["id"] = "demo_user_${DateTime.now().millisecondsSinceEpoch}";
    
    if (referralCode != null && referralCode.isNotEmpty) {
      newUser["totalCoins"] = 200; // Bonus coins for referral
    }

    return {
      "success": true,
      "data": {
        "token": "demo_token_${DateTime.now().millisecondsSinceEpoch}",
        "user": newUser,
      }
    };
  }

  static Future<Map<String, dynamic>> getProfile() async {
    await _simulateDelay();
    
    return {
      "success": true,
      "data": {
        "user": _demoUser,
      }
    };
  }

  static Future<bool> validateToken() async {
    await _simulateDelay();
    return true; // Demo mode always returns true
  }

  static Future<void> logout() async {
    await _simulateDelay();
    // Demo mode doesn't need to do anything
  }

  static Future<Map<String, dynamic>> getQuizzes({
    String? category,
    String? difficulty,
    int? page,
    int? limit,
  }) async {
    await _simulateDelay();
    
    // Demo quiz data
    final demoTests = [
      {
        "id": "quiz_1",
        "title": "General Knowledge Quiz",
        "description": "Test your general knowledge with this fun quiz!",
        "category": "General",
        "difficulty": "Easy",
        "questionCount": 10,
        "timeLimit": 300,
        "rewardCoins": 25,
      },
      {
        "id": "quiz_2",
        "title": "Science Quiz",
        "description": "Explore the world of science with this quiz!",
        "category": "Science",
        "difficulty": "Medium",
        "questionCount": 15,
        "timeLimit": 450,
        "rewardCoins": 35,
      },
      {
        "id": "quiz_3",
        "title": "History Quiz",
        "description": "Travel through time with this history quiz!",
        "category": "History",
        "difficulty": "Hard",
        "questionCount": 20,
        "timeLimit": 600,
        "rewardCoins": 50,
      },
    ];

    return {
      "success": true,
      "data": {
        "quizzes": demoTests,
        "total": demoTests.length,
        "page": page ?? 1,
        "limit": limit ?? 10,
      }
    };
  }

  static Future<Map<String, dynamic>> getQuizById(String quizId) async {
    await _simulateDelay();
    
    // Demo quiz questions
    final questions = [
      {
        "id": "q1",
        "question": "What is the capital of France?",
        "options": ["London", "Berlin", "Paris", "Madrid"],
        "correctAnswer": 2,
        "explanation": "Paris is the capital and largest city of France.",
      },
      {
        "id": "q2",
        "question": "Which planet is known as the Red Planet?",
        "options": ["Venus", "Mars", "Jupiter", "Saturn"],
        "correctAnswer": 1,
        "explanation": "Mars is called the Red Planet due to its reddish appearance.",
      },
      {
        "id": "q3",
        "question": "What is 2 + 2?",
        "options": ["3", "4", "5", "6"],
        "correctAnswer": 1,
        "explanation": "2 + 2 equals 4.",
      },
    ];

    return {
      "success": true,
      "data": {
        "quiz": {
          "id": quizId,
          "title": "Demo Quiz",
          "description": "This is a demo quiz for testing purposes.",
          "category": "Demo",
          "difficulty": "Easy",
          "questionCount": questions.length,
          "timeLimit": 300,
          "rewardCoins": 25,
          "questions": questions,
        }
      }
    };
  }

  static Future<Map<String, dynamic>> submitQuiz({
    required String quizId,
    required List<Map<String, dynamic>> answers,
  }) async {
    await _simulateDelay();
    
    // Simulate quiz scoring
    int correctAnswers = 0;
    int totalQuestions = answers.length;
    
    for (var answer in answers) {
      if (answer["selectedAnswer"] == answer["correctAnswer"]) {
        correctAnswers++;
      }
    }
    
    final score = (correctAnswers / totalQuestions * 100).round();
    final earnedCoins = (score / 100 * 25).round(); // Max 25 coins for perfect score
    
    return {
      "success": true,
      "data": {
        "score": score,
        "correctAnswers": correctAnswers,
        "totalQuestions": totalQuestions,
        "earnedCoins": earnedCoins,
        "message": "Great job! You've completed the quiz.",
      }
    };
  }

  static Future<Map<String, dynamic>> getWalletBalance() async {
    await _simulateDelay();
    
    return {
      "success": true,
      "data": {
        "balance": 150,
        "currency": "coins",
      }
    };
  }

  static Future<Map<String, dynamic>> getTransactions() async {
    await _simulateDelay();
    
    return {
      "success": true,
      "data": {
        "transactions": [
          {
            "id": "tx1",
            "type": "earned",
            "amount": 25,
            "description": "Quiz completion reward",
            "timestamp": DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
          },
          {
            "id": "tx2",
            "type": "earned",
            "amount": 10,
            "description": "Referral bonus",
            "timestamp": DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
          },
        ]
      }
    };
  }

  static Future<Map<String, dynamic>> getReferralStats() async {
    await _simulateDelay();
    
    return {
      "success": true,
      "data": {
        "referralCount": 5,
        "referralEarnings": 50.0,
        "referralCode": "DEMO123",
        "referralLink": "https://example.com/ref/DEMO123",
      }
    };
  }

  static Future<Map<String, dynamic>> getReferralLink() async {
    await _simulateDelay();
    
    return {
      "success": true,
      "data": {
        "referralCode": "DEMO123",
        "referralLink": "https://example.com/ref/DEMO123",
        "message": "Share this link with friends to earn bonus coins!",
      }
    };
  }

  static bool get isDemoMode => _isDemoMode;
}
