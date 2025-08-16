import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/user_preferences.dart';

class BackendService {
  static final BackendService _instance = BackendService._internal();
  factory BackendService() => _instance;
  BackendService._internal();

  late final Dio _dio;
  String? _authToken;
  String? _userId;
  bool _isInitialized = false;

  // API Configuration
  static const String _baseUrl =
      'https://api.quizandlearn.com'; // Replace with your actual API URL
  static const String _apiVersion = '/v1';
  static const Duration _timeout = Duration(seconds: 30);

  // API Endpoints
  static const String _authEndpoint = '/auth';
  static const String _userEndpoint = '/user';
  static const String _preferencesEndpoint = '/preferences';
  static const String _analyticsEndpoint = '/analytics';
  static const String _notificationsEndpoint = '/notifications';

  // Getter for base URL
  String get baseUrl => _baseUrl + _apiVersion;

  // Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
      sendTimeout: _timeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors for authentication and error handling
    _dio.interceptors.addAll([
      _AuthInterceptor(this),
      _ErrorInterceptor(),
      _LoggingInterceptor(),
    ]);

    _isInitialized = true;
  }

  // Set authentication token
  void setAuthToken(String token, String userId) {
    _authToken = token;
    _userId = userId;
  }

  // Clear authentication
  void clearAuth() {
    _authToken = null;
    _userId = null;
  }

  // Check if authenticated
  bool get isAuthenticated => _authToken != null && _userId != null;

  // Get current user ID
  String? get currentUserId => _userId;

  // Authentication Methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('$_authEndpoint/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data;
      if (data['success'] == true) {
        setAuthToken(data['token'], data['user']['id']);
        return data;
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final response = await _dio.post('$_authEndpoint/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      final data = response.data;
      if (data['success'] == true) {
        setAuthToken(data['token'], data['user']['id']);
        return data;
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      if (isAuthenticated) {
        await _dio.post('$_authEndpoint/logout');
      }
    } catch (e) {
      // Log error but don't throw
      print('Logout error: $e');
    } finally {
      clearAuth();
    }
  }

  // User Preferences Methods
  Future<UserPreferences> getUserPreferences() async {
    try {
      final response = await _dio.get('$_preferencesEndpoint/$_userId');
      final data = response.data;

      if (data['success'] == true) {
        return UserPreferences.fromMap(data['preferences']);
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch preferences');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Update user preferences
  Future<void> updateUserPreferences(UserPreferences preferences) async {
    try {
      final response = await _dio.put('$_preferencesEndpoint/$_userId', data: preferences.toMap());

      final data = response.data;
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to update preferences');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception(
              'Connection timeout. Please check your internet connection.');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            clearAuth();
            return Exception('Authentication expired. Please login again.');
          } else if (statusCode == 403) {
            return Exception(
                'Access denied. You don\'t have permission for this action.');
          } else if (statusCode == 404) {
            return Exception('Resource not found.');
          } else if (statusCode == 500) {
            return Exception('Server error. Please try again later.');
          } else {
            return Exception('Request failed with status code: $statusCode');
          }
        case DioExceptionType.cancel:
          return Exception('Request was cancelled.');
        case DioExceptionType.connectionError:
          return Exception(
              'No internet connection. Please check your network.');
        default:
          return Exception('Network error: ${error.message}');
      }
    } else if (error is Exception) {
      return error;
    } else {
      return Exception('Unknown error: $error');
    }
  }

  // Health check
  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get connection status
  Future<Map<String, dynamic>> getConnectionStatus() async {
    try {
      final isHealthy = await healthCheck();
      return {
        'connected': isHealthy,
        'baseUrl': baseUrl,
        'authenticated': isAuthenticated,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'connected': false,
        'baseUrl': baseUrl,
        'authenticated': isAuthenticated,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}

// Interceptors
class _AuthInterceptor extends Interceptor {
  final BackendService _service;

  _AuthInterceptor(this._service);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_service.isAuthenticated) {
      options.headers['Authorization'] = 'Bearer ${_service._authToken}';
    }
    handler.next(options);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle specific error cases
    if (err.response?.statusCode == 401) {
      // Token expired, clear auth
      // This will be handled by the main error handler
    }
    handler.next(err);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🌐 API Request: ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        '✅ API Response: ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ API Error: ${err.type} ${err.message}');
    handler.next(err);
  }
}

