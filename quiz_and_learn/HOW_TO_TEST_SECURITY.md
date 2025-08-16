# 🧪 How to Test Security Implementation

This document provides a step-by-step testing checklist for the anti-fraud security layer.

## 🚀 Pre-Testing Setup

### 1. Environment Preparation
- [ ] Flutter SDK is up to date
- [ ] Dependencies installed: `flutter pub get`
- [ ] API_BASE_URL configured (or using default)
- [ ] Test device/emulator ready

### 2. Server Setup (Optional)
- [ ] Backend server running
- [ ] Security endpoints configured
- [ ] API authentication working
- [ ] Database accessible

## 🔧 Basic Functionality Tests

### 1. App Startup
```bash
# Test basic app launch
flutter run
```
**Expected Results:**
- [ ] App launches without crashes
- [ ] Security guard initializes
- [ ] No security errors in console
- [ ] App shows main screen

### 2. Security Guard CLI Tool
```bash
# Test CLI tool installation
dart tool/security_guard.dart --help

# Test basic security check
dart tool/security_guard.dart
```
**Expected Results:**
- [ ] CLI tool runs without errors
- [ ] Help text displays correctly
- [ ] Basic security status shows
- [ ] No crashes or exceptions

## 🛡️ Security Component Tests

### 1. Environment Checks
```bash
# Test environment checks only
dart tool/security_guard.dart --env-only --verbose
```
**Expected Results:**
- [ ] Environment checks complete
- [ ] Results displayed clearly
- [ ] No crashes or errors
- [ ] Status shows pass/fail

**Test Cases:**
- [ ] **Emulator Detection**: Run on emulator vs real device
- [ ] **Debug Mode**: Check debug vs release builds
- [ ] **Development Build**: Verify dev vs prod detection

### 2. Remote Configuration
```bash
# Test config sync only
dart tool/security_guard.dart --config-only --verbose
```
**Expected Results:**
- [ ] Config sync completes
- [ ] Default config loaded if no server
- [ ] No network errors
- [ ] Configuration displayed

**Test Cases:**
- [ ] **No Server**: App uses default config
- [ ] **With Server**: App fetches remote config
- [ ] **Network Error**: App gracefully handles failures

### 3. Device Attestation
```bash
# Test attestation only
dart tool/security_guard.dart --attestation-only --verbose
```
**Expected Results:**
- [ ] Attestation process starts
- [ ] Platform-specific checks run
- [ ] Results displayed
- [ ] No crashes

**Test Cases:**
- [ ] **Android**: Play Integrity API calls
- [ ] **iOS**: App Attest + DeviceCheck calls
- [ ] **No Server**: Graceful fallback

## 📱 Platform-Specific Tests

### Android Testing
```bash
# Test on Android device/emulator
flutter run -d android
```
**Test Cases:**
- [ ] **Real Device**: All security checks pass
- [ ] **Emulator**: Environment checks detect emulator
- [ ] **Rooted Device**: Root detection works
- [ ] **Play Integrity**: API calls succeed

### iOS Testing
```bash
# Test on iOS device/simulator
flutter run -d ios
```
**Test Cases:**
- [ ] **Real Device**: All security checks pass
- [ ] **Simulator**: Environment checks detect simulator
- [ ] **Jailbroken Device**: Jailbreak detection works
- [ ] **App Attest**: API calls succeed

## 🔄 Build Flavor Tests

### 1. Development Build (Default)
```bash
# Test default dev build
flutter run
```
**Expected Results:**
- [ ] Emulator allowed
- [ ] Rewards disabled by default
- [ ] Integrity checks relaxed
- [ ] Debug mode enabled

### 2. Development Build with Override
```bash
# Test dev build with integrity override
flutter run --dart-define=OVERRIDE_DEV_INTEGRITY=true
```
**Expected Results:**
- [ ] Emulator allowed
- [ ] Rewards enabled
- [ ] Integrity checks enforced
- [ ] Debug mode enabled

### 3. Production Build
```bash
# Test production build
flutter run --release
```
**Expected Results:**
- [ ] Emulator blocked
- [ ] Rewards enabled
- [ ] Integrity checks enforced
- [ ] Debug mode disabled

## 🌐 Network Integration Tests

### 1. Custom API Endpoint
```bash
# Test with custom API
flutter run --dart-define=API_BASE_URL=https://your-api.com
```
**Expected Results:**
- [ ] App uses custom API endpoint
- [ ] Config fetched from custom server
- [ ] No fallback to default
- [ ] Network errors handled gracefully

### 2. Network Failure Handling
```bash
# Test with invalid API endpoint
flutter run --dart-define=API_BASE_URL=https://invalid-url.com
```
**Expected Results:**
- [ ] App handles network failures
- [ ] Default config used
- [ ] No crashes
- [ ] Error logged appropriately

## 🔐 Security Enforcement Tests

### 1. Reward Blocking
```bash
# Test reward blocking on emulator
flutter run
# Try to claim a reward
```
**Expected Results:**
- [ ] Reward request blocked
- [ ] Security reason displayed
- [ ] No local credit given
- [ ] Action logged

### 2. Security Banner Display
```bash
# Test security banner on insecure device
flutter run
# Check if banner appears
```
**Expected Results:**
- [ ] Security banner shows when needed
- [ ] Banner text is clear
- [ ] Info button works
- [ ] Banner doesn't block UI

### 3. Outbox Pattern
```bash
# Test outbox operation
flutter run
# Perform an action that triggers outbox
```
**Expected Results:**
- [ ] Operation stored in outbox
- [ ] Idempotency key generated
- [ ] Server call attempted
- [ ] Retry logic works

## 📊 Monitoring Tests

### 1. Security Logs
```bash
# Check console for security logs
flutter run
# Watch console output
```
**Expected Results:**
- [ ] Security events logged
- [ ] Device fingerprint included
- [ ] Timestamps accurate
- [ ] Error details provided

### 2. Security Status
```bash
# Test security status API
dart tool/security_guard.dart --verbose
```
**Expected Results:**
- [ ] Status shows all components
- [ ] Environment status accurate
- [ ] Attestation status accurate
- [ ] Issues listed clearly

## 🧹 Cleanup Tests

### 1. App Restart
```bash
# Test app restart behavior
flutter run
# Close app completely
flutter run
```
**Expected Results:**
- [ ] Security guard reinitializes
- [ ] Previous status maintained
- [ ] No duplicate initialization
- [ ] Cache working properly

### 2. Data Persistence
```bash
# Test data persistence
flutter run
# Perform some actions
# Restart app
```
**Expected Results:**
- [ ] Security status persists
- [ ] Pending rewards maintained
- [ ] Device fingerprint cached
- [ ] Configuration cached

## 🚨 Error Handling Tests

### 1. Security Guard Failure
```bash
# Test security guard failure handling
# Modify security guard to throw error
flutter run
```
**Expected Results:**
- [ ] App continues to launch
- [ ] Error logged appropriately
- [ ] No crashes
- [ ] Graceful degradation

### 2. Network Timeout
```bash
# Test network timeout handling
# Use slow network or invalid endpoint
flutter run
```
**Expected Results:**
- [ ] Timeout handled gracefully
- [ ] Retry logic works
- [ ] Fallback config used
- [ ] User experience not blocked

## 📋 Test Results Template

### Test Run Summary
```
Date: _______________
Tester: _____________
Device: _____________
Flutter Version: _______

### Test Results
□ App Startup: PASS/FAIL
□ CLI Tool: PASS/FAIL
□ Environment Checks: PASS/FAIL
□ Remote Config: PASS/FAIL
□ Attestation: PASS/FAIL
□ Build Flavors: PASS/FAIL
□ Security Enforcement: PASS/FAIL
□ Error Handling: PASS/FAIL

### Issues Found
1. ________________
2. ________________
3. ________________

### Recommendations
1. ________________
2. ________________
3. ________________
```

## 🔍 Troubleshooting Common Issues

### 1. CLI Tool Won't Run
**Symptoms:** `dart tool/security_guard.dart` fails
**Solutions:**
- Check if `args` package is installed
- Verify file permissions
- Check Dart SDK version

### 2. Security Guard Won't Initialize
**Symptoms:** Security errors on app startup
**Solutions:**
- Check API_BASE_URL configuration
- Verify network connectivity
- Check server endpoints

### 3. Environment Checks Always Fail
**Symptoms:** All devices show as insecure
**Solutions:**
- Check platform-specific implementations
- Verify method channel setup
- Check fallback logic

### 4. App Crashes on Security Check
**Symptoms:** App crashes during security initialization
**Solutions:**
- Check try-catch blocks
- Verify null safety
- Check dependency initialization order

## ✅ Success Criteria

### Minimum Viable Testing
- [ ] App launches without crashes
- [ ] Security guard initializes
- [ ] CLI tool works
- [ ] Basic security checks run
- [ ] Build flavors work
- [ ] Error handling works

### Comprehensive Testing
- [ ] All security components tested
- [ ] Platform-specific features work
- [ ] Network integration tested
- [ ] Security enforcement verified
- [ ] Monitoring and logging work
- [ ] Cleanup and persistence work

### Production Readiness
- [ ] Security layer robust
- [ ] Performance acceptable
- [ ] Error handling comprehensive
- [ ] Logging sufficient
- [ ] Documentation complete
- [ ] Testing thorough

## 🚀 Next Steps After Testing

### 1. Fix Issues
- Address any test failures
- Improve error handling
- Enhance logging
- Optimize performance

### 2. Deploy to Test Environment
- Test on real devices
- Verify server integration
- Test production builds
- Validate security enforcement

### 3. Monitor in Production
- Watch security metrics
- Monitor blocked actions
- Track performance
- Gather user feedback

### 4. Iterate and Improve
- Refine security rules
- Optimize checks
- Add new features
- Improve user experience

## 📞 Getting Help

If you encounter issues during testing:

1. **Check Logs**: Look at console output for error details
2. **Use CLI Tool**: Run `dart tool/security_guard.dart --verbose`
3. **Review Code**: Check the security implementation files
4. **Check Dependencies**: Verify all packages are installed
5. **Test Components**: Use individual component tests to isolate issues

The security layer is designed to be robust and maintainable, with comprehensive error handling and logging to help diagnose and resolve any issues.
