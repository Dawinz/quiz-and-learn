import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';
import '../admob_config_service.dart';

class BannerAdManager {
  static BannerAdManager? _instance;
  static BannerAdManager get instance => _instance ??= BannerAdManager._();

  BannerAdManager._();

  final AdMobConfigService _config = AdMobConfigService.instance;
  BannerAd? _bannerAd;
  bool _isLoading = false;
  bool _isLoaded = false;

  /// Check if ad is currently loading
  bool get isLoading => _isLoading;

  /// Check if ad is loaded and ready to show
  bool get isLoaded => _isLoaded;

  /// Check if ad is available
  bool get isAvailable => _bannerAd != null && _isLoaded;

  /// Initialize the banner ad manager
  Future<void> initialize() async {
    await _config.initialize();
  }

  /// Load a banner ad
  Future<bool> loadAd() async {
    if (_isLoading || _isLoaded) return false;

    try {
      _isLoading = true;
      _isLoaded = false;

      final adUnitId = _config.bannerAdUnitId;
      if (adUnitId.isEmpty) {
        debugPrint('Banner ad unit ID not configured');
        return false;
      }

      // Use test ad unit ID if in test mode
      final finalAdUnitId = _config.isTestMode
          ? 'ca-app-pub-3940256099942544/6300978111' // Test banner ad unit ID
          : adUnitId;

      debugPrint('Loading banner ad with ID: $finalAdUnitId');

      _bannerAd = BannerAd(
        adUnitId: finalAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('Banner ad loaded successfully');
            _isLoaded = true;
            _isLoading = false;
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('Banner ad failed to load: ${error.message}');
            _isLoaded = false;
            _isLoading = false;
            _bannerAd = null;
          },
          onAdOpened: (ad) {
            debugPrint('Banner ad opened');
          },
          onAdClosed: (ad) {
            debugPrint('Banner ad closed');
          },
        ),
      );

      // Add timeout to prevent hanging
      final completer = Completer<bool>();
      Timer? timeoutTimer;

      timeoutTimer = Timer(const Duration(seconds: 15), () {
        if (!completer.isCompleted) {
          debugPrint('Banner ad load timeout');
          _isLoaded = false;
          _isLoading = false;
          _bannerAd = null;
          completer.complete(false);
        }
      });

      _bannerAd!.load().then((_) {
        timeoutTimer?.cancel();
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      }).catchError((error) {
        timeoutTimer?.cancel();
        if (!completer.isCompleted) {
          debugPrint('Banner ad load error: $error');
          _isLoaded = false;
          _isLoading = false;
          _bannerAd = null;
          completer.complete(false);
        }
      });

      return await completer.future;
    } catch (e) {
      debugPrint('Error loading banner ad: $e');
      _isLoading = false;
      _isLoaded = false;
      return false;
    }
  }

  /// Get banner ad widget
  Widget? getBannerWidget() {
    if (!isAvailable) return null;

    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  /// Get adaptive banner ad widget (recommended for production)
  Widget? getAdaptiveBannerWidget() {
    if (!isAvailable) return null;

    return Container(
      width: double.infinity,
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  /// Get smart banner ad widget (automatically adjusts size)
  Widget? getSmartBannerWidget() {
    if (!isAvailable) return null;

    // Create a new AdWidget instance each time to prevent "already in widget tree" errors
    return Container(
      width: double.infinity,
      height: 50, // Standard banner height
      child: AdWidget(
        key: ValueKey(
            'banner_${DateTime.now().millisecondsSinceEpoch}_${_bannerAd.hashCode}'),
        ad: _bannerAd!,
      ),
    );
  }

  /// Dispose of the current ad
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;
    _isLoading = false;
  }

  /// Get manager status for debugging
  Map<String, dynamic> get status {
    return {
      'isLoading': _isLoading,
      'isLoaded': _isLoaded,
      'isAvailable': isAvailable,
      'adUnitId': _config.bannerAdUnitId,
      'isTestMode': _config.isTestMode,
      'adSize': _bannerAd?.size.toString(),
    };
  }
}
