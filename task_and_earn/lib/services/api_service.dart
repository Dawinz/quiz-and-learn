import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3001/api';
  late Dio _dio;
  String? _token;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          _clearToken();
        }
        handler.next(error);
      },
    ));

    _initialize();
  }

  Future<void> _initialize() async {
    await _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Auth methods
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? referralCode,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        if (referralCode != null) 'referralCode': referralCode,
      });
      return response.data;
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      if (response.data['success']) {
        await _saveToken(response.data['data']['token']);
      }
      
      return response.data;
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<void> logout() async {
    await _clearToken();
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/auth/me');
      return response.data;
    } catch (e) {
      return _handleError(e);
    }
  }

  // Task methods
  Future<Map<String, dynamic>> getTasks({
    String? category,
    String? type,
    String? difficulty,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (category != null) queryParams['category'] = category;
      if (type != null) queryParams['type'] = type;
      if (difficulty != null) queryParams['difficulty'] = difficulty;
      
      final response = await _dio.get('/tasks', queryParameters: queryParams);
      return response.data;
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getTaskById(String taskId) async {
    try {
      final response = await _dio.get('/tasks/$taskId');
      return response.data;
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> completeTask({
    required String taskId,
    int? rating,
    String? feedback,
  }) async {
    try {
      final response = await _dio.post('/tasks/$taskId/complete', data: {
        if (rating != null) 'rating': rating,
        if (feedback != null) 'feedback': feedback,
      });
      return response.data;
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getTaskProgress() async {
    try {
      final response = await _dio.get('/tasks/progress');
      return response.data;
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getTaskCategories() async {
    try {
      final response = await _dio.get('/tasks/categories');
      return response.data;
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getTaskTypes() async {
    try {
      final response = await _dio.get('/tasks/types');
      return response.data;
    } catch (e) {
      return _handleError(e);
    }
  }

  // Wallet methods
  Future<Map<String, dynamic>> getWalletBalance() async {
    try {
      final response = await _dio.get('/wallet/balance');
      return response.data;
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get('/wallet/transactions', queryParameters: {
        'page': page,
        'limit': limit,
      });
      return response.data;
    } catch (e) {
      return _handleError(e);
    }
  }

  // Referral methods
  Future<Map<String, dynamic>> getReferralStats() async {
    try {
      final response = await _dio.get('/referrals/stats');
      return response.data;
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getReferralLink() async {
    try {
      final response = await _dio.get('/referrals/link');
      return response.data;
    } catch (e) {
      return _handleError(e);
    }
  }

  // Utility methods
  Map<String, dynamic> _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        return error.response!.data;
      } else {
        return {
          'success': false,
          'error': 'Network error: ${error.message}',
        };
      }
    }
    return {
      'success': false,
      'error': 'Unknown error: $error',
    };
  }

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<bool> validateToken() async {
    try {
      if (_token == null) {
        await _loadToken();
      }
      
      if (_token == null || _token!.isEmpty) {
        return false;
      }

      final response = await _dio.get('/auth/me');
      return response.statusCode == 200;
    } catch (e) {
      await _clearToken();
      return false;
    }
  }
} 