import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceKey {
  static final DeviceKey _instance = DeviceKey._internal();
  factory DeviceKey() => _instance;
  DeviceKey._internal();

  bool _isInitialized = false;
  String? _keyAlias;
  String? _publicKeyHash;

  bool get isInitialized => _isInitialized;

  /// Initialize the device key service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load or create device key
      await _loadOrCreateKey();
      _isInitialized = true;
      debugPrint('DeviceKey initialized successfully');
    } catch (e) {
      debugPrint('Error initializing DeviceKey: $e');
      _isInitialized = true;
    }
  }

  /// Load existing key or create a new one
  Future<void> _loadOrCreateKey() async {
    try {
      const platform = MethodChannel('security_channel');

      // Try to load existing key
      final existingKey = await _loadExistingKey();
      if (existingKey != null) {
        _keyAlias = existingKey['alias'];
        _publicKeyHash = existingKey['publicKeyHash'];
        debugPrint('Loaded existing device key');
        return;
      }

      // Create new key if none exists
      await _createNewKey();
      debugPrint('Created new device key');
    } catch (e) {
      debugPrint('Error in _loadOrCreateKey: $e');
      // Create a fallback key
      await _createFallbackKey();
    }
  }

  /// Load existing key from storage
  Future<Map<String, String>?> _loadExistingKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alias = prefs.getString('device_key_alias');
      final publicKeyHash = prefs.getString('device_key_hash');

      if (alias != null && publicKeyHash != null) {
        // Verify key still exists in keystore
        const platform = MethodChannel('security_channel');
        final keyExists =
            await platform.invokeMethod('keyExists', {'alias': alias});

        if (keyExists == true) {
          return {
            'alias': alias,
            'publicKeyHash': publicKeyHash,
          };
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error loading existing key: $e');
      return null;
    }
  }

  /// Create a new device key
  Future<void> _createNewKey() async {
    try {
      const platform = MethodChannel('security_channel');

      // Generate unique alias
      final alias = 'device_key_${DateTime.now().millisecondsSinceEpoch}';

      // Create key in keystore
      final result = await platform.invokeMethod('createKey', {
        'alias': alias,
        'algorithm': 'RSA',
        'keySize': 2048,
        'purposes': ['SIGN', 'VERIFY'],
      });

      if (result == true) {
        // Get public key hash
        final publicKeyHash = await platform.invokeMethod('getPublicKeyHash', {
          'alias': alias,
        });

        _keyAlias = alias;
        _publicKeyHash = publicKeyHash;

        // Save to storage
        await _saveKeyToStorage(alias, publicKeyHash);
      } else {
        throw Exception('Failed to create key');
      }
    } catch (e) {
      debugPrint('Error creating new key: $e');
      throw e;
    }
  }

  /// Create fallback key (for when keystore is not available)
  Future<void> _createFallbackKey() async {
    try {
      final alias = 'fallback_key_${DateTime.now().millisecondsSinceEpoch}';
      final publicKeyHash = _generateFallbackKeyHash();

      _keyAlias = alias;
      _publicKeyHash = publicKeyHash;

      await _saveKeyToStorage(alias, publicKeyHash);
      debugPrint('Created fallback device key');
    } catch (e) {
      debugPrint('Error creating fallback key: $e');
    }
  }

  /// Save key information to storage
  Future<void> _saveKeyToStorage(String alias, String publicKeyHash) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('device_key_alias', alias);
      await prefs.setString('device_key_hash', publicKeyHash);
    } catch (e) {
      debugPrint('Error saving key to storage: $e');
    }
  }

  /// Validate that the device key is valid
  Future<bool> validateKey() async {
    if (!_isInitialized || _keyAlias == null) {
      return false;
    }

    try {
      const platform = MethodChannel('security_channel');

      // Check if key exists in keystore
      final keyExists = await platform.invokeMethod('keyExists', {
        'alias': _keyAlias,
      });

      if (keyExists != true) {
        debugPrint('Device key not found in keystore');
        return false;
      }

      // Test signing to verify key works
      final testData =
          'test_signature_${DateTime.now().millisecondsSinceEpoch}';
      final signature = await signData(testData);

      if (signature == null) {
        debugPrint('Device key signature test failed');
        return false;
      }

      // Verify signature
      final isValid = await verifySignature(testData, signature);

      if (!isValid) {
        debugPrint('Device key verification test failed');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error validating device key: $e');
      return false;
    }
  }

  /// Sign data with device key
  Future<String?> signData(String data) async {
    if (!_isInitialized || _keyAlias == null) {
      return null;
    }

    try {
      const platform = MethodChannel('security_channel');

      final signature = await platform.invokeMethod('signData', {
        'alias': _keyAlias,
        'data': data,
        'algorithm': 'SHA256withRSA',
      });

      return signature;
    } catch (e) {
      debugPrint('Error signing data: $e');
      return null;
    }
  }

  /// Verify signature
  Future<bool> verifySignature(String data, String signature) async {
    if (!_isInitialized || _keyAlias == null) {
      return false;
    }

    try {
      const platform = MethodChannel('security_channel');

      final isValid = await platform.invokeMethod('verifySignature', {
        'alias': _keyAlias,
        'data': data,
        'signature': signature,
        'algorithm': 'SHA256withRSA',
      });

      return isValid == true;
    } catch (e) {
      debugPrint('Error verifying signature: $e');
      return false;
    }
  }

  /// Get public key hash
  String? getPublicKeyHash() => _publicKeyHash;

  /// Get key alias
  String? getKeyAlias() => _keyAlias;

  /// Generate attestation challenge signature
  Future<String?> generateAttestationSignature(String challenge) async {
    if (!_isInitialized || _keyAlias == null) {
      return null;
    }

    try {
      // Add timestamp to challenge
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final challengeWithTimestamp = '${challenge}_$timestamp';

      // Sign the challenge
      final signature = await signData(challengeWithTimestamp);

      if (signature != null) {
        // Return base64 encoded signature with timestamp
        final signatureData = {
          'signature': signature,
          'timestamp': timestamp,
          'challenge': challenge,
        };

        return base64Encode(utf8.encode(jsonEncode(signatureData)));
      }

      return null;
    } catch (e) {
      debugPrint('Error generating attestation signature: $e');
      return null;
    }
  }

  /// Generate fallback key hash
  String _generateFallbackKeyHash() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp % 1000000;
    return 'fallback_${random}_${timestamp}';
  }

  /// Clear device key
  Future<void> clearKey() async {
    try {
      if (_keyAlias != null) {
        const platform = MethodChannel('security_channel');
        await platform.invokeMethod('deleteKey', {'alias': _keyAlias});
      }

      // Clear from storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('device_key_alias');
      await prefs.remove('device_key_hash');

      _keyAlias = null;
      _publicKeyHash = null;

      debugPrint('Device key cleared');
    } catch (e) {
      debugPrint('Error clearing device key: $e');
    }
  }

  /// Get key information
  Map<String, dynamic> getKeyInfo() {
    return {
      'alias': _keyAlias,
      'publicKeyHash': _publicKeyHash,
      'isInitialized': _isInitialized,
    };
  }
}
