import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  Map<String, dynamic>? _config;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final configString = await rootBundle.loadString('config/api_config.json');
      _config = json.decode(configString) as Map<String, dynamic>;
      _isInitialized = true;
               } catch (e) {
             debugPrint('Error loading config: $e');
             // Use default values if config fails to load
      _config = {
        'backend': {
          'base_url': 'https://backend-jperulfmz-dawson-s-projects.vercel.app',
          'api_version': '/api',
          'timeout_seconds': 30
        },
        'referral': {
          'reward_amount': 100,
          'max_referrals_per_user': 10
        },
        'environment': 'production'
      };
      _isInitialized = true;
    }
  }

  String get backendBaseUrl => _config?['backend']?['base_url'] ?? '';
  String get apiVersion => _config?['backend']?['api_version'] ?? '/api';
  String get fullApiUrl => backendBaseUrl + apiVersion;
  int get referralRewardAmount => _config?['referral']?['reward_amount'] ?? 100;
  int get maxReferralsPerUser => _config?['referral']?['max_referrals_per_user'] ?? 10;
  String get environment => _config?['environment'] ?? 'production';

  bool get isProduction => environment == 'production';
  bool get isDevelopment => environment == 'development';
}
