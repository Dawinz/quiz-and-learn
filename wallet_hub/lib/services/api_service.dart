import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'connectivity_service.dart';

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
      // Check internet connection first
      final hasInternet = await ConnectivityService.checkInternetConnection();
      if (!hasInternet) {
        return {'success': false, 'error': 'No internet connection'};
      }

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
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          return {
            'success': false,
            'error': 'Connection timeout. Please try again.'
          };
        }
        if (e.type == DioExceptionType.connectionError) {
          return {'success': false, 'error': 'No internet connection'};
        }
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

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      // Check internet connection first
      final hasInternet = await ConnectivityService.checkInternetConnection();
      if (!hasInternet) {
        return {'success': false, 'error': 'No internet connection'};
      }

      final response = await _dio.put('/auth/me', data: {
        'name': name,
        'email': email,
      });
      return response.data;
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          return {
            'success': false,
            'error': 'Connection timeout. Please try again.'
          };
        }
        if (e.type == DioExceptionType.connectionError) {
          return {'success': false, 'error': 'No internet connection'};
        }
        return {
          'success': false,
          'error': e.response?.data['error'] ?? 'Failed to update profile',
        };
      }
      return {'success': false, 'error': 'Network error'};
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Check internet connection first
      final hasInternet = await ConnectivityService.checkInternetConnection();
      if (!hasInternet) {
        return {'success': false, 'error': 'No internet connection'};
      }

      final response = await _dio.put('/auth/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      return response.data;
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          return {
            'success': false,
            'error': 'Connection timeout. Please try again.'
          };
        }
        if (e.type == DioExceptionType.connectionError) {
          return {'success': false, 'error': 'No internet connection'};
        }
        return {
          'success': false,
          'error': e.response?.data['error'] ?? 'Failed to change password',
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

  Future<Map<String, dynamic>> getTransactions({
    int page = 1,
    int limit = 20,
    String? type,
    String? source,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (type != null) 'type': type,
        if (source != null) 'source': source,
      };

      final response =
          await _dio.get('/wallet/transactions', queryParameters: queryParams);
      return response.data;
    } catch (e) {
      if (e is DioException) {
        return {
          'success': false,
          'error': e.response?.data['error'] ?? 'Failed to get transactions',
        };
      }
      return {'success': false, 'error': 'Network error'};
    }
  }

  Future<Map<String, dynamic>> requestWithdrawal({
    required double amount,
    required String method,
    required String accountDetails,
  }) async {
    try {
      final response = await _dio.post('/wallet/withdraw', data: {
        'amount': amount,
        'method': method,
        'accountDetails': accountDetails,
      });
      return response.data;
    } catch (e) {
      if (e is DioException) {
        return {
          'success': false,
          'error': e.response?.data['error'] ?? 'Failed to request withdrawal',
        };
      }
      return {'success': false, 'error': 'Network error'};
    }
  }

  Future<Map<String, dynamic>> getWithdrawals({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get('/wallet/withdrawals', queryParameters: {
        'page': page,
        'limit': limit,
      });
      return response.data;
    } catch (e) {
      if (e is DioException) {
        return {
          'success': false,
          'error': e.response?.data['error'] ?? 'Failed to get withdrawals',
        };
      }
      return {'success': false, 'error': 'Network error'};
    }
  }

  Future<Map<String, dynamic>> updateGoals({
    required Map<String, dynamic> goals,
  }) async {
    try {
      final response = await _dio.put('/wallet/goals', data: {
        'goals': goals,
      });
      return response.data;
    } catch (e) {
      if (e is DioException) {
        return {
          'success': false,
          'error': e.response?.data['error'] ?? 'Failed to update goals',
        };
      }
      return {'success': false, 'error': 'Network error'};
    }
  }

  Future<Map<String, dynamic>> getReferralStats() async {
    try {
      final response = await _dio.get('/referrals/stats');
      return response.data;
    } catch (e) {
      if (e is DioException) {
        return {
          'success': false,
          'error': e.response?.data['error'] ?? 'Failed to get referral stats',
        };
      }
      return {'success': false, 'error': 'Network error'};
    }
  }

  Future<Map<String, dynamic>> getReferralLink() async {
    try {
      final response = await _dio.get('/referrals/link');
      return response.data;
    } catch (e) {
      if (e is DioException) {
        return {
          'success': false,
          'error': e.response?.data['error'] ?? 'Failed to get referral link',
        };
      }
      return {'success': false, 'error': 'Network error'};
    }
  }

  bool get isAuthenticated {
    return _token != null && _token!.isNotEmpty;
  }

  Future<bool> get isAuthenticatedAsync async {
    if (_token == null) {
      await _loadToken();
    }
    return _token != null && _token!.isNotEmpty;
  }

  Future<bool> validateToken() async {
    try {
      if (_token == null) {
        await _loadToken();
      }

      if (_token == null || _token!.isEmpty) {
        return false;
      }

      // Test the token with the backend
      final response = await _dio.get('/auth/me');
      return response.statusCode == 200;
    } catch (e) {
      // If token is invalid, clear it
      await _clearToken();
      return false;
    }
  }
}
