import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../admob_config_service.dart';

class NativeAdManager {
  static NativeAdManager? _instance;
  static NativeAdManager get instance => _instance ??= NativeAdManager._();

  NativeAdManager._();

  final AdMobConfigService _config = AdMobConfigService.instance;
  NativeAd? _nativeAd;
  bool _isLoading = false;
  bool _isLoaded = false;

  /// Check if native ads are supported on current platform
  bool get isSupported => Platform.isAndroid;

  /// Check if ad is currently loading
  bool get isLoading => _isLoading;

  /// Check if ad is loaded and ready to show
  bool get isLoaded => _isLoaded;

  /// Check if ad is available
  bool get isAvailable => _nativeAd != null && _isLoaded && isSupported;

  /// Initialize the native ad manager
  Future<void> initialize() async {
    await _config.initialize();
  }

  /// Load a native ad
  Future<bool> loadAd() async {
    if (!isSupported) {
      debugPrint('Native ads not supported on this platform');
      return false;
    }

    if (_isLoading || _isLoaded) return false;

    try {
      _isLoading = true;
      _isLoaded = false;

      final adUnitId = _config.nativeAdUnitId;
      if (adUnitId.isEmpty) {
        debugPrint('Native ad unit ID not configured');
        return false;
      }

      // Use test ad unit ID if in test mode
      final finalAdUnitId = _config.isTestMode
          ? 'ca-app-pub-3940256099942544/2247696110' // Test native ad unit ID
          : adUnitId;

      debugPrint('Loading native ad with ID: $finalAdUnitId');

      _nativeAd = NativeAd(
        adUnitId: finalAdUnitId,
        factoryId: 'listTile',
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            debugPrint('Native ad loaded successfully');
            _isLoaded = true;
            _isLoading = false;
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('Native ad failed to load: ${error.message}');
            _isLoaded = false;
            _isLoading = false;
            _nativeAd = null;
          },
          onAdOpened: (ad) {
            debugPrint('Native ad opened');
          },
          onAdClosed: (ad) {
            debugPrint('Native ad closed');
          },
          onAdImpression: (ad) {
            debugPrint('Native ad impression');
          },
          onAdClicked: (ad) {
            debugPrint('Native ad clicked');
          },
        ),
      );

      await _nativeAd!.load();
      return true;
    } catch (e) {
      debugPrint('Error loading native ad: $e');
      _isLoading = false;
      _isLoaded = false;
      return false;
    }
  }

  /// Get native ad widget
  Widget? getNativeAdWidget() {
    if (!isAvailable) return null;

    return Container(
      height: 72, // Standard list tile height
      child: AdWidget(ad: _nativeAd!),
    );
  }

  /// Get custom styled native ad widget
  Widget? getCustomNativeAdWidget({
    double height = 120,
    EdgeInsets padding = const EdgeInsets.all(8.0),
  }) {
    if (!isAvailable) return null;

    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: AdWidget(ad: _nativeAd!),
    );
  }

  /// Get native ad widget for results screen
  Widget? getResultsScreenNativeAd() {
    if (!isAvailable) return null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sponsored',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: AdWidget(ad: _nativeAd!),
          ),
        ],
      ),
    );
  }

  /// Dispose of the current ad
  void dispose() {
    _nativeAd?.dispose();
    _nativeAd = null;
    _isLoaded = false;
    _isLoading = false;
  }

  /// Get manager status for debugging
  Map<String, dynamic> get status {
    return {
      'isSupported': isSupported,
      'isLoading': _isLoading,
      'isLoaded': _isLoaded,
      'isAvailable': isAvailable,
      'adUnitId': _config.nativeAdUnitId,
      'isTestMode': _config.isTestMode,
      'platform': Platform.operatingSystem,
    };
  }
}
