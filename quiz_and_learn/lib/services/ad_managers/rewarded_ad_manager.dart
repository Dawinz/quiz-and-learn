import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';
import '../admob_config_service.dart';
import '../wallet_service.dart';

class RewardedAdManager {
  static RewardedAdManager? _instance;
  static RewardedAdManager get instance => _instance ??= RewardedAdManager._();

  RewardedAdManager._();

  RewardedAd? _rewardedAd;
  bool _isLoading = false;
  bool _isLoaded = false;
  final AdMobConfigService _config = AdMobConfigService.instance;
  final WalletService _wallet = WalletService.instance;

  /// Check if ad is currently loading
  bool get isLoading => _isLoading;

  /// Check if ad is loaded and ready to show
  bool get isLoaded => _isLoaded;

  /// Check if ad is available
  bool get isAvailable => _rewardedAd != null && _isLoaded;

  /// Initialize the rewarded ad manager
  Future<void> initialize() async {
    await _config.initialize();
    await _wallet.initialize();
  }

  /// Load a rewarded ad
  Future<bool> loadAd() async {
    if (_isLoading || _isLoaded) return false;

    // Check if platform supports ads
    if (!_isPlatformSupported()) {
      debugPrint('Rewarded ads not supported on this platform');
      return false;
    }

    try {
      _isLoading = true;
      _isLoaded = false;

      final adUnitId = _config.rewardedAdUnitId;
      if (adUnitId.isEmpty) {
        debugPrint('Rewarded ad unit ID not configured');
        return false;
      }

      // Use test ad unit ID if in test mode
      final finalAdUnitId = _config.isTestMode
          ? 'ca-app-pub-3940256099942544/5224354917' // Test rewarded ad unit ID
          : adUnitId;

      debugPrint('Loading rewarded ad with ID: $finalAdUnitId');

      // Add timeout to prevent hanging
      final completer = Completer<bool>();
      Timer? timeoutTimer;

      timeoutTimer = Timer(const Duration(seconds: 15), () {
        if (!completer.isCompleted) {
          debugPrint('Rewarded ad load timeout');
          _isLoaded = false;
          _isLoading = false;
          _rewardedAd = null;
          completer.complete(false);
        }
      });

      RewardedAd.load(
        adUnitId: finalAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            timeoutTimer?.cancel();
            if (!completer.isCompleted) {
              debugPrint('Rewarded ad loaded successfully');
              _rewardedAd = ad;
              _isLoaded = true;
              _isLoading = false;

              // Set up event handlers
              _setupEventHandlers();
              completer.complete(true);
            }
          },
          onAdFailedToLoad: (error) {
            timeoutTimer?.cancel();
            if (!completer.isCompleted) {
              debugPrint('Rewarded ad failed to load: ${error.message}');
              _isLoaded = false;
              _isLoading = false;
              _rewardedAd = null;
              completer.complete(false);
            }
          },
        ),
      );

      return await completer.future;
    } catch (e) {
      debugPrint('Error loading rewarded ad: $e');
      _isLoading = false;
      _isLoaded = false;
      return false;
    }
  }

  /// Show the rewarded ad
  Future<bool> showAd() async {
    if (!isAvailable) {
      debugPrint('Rewarded ad not available. Loading...');
      final loaded = await loadAd();
      if (!loaded) return false;
    }

    try {
      final ad = _rewardedAd;
      if (ad == null) return false;

      debugPrint('Showing rewarded ad');

      await ad.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('User earned reward: ${reward.amount} ${reward.type}');
          _handleRewardEarned(reward.amount.toInt());
        },
      );

      return true;
    } catch (e) {
      debugPrint('Error showing rewarded ad: $e');
      return false;
    }
  }

  /// Set up event handlers for the ad
  void _setupEventHandlers() {
    final ad = _rewardedAd;
    if (ad == null) return;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('Rewarded ad dismissed');
        _isLoaded = false;
        _rewardedAd = null;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Rewarded ad failed to show: ${error.message}');
        _isLoaded = false;
        _rewardedAd = null;
      },
      onAdShowedFullScreenContent: (ad) {
        debugPrint('Rewarded ad showed full screen content');
      },
    );
  }

  /// Handle reward earned
  void _handleRewardEarned(int amount) {
    final coins = _config.rewardedVideoCoins;
    _wallet.addRewardedVideoCoins(coins);
  }

  /// Dispose of the current ad
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isLoaded = false;
    _isLoading = false;
  }

  /// Check if platform supports ads
  bool _isPlatformSupported() {
    try {
      // Try to access MobileAds to check if platform is supported
      MobileAds.instance;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get manager status for debugging
  Map<String, dynamic> get status {
    return {
      'isLoading': _isLoading,
      'isLoaded': _isLoaded,
      'isAvailable': isAvailable,
      'adUnitId': _config.rewardedAdUnitId,
      'isTestMode': _config.isTestMode,
      'rewardCoins': _config.rewardedVideoCoins,
      'walletBalance': _wallet.coins,
      'canReceiveReward': _wallet.canReceiveReward,
      'platformSupported': _isPlatformSupported(),
    };
  }
}
