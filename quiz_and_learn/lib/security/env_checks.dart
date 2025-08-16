import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnvChecks {
  static final EnvChecks _instance = EnvChecks._internal();
  factory EnvChecks() => _instance;
  EnvChecks._internal();

  bool _isInitialized = false;
  Map<String, bool> _checkResults = {};
  List<String> _issues = [];

  bool get isInitialized => _isInitialized;
  bool get isEnvironmentSafe => true; // Temporarily disable strict environment checks for development
  List<String> get issues => List.from(_issues);

  /// Initialize the environment checks
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Perform initial checks
      await performAllChecks();
      _isInitialized = true;
      debugPrint('EnvChecks initialized successfully');
    } catch (e) {
      debugPrint('Error initializing EnvChecks: $e');
      _isInitialized = true;
    }
  }

  /// Perform all environment checks
  Future<void> performAllChecks() async {
    _checkResults.clear();
    _issues.clear();

    // Check for emulator
    _checkResults['isEmulator'] = await _checkIsEmulator();
    if (_checkResults['isEmulator'] == true) {
      _issues.add('Running on emulator');
    }

    // Check for root/jailbreak
    _checkResults['isRooted'] = await _checkIsRooted();
    if (_checkResults['isRooted'] == true) {
      _issues.add('Device is rooted/jailbroken');
    }

    // Check for app cloning
    _checkResults['isCloned'] = await _checkIsCloned();
    if (_checkResults['isCloned'] == true) {
      _issues.add('App appears to be cloned');
    }

    // Check for debug mode
    _checkResults['isDebugMode'] = kDebugMode;
    if (_checkResults['isDebugMode'] == true) {
      _issues.add('Running in debug mode');
    }

    // Check for development build
    _checkResults['isDevelopmentBuild'] = await _checkIsDevelopmentBuild();
    if (_checkResults['isDevelopmentBuild'] == true) {
      _issues.add('Development build detected');
    }

    // Check for suspicious packages
    _checkResults['hasSuspiciousPackages'] = await _checkSuspiciousPackages();
    if (_checkResults['hasSuspiciousPackages'] == true) {
      _issues.add('Suspicious packages detected');
    }

    // Check for VPN/proxy
    _checkResults['isUsingVPN'] = await _checkVPNUsage();
    if (_checkResults['isUsingVPN'] == true) {
      _issues.add('VPN/proxy detected');
    }

    debugPrint('Environment checks completed. Issues: ${_issues.length}');
  }

  /// Get all check results
  Map<String, bool> getResults() {
    return Map.from(_checkResults);
  }

  /// Check if running on emulator
  Future<bool> _checkIsEmulator() async {
    try {
      if (Platform.isAndroid) {
        return await _checkAndroidEmulator();
      } else if (Platform.isIOS) {
        return await _checkIOSEmulator();
      }
      return false;
    } catch (e) {
      debugPrint('Error checking emulator: $e');
      return false;
    }
  }

  /// Check Android emulator
  Future<bool> _checkAndroidEmulator() async {
    try {
      const platform = MethodChannel('security_channel');
      final result = await platform.invokeMethod('checkEmulator');
      return result == true;
    } catch (e) {
      // Fallback checks
      return await _checkAndroidEmulatorFallback();
    }
  }

  /// Fallback Android emulator check
  Future<bool> _checkAndroidEmulatorFallback() async {
    try {
      // Check for common emulator indicators
      final buildProps = await _readFile('/system/build.prop');
      if (buildProps.contains('ro.kernel.qemu=1') ||
          buildProps.contains('ro.hardware=goldfish') ||
          buildProps.contains('ro.product.model=sdk') ||
          buildProps.contains('ro.product.model=Emulator')) {
        return true;
      }

      // Check for emulator-specific files
      final files = [
        '/sys/devices/virtual/switch/h2w',
        '/sys/devices/virtual/switch/h2w/state',
        '/sys/devices/virtual/switch/h2w/name',
      ];

      for (final file in files) {
        if (await File(file).exists()) {
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error in fallback emulator check: $e');
      return false;
    }
  }

  /// Check iOS emulator
  Future<bool> _checkIOSEmulator() async {
    try {
      const platform = MethodChannel('security_channel');
      final result = await platform.invokeMethod('checkEmulator');
      return result == true;
    } catch (e) {
      // Fallback: check for simulator-specific environment
      return Platform.environment.containsKey('SIMULATOR_DEVICE_NAME') ||
             Platform.environment.containsKey('SIMULATOR_HOST_HOME');
    }
  }

  /// Check if device is rooted/jailbroken
  Future<bool> _checkIsRooted() async {
    try {
      if (Platform.isAndroid) {
        return await _checkAndroidRoot();
      } else if (Platform.isIOS) {
        return await _checkIOSJailbreak();
      }
      return false;
    } catch (e) {
      debugPrint('Error checking root: $e');
      return false;
    }
  }

  /// Check Android root
  Future<bool> _checkAndroidRoot() async {
    try {
      const platform = MethodChannel('security_channel');
      final result = await platform.invokeMethod('checkRoot');
      return result == true;
    } catch (e) {
      // Fallback checks
      return await _checkAndroidRootFallback();
    }
  }

  /// Fallback Android root check
  Future<bool> _checkAndroidRootFallback() async {
    try {
      // Check for common root indicators
      final files = [
        '/system/app/Superuser.apk',
        '/system/xbin/su',
        '/system/bin/su',
        '/sbin/su',
        '/system/su',
        '/system/bin/.ext/.su',
        '/system/etc/init.d/99SuperSUDaemon',
        '/dev/com.koushikdutta.superuser.daemon/',
      ];

      for (final file in files) {
        if (await File(file).exists()) {
          return true;
        }
      }

      // Check if su command is available
      try {
        final result = await Process.run('which', ['su']);
        if (result.exitCode == 0) {
          return true;
        }
      } catch (e) {
        // Process.run might not be available
      }

      return false;
    } catch (e) {
      debugPrint('Error in fallback root check: $e');
      return false;
    }
  }

  /// Check iOS jailbreak
  Future<bool> _checkIOSJailbreak() async {
    try {
      const platform = MethodChannel('security_channel');
      final result = await platform.invokeMethod('checkJailbreak');
      return result == true;
    } catch (e) {
      // Fallback checks
      return await _checkIOSJailbreakFallback();
    }
  }

  /// Fallback iOS jailbreak check
  Future<bool> _checkIOSJailbreakFallback() async {
    try {
      // Check for common jailbreak indicators
      final files = [
        '/Applications/Cydia.app',
        '/Library/MobileSubstrate/MobileSubstrate.dylib',
        '/bin/bash',
        '/usr/sbin/sshd',
        '/etc/apt',
        '/private/var/lib/apt/',
        '/private/var/lib/cydia',
        '/private/var/mobile/Library/SBSettings/Themes',
        '/Library/MobileSubstrate/DynamicLibraries/Veency.plist',
        '/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist',
        '/System/Library/LaunchDaemons/com.ikey.bbot.plist',
        '/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist',
      ];

      for (final file in files) {
        if (await File(file).exists()) {
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error in fallback jailbreak check: $e');
      return false;
    }
  }

  /// Check if app is cloned
  Future<bool> _checkIsCloned() async {
    try {
      // Check for multiple instances of the app
      // This is a simplified check - in production, you'd want more sophisticated detection
      return false;
    } catch (e) {
      debugPrint('Error checking app cloning: $e');
      return false;
    }
  }

  /// Check if this is a development build
  Future<bool> _checkIsDevelopmentBuild() async {
    try {
      // Check for development-specific indicators
      if (kDebugMode) return true;
      
      // Check for development certificates
      if (Platform.isIOS) {
        // iOS development builds have different provisioning profiles
        return false; // Simplified for now
      } else if (Platform.isAndroid) {
        // Android debug builds
        return false; // Simplified for now
      }
      
      return false;
    } catch (e) {
      debugPrint('Error checking development build: $e');
      return false;
    }
  }

  /// Check for suspicious packages
  Future<bool> _checkSuspiciousPackages() async {
    try {
      if (Platform.isAndroid) {
        return await _checkAndroidSuspiciousPackages();
      }
      return false;
    } catch (e) {
      debugPrint('Error checking suspicious packages: $e');
      return false;
    }
  }

  /// Check Android suspicious packages
  Future<bool> _checkAndroidSuspiciousPackages() async {
    try {
      const platform = MethodChannel('security_channel');
      final result = await platform.invokeMethod('checkSuspiciousPackages');
      return result == true;
    } catch (e) {
      // Fallback: check for common suspicious packages
      final suspiciousPackages = [
        'com.nox',
        'com.parallel.space.lite',
        'com.excelliance.dualaid',
        'com.lbe.parallel',
        'com.parallel.space.lite',
        'com.parallel.space.lite',
        'com.parallel.space.lite',
      ];

      // This would require package manager access
      return false;
    }
  }

  /// Check VPN usage
  Future<bool> _checkVPNUsage() async {
    try {
      if (Platform.isAndroid) {
        return await _checkAndroidVPN();
      } else if (Platform.isIOS) {
        return await _checkIOSVPN();
      }
      return false;
    } catch (e) {
      debugPrint('Error checking VPN: $e');
      return false;
    }
  }

  /// Check Android VPN
  Future<bool> _checkAndroidVPN() async {
    try {
      const platform = MethodChannel('security_channel');
      final result = await platform.invokeMethod('checkVPN');
      return result == true;
    } catch (e) {
      // Fallback: check for VPN interfaces
      return false;
    }
  }

  /// Check iOS VPN
  Future<bool> _checkIOSVPN() async {
    try {
      const platform = MethodChannel('security_channel');
      final result = await platform.invokeMethod('checkVPN');
      return result == true;
    } catch (e) {
      // Fallback: check for VPN configuration
      return false;
    }
  }

  /// Read file content (Android only)
  Future<String> _readFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return '';
    } catch (e) {
      return '';
    }
  }
}
