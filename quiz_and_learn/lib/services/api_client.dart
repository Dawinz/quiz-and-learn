import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late final Dio _dio;
  bool _isInitialized = false;
  String? _authToken;
  String? _userId;

  bool get isInitialized => _isInitialized;

  /// Initialize the API client
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final apiBaseUrl = const String.fromEnvironment('API_BASE_URL');
      if (apiBaseUrl.isEmpty) {
        throw Exception('API_BASE_URL not defined');
      }

      _dio = Dio(BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

      // Add interceptors
      _dio.interceptors.addAll([
        _AuthInterceptor(this),
        _CacheInterceptor(),
        _RetryInterceptor(),
        _LoggingInterceptor(),
      ]);

      _isInitialized = true;
      debugPrint('ApiClient initialized successfully');
    } catch (e) {
      debugPrint('Error initializing ApiClient: $e');
      _isInitialized = true;
    }
  }

  /// Set authentication token
  void setAuthToken(String token, String userId) {
    _authToken = token;
    _userId = userId;
  }

  /// Clear authentication
  void clearAuth() {
    _authToken = null;
    _userId = null;
  }

  /// Check if authenticated
  bool get isAuthenticated => _authToken != null && _userId != null;

  /// Get current user ID
  String? get currentUserId => _userId;

  /// Make a GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool useCache = true,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          extra: {'useCache': useCache},
        ),
      );

      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Make a POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        options: Options(headers: headers),
      );

      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Make a PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        options: Options(headers: headers),
      );

      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Make a DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        options: Options(headers: headers),
      );

      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle API errors
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Request timeout');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data?['message'] ?? 'Server error';
          return Exception('HTTP $statusCode: $message');
        case DioExceptionType.cancel:
          return Exception('Request cancelled');
        case DioExceptionType.connectionError:
          return Exception('Network connection error');
        default:
          return Exception('Network error: ${error.message}');
      }
    }
    return Exception('Unexpected error: $error');
  }
}

/// Authentication interceptor
class _AuthInterceptor extends Interceptor {
  final ApiClient _apiClient;

  _AuthInterceptor(this._apiClient);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_apiClient.isAuthenticated) {
      options.headers['Authorization'] = 'Bearer ${_apiClient._authToken}';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token expired or invalid
      _apiClient.clearAuth();
    }
    handler.next(err);
  }
}

/// Cache interceptor with ETag support
class _CacheInterceptor extends Interceptor {
  static const String _cacheKey = 'api_cache';
  static const Duration _cacheDuration = Duration(minutes: 5);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.method == 'GET' && options.extra['useCache'] == true) {
      final cachedResponse = await _getCachedResponse(options.uri.toString());
      if (cachedResponse != null) {
        // Return cached response
        handler.resolve(Response(
          data: cachedResponse['data'],
          statusCode: 200,
          requestOptions: options,
          headers: Headers.fromMap({
            'X-Cache': ['HIT']
          }),
        ));
        return;
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response.requestOptions.method == 'GET' &&
        response.statusCode == 200 &&
        response.requestOptions.extra['useCache'] == true) {
      await _cacheResponse(
        response.requestOptions.uri.toString(),
        response.data,
        response.headers.map['etag']?.first,
      );
    }
    handler.next(response);
  }

  Future<Map<String, dynamic>?> _getCachedResponse(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cacheKey:${_hashUrl(url)}';
      final cached = prefs.getString(cacheKey);

      if (cached != null) {
        final cacheData = jsonDecode(cached);
        final timestamp = DateTime.parse(cacheData['timestamp']);

        if (DateTime.now().difference(timestamp) < _cacheDuration) {
          return cacheData['data'];
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting cached response: $e');
      return null;
    }
  }

  Future<void> _cacheResponse(String url, dynamic data, String? etag) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cacheKey:${_hashUrl(url)}';
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
        'etag': etag,
      };

      await prefs.setString(cacheKey, jsonEncode(cacheData));
    } catch (e) {
      debugPrint('Error caching response: $e');
    }
  }

  String _hashUrl(String url) {
    return url.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
  }
}

/// Retry interceptor with exponential backoff
class _RetryInterceptor extends Interceptor {
  static const List<Duration> _retryDelays = [
    Duration(seconds: 1),
    Duration(seconds: 3),
    Duration(seconds: 7),
  ];

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err) && err.requestOptions.extra['retryCount'] == null) {
      err.requestOptions.extra['retryCount'] = 0;
    }

    final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

    if (_shouldRetry(err) && retryCount < _retryDelays.length) {
      err.requestOptions.extra['retryCount'] = retryCount + 1;

      debugPrint('Retrying request (${retryCount + 1}/${_retryDelays.length})');

      await Future.delayed(_retryDelays[retryCount]);

      try {
        final response = await Dio().fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (retryError) {
        if (retryError is DioException) {
          handler.next(retryError);
        } else {
          handler.next(err);
        }
        return;
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        (error.type == DioExceptionType.badResponse &&
            error.response?.statusCode != null &&
            error.response!.statusCode! >= 500);
  }
}

/// Logging interceptor
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('API Request: ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
        'API Response: ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('API Error: ${err.type} ${err.requestOptions.uri}');
    handler.next(err);
  }
}
