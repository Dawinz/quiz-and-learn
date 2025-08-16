import 'package:flutter/foundation.dart';

enum Flavor {
  dev,
  prod,
}

class FlavorConfig {
  static final FlavorConfig _instance = FlavorConfig._internal();
  factory FlavorConfig() => _instance;
  FlavorConfig._internal();

  late final Flavor _flavor;
  late final String _apiBaseUrl;
  late final bool _allowEmulator;
  late final bool _enableRewards;
  late final bool _requireIntegrity;

  Flavor get flavor => _flavor;
  String get apiBaseUrl => _apiBaseUrl;
  bool get allowEmulator => _allowEmulator;
  bool get enableRewards => _enableRewards;
  bool get requireIntegrity => _requireIntegrity;

  /// Initialize flavor configuration
  void initialize() {
    // Determine flavor from build configuration
    if (kDebugMode) {
      _flavor = Flavor.dev;
    } else {
      _flavor = Flavor.prod;
    }

    // Set configuration based on flavor
    switch (_flavor) {
      case Flavor.dev:
        _apiBaseUrl = const String.fromEnvironment('API_BASE_URL',
            defaultValue: 'https://dev-api.quizandlearn.com');
        _allowEmulator = true;
        _enableRewards = false; // Disabled by default in dev
        _requireIntegrity = false; // Relaxed in dev
        break;
      case Flavor.prod:
        _apiBaseUrl = const String.fromEnvironment('API_BASE_URL',
            defaultValue: 'https://api.quizandlearn.com');
        _allowEmulator = false;
        _enableRewards = true;
        _requireIntegrity = true;
        break;
    }

    // Check for override flags
    _checkOverrideFlags();

    debugPrint('Flavor initialized: $_flavor');
    debugPrint('API Base URL: $_apiBaseUrl');
    debugPrint('Allow Emulator: $_allowEmulator');
    debugPrint('Enable Rewards: $_enableRewards');
    debugPrint('Require Integrity: $_requireIntegrity');
  }

  /// Check for override flags
  void _checkOverrideFlags() {
    // Check for dev integrity override
    final overrideDevIntegrity =
        const String.fromEnvironment('OVERRIDE_DEV_INTEGRITY');
    if (_flavor == Flavor.dev && overrideDevIntegrity == 'true') {
      _enableRewards = true;
      _requireIntegrity = true;
      debugPrint('Dev integrity override enabled');
    }

    // Check for custom API URL override
    final customApiUrl = const String.fromEnvironment('API_BASE_URL');
    if (customApiUrl.isNotEmpty) {
      _apiBaseUrl = customApiUrl;
      debugPrint('Custom API URL override: $_apiBaseUrl');
    }
  }

  /// Check if current environment is development
  bool get isDevelopment => _flavor == Flavor.dev;

  /// Check if current environment is production
  bool get isProduction => _flavor == Flavor.prod;

  /// Get app title based on flavor
  String get appTitle {
    switch (_flavor) {
      case Flavor.dev:
        return 'Quiz & Learn (DEV)';
      case Flavor.prod:
        return 'Quiz & Learn';
    }
  }

  /// Get app version suffix based on flavor
  String get appVersionSuffix {
    switch (_flavor) {
      case Flavor.dev:
        return '-dev';
      case Flavor.prod:
        return '';
    }
  }

  /// Check if features should be enabled based on flavor
  bool shouldEnableFeature(String featureName) {
    switch (featureName) {
      case 'rewards':
        return _enableRewards;
      case 'integrity':
        return _requireIntegrity;
      case 'emulator':
        return _allowEmulator;
      default:
        return true;
    }
  }

  /// Get configuration summary
  Map<String, dynamic> getConfigurationSummary() {
    return {
      'flavor': _flavor.name,
      'apiBaseUrl': _apiBaseUrl,
      'allowEmulator': _allowEmulator,
      'enableRewards': _enableRewards,
      'requireIntegrity': _requireIntegrity,
      'isDevelopment': isDevelopment,
      'isProduction': isProduction,
      'appTitle': appTitle,
      'appVersionSuffix': appVersionSuffix,
    };
  }
}
