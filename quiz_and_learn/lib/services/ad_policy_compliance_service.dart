import 'package:flutter/foundation.dart';
import 'admob_config_service.dart';

/// Service to ensure AdMob policy compliance and manage ad frequency
class AdPolicyComplianceService {
  static AdPolicyComplianceService? _instance;
  static AdPolicyComplianceService get instance =>
      _instance ??= AdPolicyComplianceService._();

  AdPolicyComplianceService._();

  final AdMobConfigService _config = AdMobConfigService.instance;

  // Session tracking
  DateTime? _sessionStartTime;
  int _interstitialAdsShown = 0;
  int _rewardedAdsShown = 0;
  int _totalAdsShown = 0;

  // Timing tracking
  DateTime? _lastInterstitialAd;
  DateTime? _lastRewardedAd;

  // Quiz-specific tracking
  int _currentQuizAdCount = 0;
  int _questionsSinceLastAd = 0;

  /// Initialize the service
  void initialize() {
    _sessionStartTime = DateTime.now();
    resetCounters();
  }

  /// Reset all counters (call when starting new session)
  void resetCounters() {
    _interstitialAdsShown = 0;
    _rewardedAdsShown = 0;
    _totalAdsShown = 0;
    _currentQuizAdCount = 0;
    _questionsSinceLastAd = 0;
    _lastInterstitialAd = null;
    _lastRewardedAd = null;
  }

  /// Check if interstitial ad can be shown
  bool canShowInterstitialAd() {
    // Check session limit
    if (_interstitialAdsShown >= _config.interstitialMaxPerSession) {
      debugPrint('Interstitial ad limit reached for this session');
      return false;
    }

    // Check time interval
    if (_lastInterstitialAd != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastInterstitialAd!);
      final minInterval =
          Duration(minutes: _config.interstitialMinIntervalMinutes);

      if (timeSinceLastAd < minInterval) {
        debugPrint(
            'Interstitial ad interval not met. Wait ${minInterval.inMinutes - timeSinceLastAd.inMinutes} more minutes');
        return false;
      }
    }

    // Check quiz limit
    if (_currentQuizAdCount >= _config.maxAdsPerQuiz) {
      debugPrint('Quiz ad limit reached');
      return false;
    }

    return true;
  }

  /// Check if rewarded ad can be shown
  bool canShowRewardedAd() {
    // Check session limit
    if (_rewardedAdsShown >= _config.rewardedAdMaxPerSession) {
      debugPrint('Rewarded ad limit reached for this session');
      return false;
    }

    // Check time interval
    if (_lastRewardedAd != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastRewardedAd!);
      final minInterval =
          Duration(minutes: _config.rewardedAdMinIntervalMinutes);

      if (timeSinceLastAd < minInterval) {
        debugPrint(
            'Rewarded ad interval not met. Wait ${minInterval.inMinutes - timeSinceLastAd.inMinutes} more minutes');
        return false;
      }
    }

    // Check quiz limit
    if (_currentQuizAdCount >= _config.maxAdsPerQuiz) {
      debugPrint('Quiz ad limit reached');
      return false;
    }

    return true;
  }

  /// Check if any ad can be shown
  bool canShowAnyAd() {
    return canShowInterstitialAd() || canShowRewardedAd();
  }

  /// Check if it's time to show an ad based on question count
  bool shouldShowAdAfterQuestion() {
    return _questionsSinceLastAd >= _config.minQuestionsBetweenAds;
  }

  /// Record that an interstitial ad was shown
  void recordInterstitialAdShown() {
    _interstitialAdsShown++;
    _totalAdsShown++;
    _currentQuizAdCount++;
    _lastInterstitialAd = DateTime.now();
    _questionsSinceLastAd = 0;

    debugPrint(
        'Interstitial ad shown. Total: $_interstitialAdsShown, Quiz: $_currentQuizAdCount');
  }

  /// Record that a rewarded ad was shown
  void recordRewardedAdShown() {
    _rewardedAdsShown++;
    _totalAdsShown++;
    _currentQuizAdCount++;
    _lastRewardedAd = DateTime.now();
    _questionsSinceLastAd = 0;

    debugPrint(
        'Rewarded ad shown. Total: $_rewardedAdsShown, Quiz: $_currentQuizAdCount');
  }

  /// Increment question counter
  void incrementQuestionCount() {
    _questionsSinceLastAd++;
  }

  /// Get recommended ad type based on current state
  String getRecommendedAdType() {
    if (canShowRewardedAd() &&
        _questionsSinceLastAd >= _config.minQuestionsBetweenAds * 2) {
      return 'rewarded'; // Show rewarded ad for longer gaps
    }

    if (canShowInterstitialAd()) {
      return 'interstitial';
    }

    if (canShowRewardedAd()) {
      return 'rewarded';
    }

    return 'none';
  }

  /// Get time until next ad can be shown
  Duration? getTimeUntilNextAd() {
    if (canShowAnyAd()) return Duration.zero;

    Duration? shortestWait;

    // Check interstitial timing
    if (_lastInterstitialAd != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastInterstitialAd!);
      final minInterval =
          Duration(minutes: _config.interstitialMinIntervalMinutes);
      if (timeSinceLastAd < minInterval) {
        final waitTime = minInterval - timeSinceLastAd;
        shortestWait = waitTime;
      }
    }

    // Check rewarded ad timing
    if (_lastRewardedAd != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastRewardedAd!);
      final minInterval =
          Duration(minutes: _config.rewardedAdMinIntervalMinutes);
      if (timeSinceLastAd < minInterval) {
        final waitTime = minInterval - timeSinceLastAd;
        if (shortestWait == null || waitTime < shortestWait) {
          shortestWait = waitTime;
        }
      }
    }

    return shortestWait;
  }

  /// Get current compliance status
  Map<String, dynamic> getComplianceStatus() {
    return {
      'sessionStartTime': _sessionStartTime?.toIso8601String(),
      'interstitialAdsShown': _interstitialAdsShown,
      'rewardedAdsShown': _rewardedAdsShown,
      'totalAdsShown': _totalAdsShown,
      'currentQuizAdCount': _currentQuizAdCount,
      'questionsSinceLastAd': _questionsSinceLastAd,
      'canShowInterstitial': canShowInterstitialAd(),
      'canShowRewarded': canShowRewardedAd(),
      'canShowAnyAd': canShowAnyAd(),
      'shouldShowAdAfterQuestion': shouldShowAdAfterQuestion(),
      'recommendedAdType': getRecommendedAdType(),
      'timeUntilNextAd': getTimeUntilNextAd()?.inSeconds,
      'limits': {
        'interstitialMaxPerSession': _config.interstitialMaxPerSession,
        'rewardedMaxPerSession': _config.rewardedAdMaxPerSession,
        'maxAdsPerQuiz': _config.maxAdsPerQuiz,
        'minQuestionsBetweenAds': _config.minQuestionsBetweenAds,
      },
      'intervals': {
        'interstitialMinInterval': _config.interstitialMinIntervalMinutes,
        'rewardedMinInterval': _config.rewardedAdMinIntervalMinutes,
      },
    };
  }

  /// Check if current ad strategy complies with AdMob policies
  bool isPolicyCompliant() {
    // Check frequency limits
    if (_interstitialAdsShown > _config.interstitialMaxPerSession) return false;
    if (_rewardedAdsShown > _config.rewardedAdMaxPerSession) return false;
    if (_currentQuizAdCount > _config.maxAdsPerQuiz) return false;

    // Check timing compliance
    if (_lastInterstitialAd != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastInterstitialAd!);
      if (timeSinceLastAd <
          Duration(minutes: _config.interstitialMinIntervalMinutes)) {
        return false;
      }
    }

    if (_lastRewardedAd != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastRewardedAd!);
      if (timeSinceLastAd <
          Duration(minutes: _config.rewardedAdMinIntervalMinutes)) {
        return false;
      }
    }

    return true;
  }

  /// Get policy compliance warnings
  List<String> getPolicyWarnings() {
    final warnings = <String>[];

    if (_interstitialAdsShown >= _config.interstitialMaxPerSession) {
      warnings.add('Interstitial ad limit reached for this session');
    }

    if (_rewardedAdsShown >= _config.rewardedAdMaxPerSession) {
      warnings.add('Rewarded ad limit reached for this session');
    }

    if (_currentQuizAdCount >= _config.maxAdsPerQuiz) {
      warnings.add('Quiz ad limit reached');
    }

    if (!isPolicyCompliant()) {
      warnings.add('Current ad strategy may not comply with AdMob policies');
    }

    return warnings;
  }
}
