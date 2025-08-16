#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'package:args/args.dart';
import '../lib/security/security_guard.dart';
import '../lib/services/remote_config_service.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag('verbose', abbr: 'v', help: 'Enable verbose output')
    ..addFlag('config-only', help: 'Only sync remote config')
    ..addFlag('env-only', help: 'Only run environment checks')
    ..addFlag('attestation-only', help: 'Only run attestation')
    ..addFlag('json', help: 'Output in JSON format');

  try {
    final results = parser.parse(arguments);
    final verbose = results['verbose'] as bool;
    final configOnly = results['config-only'] as bool;
    final envOnly = results['env-only'] as bool;
    final attestationOnly = results['attestation-only'] as bool;
    final jsonOutput = results['json'] as bool;

    if (verbose) {
      print('🔒 Security Guard CLI Tool');
      print('==========================');
    }

    // Initialize services
    final securityGuard = SecurityGuard();
    final remoteConfig = RemoteConfigService();

    try {
      await remoteConfig.initialize();
      await securityGuard.initialize();

      if (verbose) {
        print('✅ Services initialized');
      }
    } catch (e) {
      print('❌ Failed to initialize services: $e');
      exit(1);
    }

    // Run requested checks
    if (configOnly) {
      await _runConfigSync(remoteConfig, verbose, jsonOutput);
    } else if (envOnly) {
      await _runEnvironmentChecks(securityGuard, verbose, jsonOutput);
    } else if (attestationOnly) {
      await _runAttestation(securityGuard, verbose, jsonOutput);
    } else {
      // Run all checks
      await _runAllChecks(securityGuard, remoteConfig, verbose, jsonOutput);
    }
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}

Future<void> _runConfigSync(
  RemoteConfigService remoteConfig,
  bool verbose,
  bool jsonOutput,
) async {
  if (verbose) {
    print('\n📡 Syncing remote config...');
  }

  try {
    await remoteConfig.fetchConfig();
    final config = remoteConfig.getCurrentConfig();

    if (jsonOutput) {
      print(jsonEncode({
        'type': 'config_sync',
        'success': true,
        'config': config,
        'timestamp': DateTime.now().toIso8601String(),
      }));
    } else {
      print('✅ Config synced successfully');
      if (verbose) {
        print('   Features: ${config['features']}');
        print('   Limits: ${config['limits']}');
        print('   Risk: ${config['risk']}');
      }
    }
  } catch (e) {
    if (jsonOutput) {
      print(jsonEncode({
        'type': 'config_sync',
        'success': false,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      }));
    } else {
      print('❌ Config sync failed: $e');
    }
  }
}

Future<void> _runEnvironmentChecks(
  SecurityGuard securityGuard,
  bool verbose,
  bool jsonOutput,
) async {
  if (verbose) {
    print('\n🔍 Running environment checks...');
  }

  try {
    final result = await securityGuard.enforceAll();
    final status = securityGuard.getSecurityStatus();

    if (jsonOutput) {
      print(jsonEncode({
        'type': 'environment_checks',
        'success': status.isEnvironmentSafe,
        'issues': status.environmentIssues,
        'checks': result.environmentChecks,
        'timestamp': DateTime.now().toIso8601String(),
      }));
    } else {
      if (status.isEnvironmentSafe) {
        print('✅ Environment checks passed');
      } else {
        print('❌ Environment checks failed');
        print('   Issues: ${status.environmentIssues.join(', ')}');
      }
    }
  } catch (e) {
    if (jsonOutput) {
      print(jsonEncode({
        'type': 'environment_checks',
        'success': false,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      }));
    } else {
      print('❌ Environment checks failed: $e');
    }
  }
}

Future<void> _runAttestation(
  SecurityGuard securityGuard,
  bool verbose,
  bool jsonOutput,
) async {
  if (verbose) {
    print('\n🔐 Running attestation...');
  }

  try {
    final result = await securityGuard.enforceAll();
    final status = securityGuard.getSecurityStatus();

    if (jsonOutput) {
      print(jsonEncode({
        'type': 'attestation',
        'success': status.isAttestationValid,
        'requiresIntegrity': status.requiresIntegrity,
        'lastAttestationTime': status.lastAttestationTime?.toIso8601String(),
        'attestationResult': result.attestationResult?.reason,
        'timestamp': DateTime.now().toIso8601String(),
      }));
    } else {
      if (status.isAttestationValid) {
        print('✅ Attestation passed');
        if (verbose && status.lastAttestationTime != null) {
          print('   Last attestation: ${status.lastAttestationTime}');
        }
      } else {
        print('❌ Attestation failed');
        if (result.attestationResult != null) {
          print('   Reason: ${result.attestationResult!.reason}');
        }
      }
    }
  } catch (e) {
    if (jsonOutput) {
      print(jsonEncode({
        'type': 'attestation',
        'success': false,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      }));
    } else {
      print('❌ Attestation failed: $e');
    }
  }
}

Future<void> _runAllChecks(
  SecurityGuard securityGuard,
  RemoteConfigService remoteConfig,
  bool verbose,
  bool jsonOutput,
) async {
  if (verbose) {
    print('\n🚀 Running all security checks...');
  }

  try {
    // Sync config
    await _runConfigSync(remoteConfig, verbose, false);

    // Run security enforcement
    final result = await securityGuard.enforceAll();
    final status = securityGuard.getSecurityStatus();

    if (jsonOutput) {
      print(jsonEncode({
        'type': 'security_status',
        'overall': status.isSecure,
        'environment': status.isEnvironmentSafe,
        'attestation': status.isAttestationValid,
        'requiresIntegrity': status.requiresIntegrity,
        'issues': status.environmentIssues,
        'lastAttestationTime': status.lastAttestationTime?.toIso8601String(),
        'timestamp': DateTime.now().toIso8601String(),
      }));
    } else {
      // One-line status
      if (status.isSecure) {
        print('✅ SECURE - All checks passed');
      } else {
        final issues = <String>[];
        if (!status.isEnvironmentSafe) {
          issues.add('environment');
        }
        if (!status.isAttestationValid && status.requiresIntegrity) {
          issues.add('attestation');
        }
        print('❌ INSECURE - Issues: ${issues.join(', ')}');
      }

      if (verbose) {
        print('\nDetailed Status:');
        print('   Environment Safe: ${status.isEnvironmentSafe ? '✅' : '❌'}');
        print('   Attestation Valid: ${status.isAttestationValid ? '✅' : '❌'}');
        print(
            '   Requires Integrity: ${status.requiresIntegrity ? 'Yes' : 'No'}');

        if (status.environmentIssues.isNotEmpty) {
          print('   Environment Issues:');
          for (final issue in status.environmentIssues) {
            print('     - $issue');
          }
        }
      }
    }
  } catch (e) {
    if (jsonOutput) {
      print(jsonEncode({
        'type': 'security_status',
        'success': false,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      }));
    } else {
      print('❌ Security checks failed: $e');
    }
  }
}
