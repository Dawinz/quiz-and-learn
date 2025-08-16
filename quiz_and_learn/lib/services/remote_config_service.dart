import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  late final Dio _dio;
  bool _isInitialized = false;
  Map<String, dynamic> _config = {};
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(seconds: 60);

  // Default configuration
  static const Map<String, dynamic> _defaultConfig = {
    'features': {
      'rewardsEnabled': true,
      'requireIntegrity': true,
    },
    'limits': {
      'dailyRewardCap': 100,
      'rewardCadenceSeconds': 60,
    },
    'risk': {
      'holdThreshold': 50,
      'blockThreshold': 100,
    },
  };

  bool get isInitialized => _isInitialized;
  Map<String, dynamic> get config => _config;
  DateTime? get lastFetchTime => _lastFetchTime;

  // Convenience getters
  Map<String, dynamic> get features => _config['features'] ?? _defaultConfig['features']!;
  Map<String, dynamic> get limits => _config['limits'] ?? _defaultConfig['limits']!;
  Map<String, dynamic> get risk => _config['risk'] ?? _defaultConfig['risk']!;

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load cached config
      await _loadCachedConfig();

      // Initialize Dio
      _dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

      // Fetch fresh config
      await fetchConfig();

      _isInitialized = true;
      debugPrint('RemoteConfigService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing RemoteConfigService: $e');
      // Use default config if initialization fails
      _config = Map.from(_defaultConfig);
      _isInitialized = true;
    }
  }

  /// Fetch configuration from server
  Future<void> fetchConfig() async {
    try {
      final apiBaseUrl = const String.fromEnvironment('API_BASE_URL');
      if (apiBaseUrl.isEmpty) {
        debugPrint('API_BASE_URL not defined, using default config');
        _config = Map.from(_defaultConfig);
        return;
      }

      final response = await _dio.get('$apiBaseUrl/v1/config');
      
      if (response.statusCode == 200) {
        _config = response.data;
        _lastFetchTime = DateTime.now();
        await _cacheConfig();
        debugPrint('Remote config fetched successfully');
      } else {
        debugPrint('Failed to fetch remote config: ${response.statusCode}');
        _config = Map.from(_defaultConfig);
      }
    } catch (e) {
      debugPrint('Error fetching remote config: $e');
      _config = Map.from(_defaultConfig);
    }
  }

  /// Get current configuration
  Map<String, dynamic> getCurrentConfig() {
    return Map.from(_config);
  }

  /// Check if config is stale and needs refresh
  bool get isConfigStale {
    if (_lastFetchTime == null) return true;
    return DateTime.now().difference(_lastFetchTime!) > _cacheDuration;
  }

  /// Refresh config if stale
  Future<void> refreshIfStale() async {
    if (isConfigStale) {
      await fetchConfig();
    }
  }

  /// Cache configuration to SharedPreferences
  Future<void> _cacheConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('remote_config', jsonEncode(_config));
      await prefs.setInt('remote_config_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Error caching remote config: $e');
    }
  }

  /// Load cached configuration from SharedPreferences
  Future<void> _loadCachedConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedConfig = prefs.getString('remote_config');
      final timestamp = prefs.getInt('remote_config_timestamp');

      if (cachedConfig != null && timestamp != null) {
        _config = jsonDecode(cachedConfig);
        _lastFetchTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        debugPrint('Loaded cached remote config');
      } else {
        _config = Map.from(_defaultConfig);
      }
    } catch (e) {
      debugPrint('Error loading cached config: $e');
      _config = Map.from(_defaultConfig);
    }
  }

  /// Clear cached configuration
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('remote_config');
      await prefs.remove('remote_config_timestamp');
      _config = Map.from(_defaultConfig);
      _lastFetchTime = null;
      debugPrint('Remote config cache cleared');
    } catch (e) {
      debugPrint('Error clearing remote config cache: $e');
    }
  }
}
