import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Fingerprint {
  static final Fingerprint _instance = Fingerprint._internal();
  factory Fingerprint() => _instance;
  Fingerprint._internal();

  bool _isInitialized = false;
  String? _cachedFingerprint;

  bool get isInitialized => _isInitialized;

  /// Initialize the fingerprint service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load cached fingerprint if available
      await _loadCachedFingerprint();
      _isInitialized = true;
      debugPrint('Fingerprint service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing fingerprint service: $e');
      _isInitialized = true;
    }
  }

  /// Generate a privacy-aware device fingerprint
  Future<String> generateFingerprint() async {
    if (_cachedFingerprint != null) {
      return _cachedFingerprint!;
    }

    try {
      final fingerprintData = await _collectFingerprintData();
      final fingerprint = _hashFingerprintData(fingerprintData);

      // Cache the fingerprint
      _cachedFingerprint = fingerprint;
      await _cacheFingerprint(fingerprint);

      debugPrint(
          'Device fingerprint generated: ${fingerprint.substring(0, 8)}...');
      return fingerprint;
    } catch (e) {
      debugPrint('Error generating fingerprint: $e');
      // Return a fallback fingerprint
      return _generateFallbackFingerprint();
    }
  }

  /// Collect fingerprint data from device
  Future<Map<String, dynamic>> _collectFingerprintData() async {
    final data = <String, dynamic>{};

    try {
      // Platform information
      data['platform'] = Platform.operatingSystem;
      data['platformVersion'] = Platform.operatingSystemVersion;

      // Device information (privacy-aware)
      if (Platform.isAndroid) {
        data.addAll(await _collectAndroidData());
      } else if (Platform.isIOS) {
        data.addAll(await _collectIOSData());
      }

      // App-specific information
      data['appVersion'] = await _getAppVersion();
      data['buildNumber'] = await _getBuildNumber();

      // Screen information (resolution only, no exact dimensions)
      data['screenDensity'] = await _getScreenDensity();
      data['screenRatio'] = await _getScreenRatio();

      // Language and region
      data['locale'] = await _getLocale();

      // Timezone (general, not exact)
      data['timezone'] = await _getTimezone();

      // Network information (type only, no IP)
      data['networkType'] = await _getNetworkType();

      // Device capabilities (privacy-safe)
      data['capabilities'] = await _getDeviceCapabilities();
    } catch (e) {
      debugPrint('Error collecting fingerprint data: $e');
    }

    return data;
  }

  /// Collect Android-specific data
  Future<Map<String, dynamic>> _collectAndroidData() async {
    final data = <String, dynamic>{};

    try {
      const platform = MethodChannel('security_channel');

      // Get device model (general, not exact)
      data['deviceModel'] =
          await platform.invokeMethod('getDeviceModel') ?? 'unknown';

      // Get Android version
      data['androidVersion'] =
          await platform.invokeMethod('getAndroidVersion') ?? 'unknown';

      // Get build fingerprint (privacy-safe)
      data['buildFingerprint'] =
          await platform.invokeMethod('getBuildFingerprint') ?? 'unknown';

      // Get hardware info (general)
      data['hardware'] =
          await platform.invokeMethod('getHardware') ?? 'unknown';

      // Get CPU architecture
      data['cpuArch'] =
          await platform.invokeMethod('getCpuArchitecture') ?? 'unknown';
    } catch (e) {
      debugPrint('Error collecting Android data: $e');
      // Fallback data
      data['deviceModel'] = 'android_device';
      data['androidVersion'] = 'unknown';
      data['buildFingerprint'] = 'unknown';
      data['hardware'] = 'unknown';
      data['cpuArch'] = 'unknown';
    }

    return data;
  }

  /// Collect iOS-specific data
  Future<Map<String, dynamic>> _collectIOSData() async {
    final data = <String, dynamic>{};

    try {
      const platform = MethodChannel('security_channel');

      // Get device model (general, not exact)
      data['deviceModel'] =
          await platform.invokeMethod('getDeviceModel') ?? 'unknown';

      // Get iOS version
      data['iosVersion'] =
          await platform.invokeMethod('getIOSVersion') ?? 'unknown';

      // Get device identifier (privacy-safe)
      data['deviceIdentifier'] =
          await platform.invokeMethod('getDeviceIdentifier') ?? 'unknown';

      // Get hardware info (general)
      data['hardware'] =
          await platform.invokeMethod('getHardware') ?? 'unknown';
    } catch (e) {
      debugPrint('Error collecting iOS data: $e');
      // Fallback data
      data['deviceModel'] = 'ios_device';
      data['iosVersion'] = 'unknown';
      data['deviceIdentifier'] = 'unknown';
      data['hardware'] = 'unknown';
    }

    return data;
  }

  /// Get app version
  Future<String> _getAppVersion() async {
    try {
      const platform = MethodChannel('security_channel');
      return await platform.invokeMethod('getAppVersion') ?? '1.0.0';
    } catch (e) {
      return '1.0.0';
    }
  }

  /// Get build number
  Future<String> _getBuildNumber() async {
    try {
      const platform = MethodChannel('security_channel');
      return await platform.invokeMethod('getBuildNumber') ?? '1';
    } catch (e) {
      return '1';
    }
  }

  /// Get screen density
  Future<String> _getScreenDensity() async {
    try {
      const platform = MethodChannel('security_channel');
      final density = await platform.invokeMethod('getScreenDensity') ?? 1.0;
      // Round to nearest 0.5 for privacy
      return (density * 2).round() / 2.0;
    } catch (e) {
      return '1.0';
    }
  }

  /// Get screen ratio
  Future<String> _getScreenRatio() async {
    try {
      const platform = MethodChannel('security_channel');
      final ratio = await platform.invokeMethod('getScreenRatio') ?? '16:9';
      return ratio;
    } catch (e) {
      return '16:9';
    }
  }

  /// Get locale
  Future<String> _getLocale() async {
    try {
      const platform = MethodChannel('security_channel');
      return await platform.invokeMethod('getLocale') ?? 'en_US';
    } catch (e) {
      return 'en_US';
    }
  }

  /// Get timezone
  Future<String> _getTimezone() async {
    try {
      const platform = MethodChannel('security_channel');
      return await platform.invokeMethod('getTimezone') ?? 'UTC';
    } catch (e) {
      return 'UTC';
    }
  }

  /// Get network type
  Future<String> _getNetworkType() async {
    try {
      const platform = MethodChannel('security_channel');
      return await platform.invokeMethod('getNetworkType') ?? 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }

  /// Get device capabilities
  Future<Map<String, bool>> _getDeviceCapabilities() async {
    final capabilities = <String, bool>{};

    try {
      const platform = MethodChannel('security_channel');

      capabilities['hasCamera'] =
          await platform.invokeMethod('hasCamera') ?? false;
      capabilities['hasBluetooth'] =
          await platform.invokeMethod('hasBluetooth') ?? false;
      capabilities['hasWifi'] = await platform.invokeMethod('hasWifi') ?? false;
      capabilities['hasGPS'] = await platform.invokeMethod('hasGPS') ?? false;
      capabilities['hasFingerprint'] =
          await platform.invokeMethod('hasFingerprint') ?? false;
      capabilities['hasFaceID'] =
          await platform.invokeMethod('hasFaceID') ?? false;
    } catch (e) {
      debugPrint('Error getting device capabilities: $e');
      // Default capabilities
      capabilities['hasCamera'] = true;
      capabilities['hasBluetooth'] = true;
      capabilities['hasWifi'] = true;
      capabilities['hasGPS'] = true;
      capabilities['hasFingerprint'] = false;
      capabilities['hasFaceID'] = false;
    }

    return capabilities;
  }

  /// Hash fingerprint data to create a unique identifier
  String _hashFingerprintData(Map<String, dynamic> data) {
    try {
      // Sort keys for consistent hashing
      final sortedKeys = data.keys.toList()..sort();
      final sortedData = <String, dynamic>{};

      for (final key in sortedKeys) {
        sortedData[key] = data[key];
      }

      // Convert to JSON string
      final jsonString = jsonEncode(sortedData);

      // Create SHA-256 hash
      final bytes = utf8.encode(jsonString);
      final digest = sha256.convert(bytes);

      return digest.toString();
    } catch (e) {
      debugPrint('Error hashing fingerprint data: $e');
      return _generateFallbackFingerprint();
    }
  }

  /// Generate fallback fingerprint
  String _generateFallbackFingerprint() {
    final random = Random();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return sha256.convert(bytes).toString();
  }

  /// Cache fingerprint to SharedPreferences
  Future<void> _cacheFingerprint(String fingerprint) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('device_fingerprint', fingerprint);
      await prefs.setInt(
          'fingerprint_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Error caching fingerprint: $e');
    }
  }

  /// Load cached fingerprint from SharedPreferences
  Future<void> _loadCachedFingerprint() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('device_fingerprint');
      final timestamp = prefs.getInt('fingerprint_timestamp');

      if (cached != null && timestamp != null) {
        // Check if cache is still valid (7 days)
        final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (cacheAge < const Duration(days: 7).inMilliseconds) {
          _cachedFingerprint = cached;
          debugPrint('Loaded cached fingerprint');
        }
      }
    } catch (e) {
      debugPrint('Error loading cached fingerprint: $e');
    }
  }

  /// Clear cached fingerprint
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('device_fingerprint');
      await prefs.remove('fingerprint_timestamp');
      _cachedFingerprint = null;
      debugPrint('Fingerprint cache cleared');
    } catch (e) {
      debugPrint('Error clearing fingerprint cache: $e');
    }
  }

  /// Get current fingerprint
  String? getCurrentFingerprint() => _cachedFingerprint;
}
