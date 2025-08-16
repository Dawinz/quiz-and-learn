import "package:dio/dio.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:flutter/foundation.dart";
import "demo_service.dart";

class ApiService {
  // Use config service for backend URL
  late String baseUrl;

  late Dio _dio;
  bool _useDemoMode = false; // Set to false to use real backend

  ApiService() {
    _initializeBaseUrl();
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _loadToken();
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        handler.next(options);
      },
      onError: (error, handler) {
        _handleError(error);
        handler.next(error);
      },
    ));
  }

  void _initializeBaseUrl() {
    baseUrl = "https://backend-o53691zww-dawson-s-projects.vercel.app/api";
  }

  Future<String?> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString("auth_token");
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("auth_token", token);
    } catch (e) {
      // Handle storage error
      debugPrint("Error saving token: $e");
    }
  }

  Future<void> _clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("auth_token");
    } catch (e) {
      // Handle storage error
      debugPrint("Error clearing token: $e");
    }
  }

  void _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      throw Exception(
          "Connection timeout. Please check your internet connection.");
    } else if (error.type == DioExceptionType.connectionError) {
      throw Exception("No internet connection. Please check your network.");
    } else if (error.response?.statusCode == 401) {
      _clearToken();
      throw Exception("Session expired. Please login again.");
    } else if (error.response?.statusCode == 403) {
      throw Exception("Access denied. Please check your permissions.");
    } else if (error.response?.statusCode == 404) {
      throw Exception("Resource not found.");
    } else if (error.response?.statusCode == 500) {
      throw Exception("Server error. Please try again later.");
    } else if (error.response?.statusCode == 0) {
      throw Exception(
          "Unable to connect to server. Please check your internet connection and try again.");
    } else {
      final errorMessage = error.response?.data?["message"] ??
          error.response?.data?["error"] ??
          "An error occurred. Please try again.";
      throw Exception(errorMessage);
    }
  }

  // Health check
  Future<Map<String, dynamic>> checkHealth() async {
    if (_useDemoMode) {
      return DemoService.getProfile(); // Use demo service for health check
    }

    try {
      final response = await _dio.get("/health");
      return response.data;
    } catch (e) {
      throw Exception("Failed to connect to server");
    }
  }

  // Authentication methods
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? referralCode,
  }) async {
    if (_useDemoMode) {
      return DemoService.register(
        name: name,
        email: email,
        password: password,
        referralCode: referralCode,
      );
    }

    try {
      final response = await _dio.post("/auth/register", data: {
        "name": name,
        "email": email,
        "password": password,
        if (referralCode != null && referralCode.isNotEmpty)
          "referralCode": referralCode,
      });

      if (response.data["success"]) {
        await _saveToken(response.data["data"]["token"]);
      }

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (_useDemoMode) {
      return DemoService.login(
        email: email,
        password: password,
      );
    }

    try {
      final response = await _dio.post("/auth/login", data: {
        "email": email,
        "password": password,
      });

      if (response.data["success"]) {
        await _saveToken(response.data["data"]["token"]);
      }

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    if (_useDemoMode) {
      return DemoService.logout();
    }

    try {
      await _dio.post("/auth/logout");
    } catch (e) {
      // Ignore logout errors
    } finally {
      await _clearToken();
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    if (_useDemoMode) {
      return DemoService.getProfile();
    }

    try {
      final response = await _dio.get("/auth/me");
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> validateToken() async {
    if (_useDemoMode) {
      return DemoService.validateToken();
    }

    try {
      final token = await _loadToken();
      if (token == null) return false;

      final response = await _dio.get("/auth/me");
      return response.data["success"] == true;
    } catch (e) {
      return false;
    }
  }

  // Quiz methods
  Future<Map<String, dynamic>> getQuizzes({
    String? category,
    String? difficulty,
    int? page,
    int? limit,
  }) async {
    if (_useDemoMode) {
      return DemoService.getQuizzes(
        category: category,
        difficulty: difficulty,
        page: page,
        limit: limit,
      );
    }

    try {
      final response = await _dio.get("/quizzes", queryParameters: {
        if (category != null) "category": category,
        if (difficulty != null) "difficulty": difficulty,
        if (page != null) "page": page,
        if (limit != null) "limit": limit,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getQuizById(String quizId) async {
    if (_useDemoMode) {
      return DemoService.getQuizById(quizId);
    }

    try {
      final response = await _dio.get("/quizzes/$quizId");
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitQuiz({
    required String quizId,
    required List<Map<String, dynamic>> answers,
  }) async {
    if (_useDemoMode) {
      return DemoService.submitQuiz(
        quizId: quizId,
        answers: answers,
      );
    }

    try {
      final response = await _dio.post("/quizzes/$quizId/submit", data: {
        "answers": answers,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Wallet methods
  Future<Map<String, dynamic>> getWalletBalance() async {
    if (_useDemoMode) {
      return DemoService.getWalletBalance();
    }

    try {
      final response = await _dio.get("/wallet/balance");
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTransactions() async {
    if (_useDemoMode) {
      return DemoService.getTransactions();
    }

    try {
      final response = await _dio.get("/wallet/transactions");
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Referral methods
  Future<Map<String, dynamic>> getReferralStats() async {
    if (_useDemoMode) {
      return DemoService.getReferralStats();
    }

    try {
      final response = await _dio.get("/referrals/stats");
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getReferralLink() async {
    if (_useDemoMode) {
      return DemoService.getReferralLink();
    }

    try {
      final response = await _dio.get("/referrals/link");
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Method to toggle demo mode
  void setDemoMode(bool enabled) {
    _useDemoMode = enabled;
  }

  bool get isDemoMode => _useDemoMode;
}
