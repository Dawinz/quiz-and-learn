import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';
import 'admob_config_service.dart';
import 'ad_managers/rewarded_ad_manager.dart';
import 'ad_managers/interstitial_ad_manager.dart';
import 'ad_managers/banner_ad_manager.dart';
import 'ad_managers/native_ad_manager.dart';

class AdMobService {
  static AdMobService? _instance;
  static AdMobService get instance => _instance ??= AdMobService._();

  AdMobService._();

  final AdMobConfigService _config = AdMobConfigService.instance;
  final RewardedAdManager _rewardedManager = RewardedAdManager.instance;
  final InterstitialAdManager _interstitialManager =
      InterstitialAdManager.instance;
  final BannerAdManager _bannerManager = BannerAdManager.instance;
  final NativeAdManager _nativeManager = NativeAdManager.instance;

  bool _isInitialized = false;
  bool _isInitializing = false;
  int _initializationAttempts = 0;
  static const int _maxInitializationAttempts = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  /// Check if AdMob service is initialized
  bool get isInitialized => _isInitialized;

  /// Check if AdMob service is currently initializing
  bool get isInitializing => _isInitializing;

  /// Check if any ads are currently loading
  bool get areAdsLoading {
    return _rewardedManager.isLoading ||
        _interstitialManager.isLoading ||
        _bannerManager.isLoading ||
        _nativeManager.isLoading;
  }

  /// Check if any ads are ready to show
  bool get areAdsReady {
    return _isInitialized &&
        (_interstitialManager.isAvailable ||
            _bannerManager.isAvailable ||
            _rewardedManager.isAvailable);
  }

  /// Get comprehensive loading status for all ad types
  Map<String, bool> get adLoadingStatus {
    return {
      'rewarded': _rewardedManager.isLoading,
      'interstitial': _interstitialManager.isLoading,
      'banner': _bannerManager.isLoading,
      'native': _nativeManager.isLoading,
    };
  }

  /// Get comprehensive availability status for all ad types
  Map<String, bool> get adAvailabilityStatus {
    return {
      'rewarded': _rewardedManager.isAvailable,
      'interstitial': _interstitialManager.isAvailable,
      'banner': _bannerManager.isAvailable,
      'native': _nativeManager.isAvailable,
    };
  }

  /// Get loading progress for all ad types
  Map<String, String> get adLoadingProgress {
    final progress = <String, String>{};
    
    if (_rewardedManager.isLoading) {
      progress['rewarded'] = 'Loading rewarded ad...';
    }
    if (_interstitialManager.isLoading) {
      progress['interstitial'] = 'Loading interstitial ad...';
    }
    if (_bannerManager.isLoading) {
      progress['banner'] = 'Loading banner ad...';
    }
    if (_nativeManager.isLoading) {
      progress['native'] = 'Loading native ad...';
    }
    
    return progress;
  }

  /// Get rewarded ad manager
  RewardedAdManager get rewarded => _rewardedManager;

  /// Get interstitial ad manager
  InterstitialAdManager get interstitial => _interstitialManager;

  /// Get banner ad manager
  BannerAdManager get banner => _bannerManager;

  /// Get native ad manager
  NativeAdManager get native => _nativeManager;

  /// Initialize AdMob service and all ad managers with retry logic
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    if (_isInitializing) {
      // Wait for ongoing initialization to complete
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _isInitialized;
    }

    _isInitializing = true;
    _initializationAttempts++;

    try {
      debugPrint(
          'Initializing AdMob service (attempt $_initializationAttempts)...');

      // Initialize configuration
      await _config.initialize();

      if (!_config.isValid) {
        debugPrint('Warning: AdMob configuration is invalid');
        // Continue with initialization even if config has warnings
      }

      // Initialize Mobile Ads SDK (only on mobile platforms)
      bool sdkInitialized = false;
      try {
        await MobileAds.instance.initialize();
        sdkInitialized = true;
        debugPrint('Mobile Ads SDK initialized successfully');
      } catch (e) {
        if (e.toString().contains('MissingPluginException')) {
          debugPrint('Mobile Ads SDK not available on this platform: $e');
          // Continue without ads on unsupported platforms
        } else {
          debugPrint('Error initializing Mobile Ads SDK: $e');
          // Retry on next attempt
          throw e;
        }
      }

      // Initialize all ad managers
      await Future.wait([
        _rewardedManager.initialize(),
        _interstitialManager.initialize(),
        _bannerManager.initialize(),
        _nativeManager.initialize(),
      ]);

      debugPrint('All ad managers initialized successfully');

      // Preload ads for better user experience (only if SDK is available)
      if (sdkInitialized) {
        await _preloadAds();
      }

      _isInitialized = true;
      _isInitializing = false;
      debugPrint('AdMob service initialized successfully');

      // Log configuration info
      _logConfigurationInfo();
      return true;
    } catch (e) {
      debugPrint(
          'Error initializing AdMob service (attempt $_initializationAttempts): $e');
      _isInitializing = false;

      // Retry logic
      if (_initializationAttempts < _maxInitializationAttempts) {
        debugPrint(
            'Retrying initialization in ${_retryDelay.inSeconds} seconds...');
        await Future.delayed(_retryDelay);
        return await initialize();
      } else {
        debugPrint(
            'Max initialization attempts reached. AdMob service failed to initialize.');
        _isInitialized = false;
        return false;
      }
    }
  }

  /// Force re-initialization (useful for recovery)
  Future<bool> reinitialize() async {
    debugPrint('Forcing AdMob service re-initialization...');
    _isInitialized = false;
    _initializationAttempts = 0;
    dispose();
    return await initialize();
  }

  /// Preload ads for better performance
  Future<void> _preloadAds() async {
    try {
      debugPrint('Preloading ads...');

      // Preload interstitial and banner ads with timeout
      await Future.wait([
        _interstitialManager.loadAd().timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            debugPrint('Interstitial ad preload timeout');
            return false;
          },
        ),
        _bannerManager.loadAd().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('Banner ad preload timeout');
            return false;
          },
        ),
      ]);

      debugPrint('Ads preloaded successfully');
    } catch (e) {
      debugPrint('Error preloading ads: $e');
      // Don't fail initialization if preloading fails
    }
  }

  /// Show interstitial ad between levels/screens
  Future<bool> showInterstitialBetweenLevels() async {
    if (!_isInitialized) {
      debugPrint('AdMob service not initialized. Attempting to initialize...');
      bool initialized = await initialize();
      if (!initialized) return false;
    }

    return await _interstitialManager.showAdIfReady();
  }

  /// Show rewarded ad for bonus coins
  Future<bool> showRewardedAdForCoins() async {
    if (!_isInitialized) {
      debugPrint('AdMob service not initialized. Attempting to initialize...');
      bool initialized = await initialize();
      if (!initialized) return false;
    }

    return await _rewardedManager.showAd();
  }

  /// Get banner ad widget for bottom placement
  Widget? getBottomBannerAd() {
    if (!_isInitialized) {
      debugPrint('AdMob service not initialized. Cannot provide banner ad.');
      return null;
    }

    // Create a unique banner ad widget to prevent "already in widget tree" errors
    return _bannerManager.getSmartBannerWidget();
  }

  /// Get native ad widget for results screen
  Widget? getResultsScreenNativeAd() {
    if (!_isInitialized) {
      debugPrint('AdMob service not initialized. Cannot provide native ad.');
      return null;
    }

    return _nativeManager.getResultsScreenNativeAd();
  }

  /// Reset session counters (call when user logs out or app restarts)
  void resetSession() {
    _interstitialManager.resetSession();
    debugPrint('AdMob session reset');
  }

  /// Dispose of all ad managers
  void dispose() {
    _rewardedManager.dispose();
    _interstitialManager.dispose();
    _bannerManager.dispose();
    _nativeManager.dispose();
    _isInitialized = false;
    _isInitializing = false;
    debugPrint('AdMob service disposed');
  }

  /// Get comprehensive status for debugging
  Map<String, dynamic> get status {
    return {
      'isInitialized': _isInitialized,
      'isInitializing': _isInitializing,
      'initializationAttempts': _initializationAttempts,
      'config': _config.debugInfo,
      'rewarded': _rewardedManager.status,
      'interstitial': _interstitialManager.status,
      'banner': _bannerManager.status,
      'native': _nativeManager.status,
    };
  }

  /// Log configuration information
  void _logConfigurationInfo() {
    debugPrint('=== AdMob Configuration Info ===');
    debugPrint('Platform: ${_config.debugInfo['platform']}');
    debugPrint('App ID: ${_config.debugInfo['appId']}');
    debugPrint('Test Mode: ${_config.debugInfo['isTestMode']}');
    debugPrint('Rewarded Ad Unit ID: ${_config.debugInfo['rewardedAdUnitId']}');
    debugPrint(
        'Interstitial Ad Unit ID: ${_config.debugInfo['interstitialAdUnitId']}');
    debugPrint('Banner Ad Unit ID: ${_config.debugInfo['bannerAdUnitId']}');
    debugPrint('Native Ad Unit ID: ${_config.debugInfo['nativeAdUnitId']}');
    debugPrint('Reward Coins: ${_config.debugInfo['rewardedVideoCoins']}');
    debugPrint('================================');
  }

  /// Check if the service is in a healthy state
  bool get isHealthy {
    return _isInitialized && !_isInitializing;
  }

  /// Get initialization health status
  Map<String, dynamic> get healthStatus {
    return {
      'isHealthy': isHealthy,
      'isInitialized': _isInitialized,
      'isInitializing': _isInitializing,
      'initializationAttempts': _initializationAttempts,
      'maxAttempts': _maxInitializationAttempts,
      'adsReady': areAdsReady,
      'adLoadingStatus': adLoadingStatus,
    };
  }
}
