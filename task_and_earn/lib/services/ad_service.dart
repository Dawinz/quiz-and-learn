import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static AdService? _instance;
  static AdService get instance => _instance ??= AdService._internal();

  AdService._internal();

  bool _isInitialized = false;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // Ad Unit IDs - Replace with your actual ad unit IDs
  static const String _bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111'; // Test ID
  static const String _interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712'; // Test ID
  static const String _rewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917'; // Test ID

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('AdService initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize AdService: $e');
    }
  }

  // Banner Ad
  Future<BannerAd?> loadBannerAd() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      _bannerAd = BannerAd(
        adUnitId: _bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('Banner ad loaded successfully');
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('Banner ad failed to load: $error');
            ad.dispose();
          },
          onAdOpened: (ad) {
            debugPrint('Banner ad opened');
          },
          onAdClosed: (ad) {
            debugPrint('Banner ad closed');
          },
        ),
      );

      await _bannerAd!.load();
      return _bannerAd;
    } catch (e) {
      debugPrint('Error loading banner ad: $e');
      return null;
    }
  }

  // Interstitial Ad
  Future<InterstitialAd?> loadInterstitialAd() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            debugPrint('Interstitial ad loaded successfully');
          },
          onAdFailedToLoad: (error) {
            debugPrint('Interstitial ad failed to load: $error');
          },
        ),
      );

      return _interstitialAd;
    } catch (e) {
      debugPrint('Error loading interstitial ad: $e');
      return null;
    }
  }

  // Show Interstitial Ad
  Future<void> showInterstitialAd() async {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          debugPrint('Interstitial ad dismissed');
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          debugPrint('Interstitial ad failed to show: $error');
        },
        onAdShowedFullScreenContent: (ad) {
          debugPrint('Interstitial ad showed full screen content');
        },
      );

      await _interstitialAd!.show();
    } else {
      debugPrint('Interstitial ad not loaded');
    }
  }

  // Rewarded Ad
  Future<RewardedAd?> loadRewardedAd() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await RewardedAd.load(
        adUnitId: _rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            debugPrint('Rewarded ad loaded successfully');
          },
          onAdFailedToLoad: (error) {
            debugPrint('Rewarded ad failed to load: $error');
          },
        ),
      );

      return _rewardedAd;
    } catch (e) {
      debugPrint('Error loading rewarded ad: $e');
      return null;
    }
  }

  // Show Rewarded Ad
  Future<bool> showRewardedAd({
    required Function() onRewarded,
    required Function() onFailed,
  }) async {
    if (_rewardedAd != null) {
      bool rewardEarned = false;

      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAd = null;

          if (rewardEarned) {
            onRewarded();
          } else {
            onFailed();
          }

          debugPrint('Rewarded ad dismissed');
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _rewardedAd = null;
          onFailed();
          debugPrint('Rewarded ad failed to show: $error');
        },
        onAdShowedFullScreenContent: (ad) {
          debugPrint('Rewarded ad showed full screen content');
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          rewardEarned = true;
          debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        },
      );

      return true;
    } else {
      debugPrint('Rewarded ad not loaded');
      onFailed();
      return false;
    }
  }

  // Show ad after task completion
  Future<void> showAdAfterTaskCompletion() async {
    // 30% chance to show interstitial ad
    if (DateTime.now().millisecondsSinceEpoch % 3 == 0) {
      await showInterstitialAd();
    }
  }

  // Show rewarded ad for bonus coins
  Future<bool> showRewardedAdForBonus() async {
    return await showRewardedAd(
      onRewarded: () {
        // User earned bonus coins
        debugPrint('User earned bonus coins from rewarded ad');
      },
      onFailed: () {
        // Ad failed to show or user didn't complete
        debugPrint('Failed to show rewarded ad or user didn\'t complete');
      },
    );
  }

  // Dispose ads
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }

  // Check if ads are available
  bool get isBannerAdLoaded => _bannerAd != null;
  bool get isInterstitialAdLoaded => _interstitialAd != null;
  bool get isRewardedAdLoaded => _rewardedAd != null;
}
