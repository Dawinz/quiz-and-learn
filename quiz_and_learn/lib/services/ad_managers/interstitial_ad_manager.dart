import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';
import '../admob_config_service.dart';

class InterstitialAdManager {
  static InterstitialAdManager? _instance;
  static InterstitialAdManager get instance =>
      _instance ??= InterstitialAdManager._();

  InterstitialAdManager._();

  InterstitialAd? _interstitialAd;
  bool _isLoading = false;
  bool _isLoaded = false;
  DateTime? _lastShownTime;
  int _showsThisSession = 0;
  final AdMobConfigService _config = AdMobConfigService.instance;

  /// Check if ad is currently loading
  bool get isLoading => _isLoading;

  /// Check if ad is loaded and ready to show
  bool get isLoaded => _isLoaded;

  /// Check if ad is available
  bool get isAvailable => _interstitialAd != null && _isLoaded;

  /// Check if ad can be shown based on frequency capping
  bool get canShowAd {
    if (!isAvailable) return false;

    // Check minimum interval
    if (_lastShownTime != null) {
      final timeSinceLastShow = DateTime.now().difference(_lastShownTime!);
      final minInterval =
          Duration(minutes: _config.interstitialMinIntervalMinutes);
      if (timeSinceLastShow < minInterval) {
        return false;
      }
    }

    // Check maximum per session
    if (_showsThisSession >= _config.interstitialMaxPerSession) {
      return false;
    }

    return true;
  }

  /// Initialize the interstitial ad manager
  Future<void> initialize() async {
    await _config.initialize();
  }

  /// Load an interstitial ad
  Future<bool> loadAd() async {
    if (_isLoading || _isLoaded) return false;

    try {
      _isLoading = true;
      _isLoaded = false;

      final adUnitId = _config.interstitialAdUnitId;
      if (adUnitId.isEmpty) {
        debugPrint('Interstitial ad unit ID not configured');
        return false;
      }

      // Use test ad unit ID if in test mode
      final finalAdUnitId = _config.isTestMode
          ? 'ca-app-pub-3940256099942544/1033173712' // Test interstitial ad unit ID
          : adUnitId;

      debugPrint('Loading interstitial ad with ID: $finalAdUnitId');

      // Add timeout to prevent hanging
      final completer = Completer<bool>();
      Timer? timeoutTimer;

      timeoutTimer = Timer(const Duration(seconds: 15), () {
        if (!completer.isCompleted) {
          debugPrint('Interstitial ad load timeout');
          _isLoaded = false;
          _isLoading = false;
          _interstitialAd = null;
          completer.complete(false);
        }
      });

      InterstitialAd.load(
        adUnitId: finalAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            timeoutTimer?.cancel();
            if (!completer.isCompleted) {
              debugPrint('Interstitial ad loaded successfully');
              _interstitialAd = ad;
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
              debugPrint('Interstitial ad failed to load: ${error.message}');
              _isLoaded = false;
              _isLoading = false;
              _interstitialAd = null;
              completer.complete(false);
            }
          },
        ),
      );

      return await completer.future;
    } catch (e) {
      debugPrint('Error loading interstitial ad: $e');
      _isLoading = false;
      _isLoaded = false;
      return false;
    }
  }

  /// Show the interstitial ad if conditions are met
  Future<bool> showAdIfReady() async {
    if (!canShowAd) {
      debugPrint('Interstitial ad not ready to show. Loading...');
      final loaded = await loadAd();
      if (!loaded) return false;

      // Check again after loading
      if (!canShowAd) return false;
    }

    try {
      final ad = _interstitialAd;
      if (ad == null) return false;

      debugPrint('Showing interstitial ad');

      await ad.show();
      _onAdShown();

      return true;
    } catch (e) {
      debugPrint('Error showing interstitial ad: $e');
      return false;
    }
  }

  /// Force show the ad (bypasses frequency capping)
  Future<bool> forceShowAd() async {
    if (!isAvailable) {
      final loaded = await loadAd();
      if (!loaded) return false;
    }

    try {
      final ad = _interstitialAd;
      if (ad == null) return false;

      debugPrint('Force showing interstitial ad');

      await ad.show();
      _onAdShown();

      return true;
    } catch (e) {
      debugPrint('Error force showing interstitial ad: $e');
      return false;
    }
  }

  /// Set up event handlers for the ad
  void _setupEventHandlers() {
    final ad = _interstitialAd;
    if (ad == null) return;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('Interstitial ad dismissed');
        _isLoaded = false;
        _interstitialAd = null;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Interstitial ad failed to show: ${error.message}');
        _isLoaded = false;
        _interstitialAd = null;
      },
      onAdShowedFullScreenContent: (ad) {
        debugPrint('Interstitial ad showed full screen content');
      },
    );
  }

  /// Handle ad shown event
  void _onAdShown() {
    _lastShownTime = DateTime.now();
    _showsThisSession++;

    debugPrint('Interstitial ad shown. Shows this session: $_showsThisSession');
  }

  /// Reset session counter (call when app restarts or user logs out)
  void resetSession() {
    _showsThisSession = 0;
    debugPrint('Interstitial ad session reset');
  }

  /// Dispose of the current ad
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isLoaded = false;
    _isLoading = false;
  }

  /// Get manager status for debugging
  Map<String, dynamic> get status {
    return {
      'isLoading': _isLoading,
      'isLoaded': _isLoaded,
      'isAvailable': isAvailable,
      'canShowAd': canShowAd,
      'adUnitId': _config.interstitialAdUnitId,
      'isTestMode': _config.isTestMode,
      'lastShownTime': _lastShownTime?.toIso8601String(),
      'showsThisSession': _showsThisSession,
      'minIntervalMinutes': _config.interstitialMinIntervalMinutes,
      'maxPerSession': _config.interstitialMaxPerSession,
    };
  }
}
