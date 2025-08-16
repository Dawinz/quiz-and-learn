import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../admob_config_service.dart';

class BannerAdManager {
  static BannerAdManager? _instance;
  static BannerAdManager get instance => _instance ??= BannerAdManager._();

  BannerAdManager._();

  final AdMobConfigService _config = AdMobConfigService.instance;
  BannerAd? _bannerAd;
  bool _isLoading = false;
  bool _isLoaded = false;
  bool _isDisposed = false;

  /// Check if banner ad is available
  bool get isAvailable => _bannerAd != null && _isLoaded && !_isDisposed;

  /// Check if banner ad is currently loading
  bool get isLoading => _isLoading;

  /// Load banner ad
  Future<bool> loadAd() async {
    if (_isDisposed) return false;
    
    if (_isLoading) {
      debugPrint('Banner ad already loading');
      return false;
    }

    if (_isLoaded && _bannerAd != null) {
      debugPrint('Banner ad already loaded');
      return true;
    }

    try {
      _isLoading = true;
      debugPrint('Loading banner ad...');

      // Dispose of previous ad if exists
      _bannerAd?.dispose();

      // Create new banner ad instance
      _bannerAd = BannerAd(
        adUnitId: _config.bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('Banner ad loaded successfully');
            _isLoaded = true;
            _isLoading = false;
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('Banner ad failed to load: $error');
            _isLoaded = false;
            _isLoading = false;
            ad.dispose();
          },
          onAdOpened: (ad) => debugPrint('Banner ad opened'),
          onAdClosed: (ad) => debugPrint('Banner ad closed'),
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
          _bannerAd?.dispose();
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
          _bannerAd?.dispose();
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

  /// Get banner ad widget with unique instance
  Widget? getBannerWidget() {
    if (!isAvailable) return null;

    // Create a unique key for this widget instance
    final uniqueKey = ValueKey('banner_${DateTime.now().millisecondsSinceEpoch}_${_bannerAd.hashCode}');
    
    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(
        key: uniqueKey,
        ad: _bannerAd!,
      ),
    );
  }

  /// Get adaptive banner ad widget with unique instance
  Widget? getAdaptiveBannerWidget() {
    if (!isAvailable) return null;

    // Create a unique key for this widget instance
    final uniqueKey = ValueKey('adaptive_banner_${DateTime.now().millisecondsSinceEpoch}_${_bannerAd.hashCode}');
    
    return Container(
      width: double.infinity,
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(
        key: uniqueKey,
        ad: _bannerAd!,
      ),
    );
  }

  /// Get smart banner ad widget with unique instance
  Widget? getSmartBannerWidget() {
    if (!isAvailable) return null;

    // Create a unique key for this widget instance
    final uniqueKey = ValueKey('smart_banner_${DateTime.now().millisecondsSinceEpoch}_${_bannerAd.hashCode}');
    
    return Container(
      width: double.infinity,
      height: 50, // Standard banner height
      child: AdWidget(
        key: uniqueKey,
        ad: _bannerAd!,
      ),
    );
  }

  /// Create a new banner ad instance for this specific widget
  /// This prevents "already in widget tree" errors by ensuring each widget has its own ad
  Widget? createUniqueBannerWidget() {
    if (!isAvailable) return null;

    // Create a completely new banner ad instance for this widget
    final newBannerAd = BannerAd(
      adUnitId: _config.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Unique banner ad loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Unique banner ad failed to load: $error');
          ad.dispose();
        },
        onAdOpened: (ad) => debugPrint('Unique banner ad opened'),
        onAdClosed: (ad) => debugPrint('Unique banner ad closed'),
      ),
    );

    // Load the new ad
    newBannerAd.load();

    // Create a unique key for this widget instance
    final uniqueKey = ValueKey('unique_banner_${DateTime.now().millisecondsSinceEpoch}_${newBannerAd.hashCode}');
    
    return Container(
      width: double.infinity,
      height: 50,
      child: AdWidget(
        key: uniqueKey,
        ad: newBannerAd,
      ),
    );
  }

  /// Dispose of the current ad
  void dispose() {
    _isDisposed = true;
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
      'isDisposed': _isDisposed,
      'adUnitId': _config.bannerAdUnitId,
      'isTestMode': _config.isTestMode,
      'adSize': _bannerAd?.size.toString(),
    };
  }
}
