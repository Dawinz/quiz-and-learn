import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AdMobConfigService {
  static AdMobConfigService? _instance;
  static AdMobConfigService get instance => _instance ??= AdMobConfigService._();

  AdMobConfigService._();

  Map<String, dynamic>? _config;
  bool _isInitialized = false;

  /// Initialize the configuration service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final configFile = File('config/admob_config.json');
      if (await configFile.exists()) {
        final jsonString = await configFile.readAsString();
        _config = json.decode(jsonString) as Map<String, dynamic>;
      } else {
        // Fallback to default config if file doesn't exist
        _config = _getDefaultConfig();
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error loading AdMob config: $e');
      _config = _getDefaultConfig();
      _isInitialized = true;
    }
  }

  /// Get Android App ID
  String get androidAppId => _config?['android']?['app_id'] ?? '';

  /// Get iOS App ID
  String get iosAppId => _config?['ios']?['app_id'] ?? '';

  /// Get platform-specific App ID
  String get appId {
    if (Platform.isAndroid) return androidAppId;
    if (Platform.isIOS) return iosAppId;
    return '';
  }

  /// Get Rewarded Video Ad Unit ID for current platform
  String get rewardedAdUnitId {
    if (Platform.isAndroid) return _config?['android']?['rewarded'] ?? '';
    if (Platform.isIOS) return _config?['ios']?['rewarded'] ?? '';
    return '';
  }

  /// Get Interstitial Ad Unit ID for current platform
  String get interstitialAdUnitId {
    if (Platform.isAndroid) return _config?['android']?['interstitial'] ?? '';
    if (Platform.isIOS) return _config?['ios']?['interstitial'] ?? '';
    return '';
  }

  /// Get Banner Ad Unit ID for current platform
  String get bannerAdUnitId {
    if (Platform.isAndroid) return _config?['android']?['banner'] ?? '';
    if (Platform.isIOS) return _config?['ios']?['banner'] ?? '';
    return '';
  }

  /// Get Native Ad Unit ID for current platform (Android only)
  String get nativeAdUnitId {
    if (Platform.isAndroid) return _config?['android']?['native'] ?? '';
    return '';
  }

  /// Get reward amount for rewarded video
  int get rewardedVideoCoins => _config?['rewards']?['quiz_and_learn']?['rewarded_video']?['coins'] ?? 10;

  /// Check if test mode is enabled
  bool get isTestMode => _config?['test_mode'] ?? kDebugMode;

  /// Get frequency capping settings
  Map<String, dynamic> get frequencyCapping => _config?['frequency_capping'] ?? {};

  /// Get minimum interval between interstitials (in minutes)
  int get interstitialMinIntervalMinutes => frequencyCapping['interstitial_min_interval_minutes'] ?? 3;

  /// Get maximum interstitials per session
  int get interstitialMaxPerSession => frequencyCapping['interstitial_max_per_session'] ?? 5;

  /// Get minimum interval between rewarded ads (in minutes)
  int get rewardedAdMinIntervalMinutes => frequencyCapping['rewarded_min_interval_minutes'] ?? 5;

  /// Get maximum rewarded ads per session
  int get rewardedAdMaxPerSession => frequencyCapping['rewarded_max_per_session'] ?? 3;

  /// Get minimum questions between ads
  int get minQuestionsBetweenAds => frequencyCapping['min_questions_between_ads'] ?? 3;

  /// Get maximum ads per quiz
  int get maxAdsPerQuiz => frequencyCapping['max_ads_per_quiz'] ?? 4;

  /// Get ad display strategy
  String get adDisplayStrategy => _config?['ad_display_strategy'] ?? 'balanced';

  /// Check if aggressive ad mode is enabled
  bool get isAggressiveAdMode => _config?['aggressive_ad_mode'] ?? false;

  /// Get quiz completion ad settings
  Map<String, dynamic> get quizCompletionAds => _config?['quiz_completion_ads'] ?? {};

  /// Check if interstitial should show after quiz completion
  bool get showInterstitialAfterQuiz => quizCompletionAds['show_interstitial'] ?? true;

  /// Check if rewarded ad should be prompted after quiz completion
  bool get promptRewardedAdAfterQuiz => quizCompletionAds['prompt_rewarded'] ?? true;

  /// Check if native ad should show in results
  bool get showNativeAdInResults => quizCompletionAds['show_native'] ?? true;

  /// Get ad content policy settings
  Map<String, dynamic> get adContentPolicy => _config?['ad_content_policy'] ?? {};

  /// Check if ads should respect user preferences
  bool get respectUserPreferences => adContentPolicy['respect_user_preferences'] ?? true;

  /// Check if ads should be family-friendly
  bool get familyFriendlyAds => adContentPolicy['family_friendly'] ?? true;

  /// Get ad loading timeout settings
  Map<String, dynamic> get adLoadingTimeouts => _config?['ad_loading_timeouts'] ?? {};

  /// Get interstitial ad loading timeout (seconds)
  int get interstitialLoadingTimeout => adLoadingTimeouts['interstitial'] ?? 15;

  /// Get rewarded ad loading timeout (seconds)
  int get rewardedAdLoadingTimeout => adLoadingTimeouts['rewarded'] ?? 20;

  /// Get banner ad loading timeout (seconds)
  int get bannerAdLoadingTimeout => adLoadingTimeouts['banner'] ?? 10;

  /// Default configuration fallback
  Map<String, dynamic> _getDefaultConfig() {
    return {
      'android': {
        'app_id': 'ca-app-pub-6181092189054832~7096810595',
        'rewarded': 'ca-app-pub-6181092189054832/9985847751',
        'interstitial': 'ca-app-pub-6181092189054832/7351945552',
        'banner': 'ca-app-pub-6181092189054832/6857121530',
        'native': 'ca-app-pub-6181092189054832/9505118560',
      },
      'ios': {
        'app_id': 'ca-app-pub-6181092189054832~7096810595',
        'rewarded': 'ca-app-pub-6181092189054832/9985847751',
        'interstitial': 'ca-app-pub-6181092189054832/7351945552',
        'banner': 'ca-app-pub-6181092189054832/6857121530',
        'native': 'ca-app-pub-6181092189054832/9505118560',
      },
      'rewards': {
        'quiz_and_learn': {
          'rewarded_video': {
            'coins': 10,
            'experience': 25,
          },
        },
      },
      'test_mode': kDebugMode,
      'frequency_capping': {
        'interstitial_min_interval_minutes': 2,
        'interstitial_max_per_session': 6,
        'rewarded_min_interval_minutes': 3,
        'rewarded_max_per_session': 4,
        'min_questions_between_ads': 3,
        'max_ads_per_quiz': 5,
      },
      'ad_display_strategy': 'balanced',
      'aggressive_ad_mode': false,
      'quiz_completion_ads': {
        'show_interstitial': true,
        'prompt_rewarded': true,
        'show_native': true,
      },
      'ad_content_policy': {
        'respect_user_preferences': true,
        'family_friendly': true,
        'max_ad_content_rating': 'G',
      },
      'ad_loading_timeouts': {
        'interstitial': 15,
        'rewarded': 20,
        'banner': 10,
        'native': 25,
      },
    };
  }

  /// Check if configuration is valid
  bool get isValid {
    if (!_isInitialized) return false;
    
    final hasAndroidConfig = androidAppId.isNotEmpty && 
                            _config?['android']?['rewarded']?.isNotEmpty == true &&
                            _config?['android']?['interstitial']?.isNotEmpty == true &&
                            _config?['android']?['banner']?.isNotEmpty == true;
    
    final hasIosConfig = iosAppId.isNotEmpty && 
                         _config?['ios']?['rewarded']?.isNotEmpty == true &&
                         _config?['ios']?['interstitial']?.isNotEmpty == true &&
                         _config?['ios']?['banner']?.isNotEmpty == true;
    
    return hasAndroidConfig || hasIosConfig;
  }

  /// Get configuration summary for debugging
  Map<String, dynamic> get debugInfo {
    return {
      'isInitialized': _isInitialized,
      'isValid': isValid,
      'isTestMode': isTestMode,
      'platform': Platform.operatingSystem,
      'appId': appId,
      'rewardedAdUnitId': rewardedAdUnitId,
      'interstitialAdUnitId': interstitialAdUnitId,
      'bannerAdUnitId': bannerAdUnitId,
      'nativeAdUnitId': nativeAdUnitId,
      'rewardedVideoCoins': rewardedVideoCoins,
      'frequencyCapping': frequencyCapping,
    };
  }
}
