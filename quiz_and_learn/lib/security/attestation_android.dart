import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../services/remote_config_service.dart';
import 'device_key.dart';
import 'security_guard.dart';

class AttestationAndroid {
  static final AttestationAndroid _instance = AttestationAndroid._internal();
  factory AttestationAndroid() => _instance;
  AttestationAndroid._internal();

  bool _isInitialized = false;
  late final Dio _dio;
  late final DeviceKey _deviceKey;
  late final RemoteConfigService _remoteConfig;

  bool get isInitialized => _isInitialized;

  /// Initialize the Android attestation service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize dependencies
      _deviceKey = DeviceKey();
      await _deviceKey.initialize();

      _remoteConfig = RemoteConfigService();
      await _remoteConfig.initialize();

      // Initialize Dio for API calls
      _dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

      _isInitialized = true;
      debugPrint('AttestationAndroid initialized successfully');
    } catch (e) {
      debugPrint('Error initializing AttestationAndroid: $e');
      _isInitialized = true;
    }
  }

  /// Perform device attestation
  Future<AttestationResult> performAttestation() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Step 1: Get nonce from server
      final nonce = await _getServerNonce();
      if (nonce == null) {
        return AttestationResult(
          isValid: false,
          reason: 'Failed to get server nonce',
        );
      }

      // Step 2: Get Play Integrity token
      final integrityToken = await _getPlayIntegrityToken(nonce);
      if (integrityToken == null) {
        return AttestationResult(
          isValid: false,
          reason: 'Failed to get Play Integrity token',
        );
      }

      // Step 3: Generate device signature
      final deviceSignature =
          await _deviceKey.generateAttestationSignature(nonce);
      if (deviceSignature == null) {
        return AttestationResult(
          isValid: false,
          reason: 'Failed to generate device signature',
        );
      }

      // Step 4: Verify attestation with server
      final verificationResult = await _verifyAttestationWithServer(
        nonce,
        integrityToken,
        deviceSignature,
      );

      if (verificationResult['valid'] == true) {
        return AttestationResult(
          isValid: true,
          reason: 'Attestation verified successfully',
          token: verificationResult['token'],
        );
      } else {
        return AttestationResult(
          isValid: false,
          reason: verificationResult['reason'] ?? 'Server verification failed',
        );
      }
    } catch (e) {
      debugPrint('Error during attestation: $e');
      return AttestationResult(
        isValid: false,
        reason: 'Attestation error: $e',
      );
    }
  }

  /// Get nonce from server
  Future<String?> _getServerNonce() async {
    try {
      final apiBaseUrl = const String.fromEnvironment('API_BASE_URL');
      if (apiBaseUrl.isEmpty) {
        debugPrint('API_BASE_URL not defined');
        return null;
      }

      final response = await _dio.post('$apiBaseUrl/v1/attestation/nonce');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['nonce'] != null) {
          return data['nonce'];
        }
      }

      debugPrint('Failed to get server nonce: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Error getting server nonce: $e');
      return null;
    }
  }

  /// Get Play Integrity token
  Future<String?> _getPlayIntegrityToken(String nonce) async {
    try {
      const platform = MethodChannel('security_channel');

      final token = await platform.invokeMethod('getPlayIntegrityToken', {
        'nonce': nonce,
      });

      return token;
    } catch (e) {
      debugPrint('Error getting Play Integrity token: $e');
      return null;
    }
  }

  /// Verify attestation with server
  Future<Map<String, dynamic>> _verifyAttestationWithServer(
    String nonce,
    String integrityToken,
    String deviceSignature,
  ) async {
    try {
      final apiBaseUrl = const String.fromEnvironment('API_BASE_URL');
      if (apiBaseUrl.isEmpty) {
        return {'valid': false, 'reason': 'API_BASE_URL not defined'};
      }

      final response = await _dio.post(
        '$apiBaseUrl/v1/attestation/verify',
        data: {
          'nonce': nonce,
          'integrityToken': integrityToken,
          'deviceSignature': deviceSignature,
          'platform': 'android',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return {
            'valid': true,
            'token': data['token'],
            'reason': 'Verification successful',
          };
        } else {
          return {
            'valid': false,
            'reason': data['reason'] ?? 'Server verification failed',
          };
        }
      } else {
        return {
          'valid': false,
          'reason': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('Error verifying attestation with server: $e');
      return {
        'valid': false,
        'reason': 'Network error: $e',
      };
    }
  }

  /// Check if Play Integrity API is available
  Future<bool> isPlayIntegrityAvailable() async {
    try {
      const platform = MethodChannel('security_channel');
      final available = await platform.invokeMethod('isPlayIntegrityAvailable');
      return available == true;
    } catch (e) {
      debugPrint('Error checking Play Integrity availability: $e');
      return false;
    }
  }

  /// Get device integrity status
  Future<Map<String, dynamic>> getDeviceIntegrityStatus() async {
    try {
      const platform = MethodChannel('security_channel');
      final status = await platform.invokeMethod('getDeviceIntegrityStatus');

      if (status is Map) {
        return Map<String, dynamic>.from(status);
      }

      return {
        'available': false,
        'reason': 'Status not available',
      };
    } catch (e) {
      debugPrint('Error getting device integrity status: $e');
      return {
        'available': false,
        'reason': 'Error: $e',
      };
    }
  }

  /// Perform basic integrity check (without server verification)
  Future<AttestationResult> performBasicIntegrityCheck() async {
    try {
      const platform = MethodChannel('security_channel');

      final result = await platform.invokeMethod('performBasicIntegrityCheck');

      if (result is Map) {
        final data = Map<String, dynamic>.from(result);

        if (data['valid'] == true) {
          return AttestationResult(
            isValid: true,
            reason: 'Basic integrity check passed',
          );
        } else {
          return AttestationResult(
            isValid: false,
            reason: data['reason'] ?? 'Basic integrity check failed',
          );
        }
      }

      return AttestationResult(
        isValid: false,
        reason: 'Basic integrity check not available',
      );
    } catch (e) {
      debugPrint('Error performing basic integrity check: $e');
      return AttestationResult(
        isValid: false,
        reason: 'Basic integrity check error: $e',
      );
    }
  }

  /// Get attestation information
  Map<String, dynamic> getAttestationInfo() {
    return {
      'isInitialized': _isInitialized,
      'playIntegrityAvailable': false, // Will be updated when called
      'deviceKeyValid': _deviceKey.isInitialized,
    };
  }
}

// AttestationResult class is defined in security_guard.dart
