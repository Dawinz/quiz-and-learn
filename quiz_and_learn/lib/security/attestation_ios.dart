import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../services/remote_config_service.dart';
import 'device_key.dart';
import 'security_guard.dart';

class AttestationIOS {
  static final AttestationIOS _instance = AttestationIOS._internal();
  factory AttestationIOS() => _instance;
  AttestationIOS._internal();

  bool _isInitialized = false;
  late final Dio _dio;
  late final DeviceKey _deviceKey;
  late final RemoteConfigService _remoteConfig;

  bool get isInitialized => _isInitialized;

  /// Initialize the iOS attestation service
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
      debugPrint('AttestationIOS initialized successfully');
    } catch (e) {
      debugPrint('Error initializing AttestationIOS: $e');
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

      // Step 2: Get App Attest assertion
      final assertion = await _getAppAttestAssertion(nonce);
      if (assertion == null) {
        return AttestationResult(
          isValid: false,
          reason: 'Failed to get App Attest assertion',
        );
      }

      // Step 3: Get DeviceCheck token
      final deviceCheckToken = await _getDeviceCheckToken();
      if (deviceCheckToken == null) {
        return AttestationResult(
          isValid: false,
          reason: 'Failed to get DeviceCheck token',
        );
      }

      // Step 4: Generate device signature
      final deviceSignature =
          await _deviceKey.generateAttestationSignature(nonce);
      if (deviceSignature == null) {
        return AttestationResult(
          isValid: false,
          reason: 'Failed to generate device signature',
        );
      }

      // Step 5: Verify attestation with server
      final verificationResult = await _verifyAttestationWithServer(
        nonce,
        assertion,
        deviceCheckToken,
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

  /// Get App Attest assertion
  Future<String?> _getAppAttestAssertion(String nonce) async {
    try {
      const platform = MethodChannel('security_channel');

      final assertion = await platform.invokeMethod('getAppAttestAssertion', {
        'nonce': nonce,
      });

      return assertion;
    } catch (e) {
      debugPrint('Error getting App Attest assertion: $e');
      return null;
    }
  }

  /// Get DeviceCheck token
  Future<String?> _getDeviceCheckToken() async {
    try {
      const platform = MethodChannel('security_channel');

      final token = await platform.invokeMethod('getDeviceCheckToken');

      return token;
    } catch (e) {
      debugPrint('Error getting DeviceCheck token: $e');
      return null;
    }
  }

  /// Verify attestation with server
  Future<Map<String, dynamic>> _verifyAttestationWithServer(
    String nonce,
    String assertion,
    String deviceCheckToken,
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
          'assertion': assertion,
          'deviceCheckToken': deviceCheckToken,
          'deviceSignature': deviceSignature,
          'platform': 'ios',
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

  /// Check if App Attest is available
  Future<bool> isAppAttestAvailable() async {
    try {
      const platform = MethodChannel('security_channel');
      final available = await platform.invokeMethod('isAppAttestAvailable');
      return available == true;
    } catch (e) {
      debugPrint('Error checking App Attest availability: $e');
      return false;
    }
  }

  /// Check if DeviceCheck is available
  Future<bool> isDeviceCheckAvailable() async {
    try {
      const platform = MethodChannel('security_channel');
      final available = await platform.invokeMethod('isDeviceCheckAvailable');
      return available == true;
    } catch (e) {
      debugPrint('Error checking DeviceCheck availability: $e');
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
      'appAttestAvailable': false, // Will be updated when called
      'deviceCheckAvailable': false, // Will be updated when called
      'deviceKeyValid': _deviceKey.isInitialized,
    };
  }
}

// AttestationResult class is defined in security_guard.dart
