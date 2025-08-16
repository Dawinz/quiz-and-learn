# 🔒 Security Features - Quiz & Learn

This document explains how to use the new anti-fraud security layer integrated into the Quiz & Learn app.

## 🚀 Quick Start

### 1. Build with Security Features

#### Development Build (Default)
```bash
flutter run
```
- Emulator allowed
- Rewards disabled by default
- Integrity checks relaxed
- Debug mode enabled

#### Development Build with Integrity Override
```bash
flutter run --dart-define=OVERRIDE_DEV_INTEGRITY=true
```
- Emulator allowed
- Rewards enabled
- Integrity checks enforced
- Debug mode enabled

#### Production Build
```bash
flutter run --release
```
- Emulator blocked
- Rewards enabled
- Integrity checks enforced
- Debug mode disabled

#### Custom API Endpoint
```bash
flutter run --dart-define=API_BASE_URL=https://your-api.com
```

### 2. Run Security Guard CLI Tool

```bash
# Run all security checks
dart tool/security_guard.dart

# Run with verbose output
dart tool/security_guard.dart --verbose

# Run only config sync
dart tool/security_guard.dart --config-only

# Run only environment checks
dart tool/security_guard.dart --env-only

# Run only attestation
dart tool/security_guard.dart --attestation-only

# Output in JSON format
dart tool/security_guard.dart --json
```

## 🏗️ Architecture

### Security Components

1. **SecurityGuard** (`lib/security/security_guard.dart`)
   - Main orchestrator for all security checks
   - Provides unified interface for security enforcement
   - Manages attestation and environment validation

2. **RemoteConfigService** (`lib/services/remote_config_service.dart`)
   - Fetches configuration from server
   - Caches config for 60 seconds
   - Provides feature flags and limits

3. **OutboxService** (`lib/services/outbox_service.dart`)
   - Handles all write operations with idempotency
   - Generates UUID v4 for Idempotency-Key headers
   - Implements retry logic with exponential backoff

4. **SecureWalletService** (`lib/services/secure_wallet_service.dart`)
   - Never credits rewards locally
   - Shows "pending" until server confirms
   - Integrates with security guard for validation

### Platform-Specific Security

- **Android**: Play Integrity API with server nonce
- **iOS**: App Attest + DeviceCheck
- **Both**: Hardware-backed keypairs (Keystore/Secure Enclave)

## 🔧 Configuration

### Remote Config Endpoint

The app fetches configuration from:
```
GET {API_BASE_URL}/v1/config
```

### Config Structure

```json
{
  "features": {
    "rewardsEnabled": true,
    "requireIntegrity": true
  },
  "limits": {
    "dailyRewardCap": 100,
    "rewardCadenceSeconds": 60
  },
  "risk": {
    "holdThreshold": 50,
    "blockThreshold": 100
  }
}
```

### Build Flavors

| Feature | Dev | Prod |
|---------|-----|------|
| Emulator | ✅ | ❌ |
| Rewards | ❌* | ✅ |
| Integrity | ❌* | ✅ |
| Debug | ✅ | ❌ |

*Can be overridden with `OVERRIDE_DEV_INTEGRITY=true`

## 🛡️ Security Checks

### Environment Checks
- Emulator detection
- Root/jailbreak detection
- App cloning detection
- Debug mode detection
- Suspicious packages
- VPN/proxy usage

### Device Attestation
- **Android**: Play Integrity API
- **iOS**: App Attest + DeviceCheck
- Server-side verification with nonce
- Hardware-backed signatures

### Device Fingerprinting
- Privacy-aware device identification
- SHA-256 hashed fingerprint
- Cached for 7 days
- No exact device details exposed

## 📱 Integration Points

### 1. App Initialization
Security guard runs automatically in `main()` before showing any screens.

### 2. Reward Flows
Before any reward/claim operation:
```dart
final securityGuard = SecurityGuard();
final canClaim = await securityGuard.canClaimReward();
if (!canClaim) {
  // Show error or block action
  return;
}
```

### 3. Security Banner
The app automatically shows a security banner when integrity checks fail:
```dart
SecurityBanner(
  child: YourScreen(),
)
```

## 🚨 Security Events

### Blocked Actions
- Rewards when integrity checks fail
- Rewards when environment is unsafe
- Rewards when daily cap is reached
- Rewards when attestation is invalid

### Logging
All security events are logged with:
- Timestamp
- Device fingerprint
- Security status
- Blocked action details

## 🔍 Monitoring

### Security Status
```dart
final status = securityGuard.getSecurityStatus();
print('Secure: ${status.isSecure}');
print('Environment: ${status.isEnvironmentSafe}');
print('Attestation: ${status.isAttestationValid}');
```

### Outbox Status
```dart
final outbox = OutboxService();
final stats = await outbox.getStats();
print('Pending: ${stats.pending}');
print('Completed: ${stats.completed}');
print('Failed: ${stats.failed}');
```

## 🧪 Testing

### Development Mode
- Use emulator for testing
- Set `OVERRIDE_DEV_INTEGRITY=true` for full testing
- Security checks are relaxed but still functional

### Production Mode
- Test on real devices
- All security checks are enforced
- No emulator support

### Security Guard CLI
```bash
# Test config sync
dart tool/security_guard.dart --config-only --verbose

# Test environment checks
dart tool/security_guard.dart --env-only --verbose

# Test attestation
dart tool/security_guard.dart --attestation-only --verbose
```

## 🚀 Deployment

### 1. Set API Base URL
```bash
flutter build apk --dart-define=API_BASE_URL=https://your-api.com
flutter build ios --dart-define=API_BASE_URL=https://your-api.com
```

### 2. Production Build
```bash
flutter build apk --release
flutter build ios --release
```

### 3. Verify Security
```bash
dart tool/security_guard.dart --verbose
```

## 🔐 Server Requirements

### Attestation Endpoints
- `POST /v1/attestation/nonce` - Generate nonce
- `POST /v1/attestation/verify` - Verify attestation

### Reward Endpoints
- `POST /v1/rewards/request` - Request reward
- `GET /v1/config` - Get configuration

### Headers
- `Idempotency-Key`: UUID v4 for write operations
- `Authorization`: Bearer token for authenticated requests
- `Device-Fingerprint`: Device identifier hash

## 📊 Metrics

### Security Metrics
- Device integrity status
- Attestation success rate
- Environment check results
- Blocked reward attempts

### Performance Metrics
- Security check duration
- Attestation latency
- Config sync frequency
- Outbox operation success rate

## 🆘 Troubleshooting

### Common Issues

1. **Security Guard Fails to Initialize**
   - Check API_BASE_URL is set
   - Verify network connectivity
   - Check server endpoints

2. **Attestation Fails**
   - Verify Play Integrity API setup (Android)
   - Check App Attest configuration (iOS)
   - Verify server nonce generation

3. **Environment Checks Fail**
   - Check if running on emulator
   - Verify device is not rooted/jailbroken
   - Check for suspicious packages

4. **Outbox Operations Fail**
   - Check network connectivity
   - Verify server endpoints
   - Check authentication tokens

### Debug Mode
```bash
flutter run --debug
```
Security events are logged to console in debug mode.

### Verbose CLI
```bash
dart tool/security_guard.dart --verbose
```
Detailed output for troubleshooting security issues.

## 📚 Additional Resources

- [Play Integrity API Documentation](https://developer.android.com/google/play/integrity)
- [App Attest Documentation](https://developer.apple.com/documentation/devicecheck/establishing_your_app_s_integrity)
- [Flutter Security Best Practices](https://flutter.dev/docs/deployment/security)
- [Device Fingerprinting Guidelines](https://developer.mozilla.org/en-US/docs/Web/API/Fingerprinting)
