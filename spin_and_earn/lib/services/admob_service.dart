import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

class AdMobService {
  // Test Ad Unit IDs (for development)
  static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/1712485313';
  static const String _testRewardedInterstitialAdUnitId = 'ca-app-pub-3940256099942544/5354046379';
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  
  // Production Ad Unit IDs
  static const String _androidRewardedAdUnitId = 'ca-app-pub-6181092189054832/5896249880';
  static const String _androidRewardedInterstitialAdUnitId = 'ca-app-pub-6181092189054832/5879922109';
  static const String _androidBannerAdUnitId = 'ca-app-pub-6181092189054832/1234567890';
  
  // iOS Production Ad Unit IDs
  static const String _iosRewardedAdUnitId = 'ca-app-pub-6181092189054832/4695134266'; // Your actual iOS rewarded ad unit ID
  static const String _iosRewardedInterstitialAdUnitId = 'ca-app-pub-6181092189054832/5879922109'; // Replace with your iOS ad unit ID
  static const String _iosBannerAdUnitId = 'ca-app-pub-6181092189054832/1234567890'; // Replace with your iOS ad unit ID

  // Singleton instance
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  // Ad instances
  RewardedAd? _rewardedAd;
  RewardedInterstitialAd? _rewardedInterstitialAd;
  BannerAd? _bannerAd;
  bool _isRewardedAdLoading = false;
  bool _isBannerAdLoading = false;

  // Getters for ad unit IDs based on platform
  String get rewardedAdUnitId {
    // Use test ads for development
    if (kDebugMode) {
      return _testRewardedAdUnitId;
    }
    
    // Use platform-specific IDs for production
    if (Platform.isAndroid) {
      return _androidRewardedAdUnitId;
    } else if (Platform.isIOS) {
      return _iosRewardedAdUnitId;
    }
    return _testRewardedAdUnitId; // fallback
  }

  String get rewardedInterstitialAdUnitId {
    // Use test ads for development
    if (kDebugMode) {
      return _testRewardedInterstitialAdUnitId;
    }
    
    // Use platform-specific IDs for production
    if (Platform.isAndroid) {
      return _androidRewardedInterstitialAdUnitId;
    } else if (Platform.isIOS) {
      return _iosRewardedInterstitialAdUnitId;
    }
    return _testRewardedInterstitialAdUnitId; // fallback
  }

  String get bannerAdUnitId {
    // Use test ads for development
    if (kDebugMode) {
      return _testBannerAdUnitId;
    }
    
    // Use platform-specific IDs for production
    if (Platform.isAndroid) {
      return _androidBannerAdUnitId;
    } else if (Platform.isIOS) {
      return _iosBannerAdUnitId;
    }
    return _testBannerAdUnitId; // fallback
  }

  // Load Rewarded Ad
  Future<void> loadRewardedAd() async {
    if (_isRewardedAdLoading) return;

    _isRewardedAdLoading = true;
    
    try {
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isRewardedAdLoading = false;
            debugPrint('Rewarded ad loaded successfully');
          },
          onAdFailedToLoad: (error) {
            _isRewardedAdLoading = false;
            debugPrint('Rewarded ad failed to load: $error');
          },
        ),
      );
    } catch (e) {
      _isRewardedAdLoading = false;
      debugPrint('Error loading rewarded ad: $e');
    }
  }

  // Show Rewarded Ad
  Future<bool> showRewardedAd({
    required Function() onRewarded,
    required Function() onAdClosed,
    required Function() onAdFailedToShow,
  }) async {
    if (_rewardedAd == null) {
      debugPrint('Rewarded ad not loaded');
      return false;
    }

    bool rewardEarned = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        onAdClosed();
        loadRewardedAd(); // Load next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        onAdFailedToShow();
        debugPrint('Rewarded ad failed to show: $error');
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        rewardEarned = true;
        onRewarded();
        debugPrint('User earned reward: ${reward.amount} ${reward.type}');
      },
    );

    return rewardEarned;
  }

  // Check if rewarded ad is ready
  bool get isRewardedAdReady => _rewardedAd != null;
  
  // Check if ads are loading
  bool get isRewardedAdLoading => _isRewardedAdLoading;

  // Load Banner Ad
  Future<void> loadBannerAd() async {
    if (_isBannerAdLoading) return;

    _isBannerAdLoading = true;
    
    try {
      _bannerAd = BannerAd(
        adUnitId: bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _isBannerAdLoading = false;
            debugPrint('Banner ad loaded successfully');
          },
          onAdFailedToLoad: (ad, error) {
            _isBannerAdLoading = false;
            ad.dispose();
            debugPrint('Banner ad failed to load: $error');
          },
        ),
      );
      
      await _bannerAd!.load();
    } catch (e) {
      _isBannerAdLoading = false;
      debugPrint('Error loading banner ad: $e');
    }
  }

  // Check if banner ad is ready
  bool get isBannerAdReady => _bannerAd != null;
  
  // Check if banner ads are loading
  bool get isBannerAdLoading => _isBannerAdLoading;

  // Create Banner Ad Widget
  Widget createBannerAd() {
    if (_bannerAd == null) {
      // Load banner ad if not loaded
      loadBannerAd();
      return Container(
        width: AdSize.banner.width.toDouble(),
        height: AdSize.banner.height.toDouble(),
        color: Colors.grey[200],
        child: const Center(
          child: Text('Loading Ad...', style: TextStyle(fontSize: 12)),
        ),
      );
    }
    
    return Container(
      alignment: Alignment.center,
      width: AdSize.banner.width.toDouble(),
      height: AdSize.banner.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  // Dispose ads
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedInterstitialAd?.dispose();
    _bannerAd?.dispose();
  }
} 