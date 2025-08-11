import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3001/api';
  static const String healthUrl = 'http://localhost:3001/health';
  
  late Dio _dio;
  String? _token;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        handler.next(options);
      },
    ));

    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _token = token;
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
  }

  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get(healthUrl);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? referralCode,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
        if (referralCode != null) 'referralCode': referralCode,
      });

      if (response.data['success']) {
        await _saveToken(response.data['data']['token']);
      }

      return response.data;
    } catch (e) {
      if (e is DioException) {
        return {
          'success': false,
          'error': e.response?.data['error'] ?? 'Registration failed',
        };
      }
      return {'success': false, 'error': 'Network error'};
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
      if (e is DioException) {
        return {
          'success': false,
          'error': e.response?.data['error'] ?? 'Login failed',
        };
      }
      return {'success': false, 'error': 'Network error'};
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
      if (e is DioException) {
        return {
          'success': false,
          'error': e.response?.data['error'] ?? 'Failed to get profile',
        };
      }
      return {'success': false, 'error': 'Network error'};
    }
  }

  Future<Map<String, dynamic>> getWalletBalance() async {
    try {
      final response = await _dio.get('/wallet/balance');
      return response.data;
    } catch (e) {
      if (e is DioException) {
        return {
          'success': false,
          'error': e.response?.data['error'] ?? 'Failed to get wallet balance',
        };
      }
      return {'success': false, 'error': 'Network error'};
    }
  }

  Future<Map<String, dynamic>> playSpin() async {
    try {
      final response = await _dio.post('/spin/play');
      return response.data;
    } catch (e) {
      if (e is DioException) {
        return {
          'success': false,
          'error': e.response?.data['error'] ?? 'Failed to play spin',
        };
      }
      return {'success': false, 'error': 'Network error'};
    }
  }

  Future<Map<String, dynamic>> getSpinStatus() async {
    try {
      final response = await _dio.get('/spin/status');
      return response.data;
    } catch (e) {
      if (e is DioException) {
        return {
          'success': false,
          'error': e.response?.data['error'] ?? 'Failed to get spin status',
        };
      }
      return {'success': false, 'error': 'Network error'};
    }
  }

  bool get isAuthenticated => _token != null;
} 