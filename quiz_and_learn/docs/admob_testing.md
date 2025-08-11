# AdMob Testing Guide - Quiz & Learn App

## Overview
This guide provides step-by-step instructions for testing the AdMob integration in the Quiz & Learn app.

## Prerequisites
- Flutter development environment set up
- iOS Simulator or Android Emulator running
- App successfully built and running

## Test Mode Configuration
The app is configured to use test ads by default in debug builds. This ensures:
- Safe testing without affecting real ad metrics
- Consistent test ad content
- No risk of policy violations during development

## Testing Checklist

### 1. App Initialization
- [ ] App launches without crashes
- [ ] AdMob service initializes successfully
- [ ] Configuration loads correctly
- [ ] Test mode is active (check console logs)

### 2. Rewarded Video Ads
**Test Steps:**
1. Launch the app and navigate to the home screen
2. Look for the "Watch Ad & Earn +10 Coins" button
3. Tap the button to trigger a rewarded video ad
4. Watch the entire ad (test ads are usually 15-30 seconds)
5. Verify that +10 coins are added to the wallet
6. Check that the button shows a cooldown timer

**Expected Results:**
- Ad loads and displays properly
- User can watch the full ad
- Coins are awarded upon completion
- Button shows cooldown after watching
- No crashes or errors

### 3. Banner Ads
**Test Steps:**
1. Navigate to the home screen
2. Look for a banner ad at the bottom of the screen
3. Verify the ad displays without overlapping content
4. Check that the ad is properly sized and positioned

**Expected Results:**
- Banner ad appears at bottom of screen
- No layout shifts or overlapping content
- Ad is properly sized for the device
- No crashes when ad loads

### 4. Interstitial Ads
**Test Steps:**
1. Complete a quiz or navigate between screens
2. Interstitial ads should appear based on frequency capping
3. Verify the ad displays full screen
4. Test back button behavior
5. Check frequency capping (max 1 every 3 minutes, max 5 per session)

**Expected Results:**
- Interstitial appears at appropriate times
- Ad displays full screen without issues
- Back button works correctly
- Frequency capping is respected
- No excessive ad frequency

### 5. Native Ads (Android Only)
**Test Steps:**
1. On Android device/emulator, navigate to results screen
2. Look for native ad content
3. Verify ad styling matches app design
4. Check that native ads are skipped on iOS

**Expected Results:**
- Native ads display on Android
- Ads are properly styled and non-deceptive
- Native ads are gracefully skipped on iOS
- No layout issues or crashes

## Console Logs to Monitor

### Successful Initialization
```
Initializing AdMob service...
AdMob service initialized successfully
=== AdMob Configuration Info ===
Platform: ios/android
App ID: ca-app-pub-6181092189054832~...
Test Mode: true
Rewarded Ad Unit ID: ca-app-pub-...
================================
```

### Ad Loading
```
Loading rewarded ad with ID: ca-app-pub-3940256099942544/...
Rewarded ad loaded successfully
```

### Ad Events
```
Showing rewarded ad
User earned reward: 10 coins
Rewarded ad dismissed
```

## Troubleshooting

### Common Issues

**1. Ads Not Loading**
- Check internet connection
- Verify AdMob configuration is valid
- Ensure test mode is enabled for development
- Check console for error messages

**2. App Crashes on Ad Load**
- Verify AdMob SDK is properly initialized
- Check platform-specific configuration
- Ensure ad unit IDs are correct
- Review crash logs for specific errors

**3. Rewarded Ads Not Awarding Coins**
- Check wallet service initialization
- Verify reward amount configuration
- Ensure ad completion callback is triggered
- Check for timing issues with reward delivery

**4. Banner Ads Not Displaying**
- Verify banner ad unit ID is configured
- Check ad loading status
- Ensure proper widget integration
- Verify no layout conflicts

### Debug Commands

**Check AdMob Status:**
```dart
// Add this to any screen for debugging
final status = AdMobService.instance.status;
print('AdMob Status: $status');
```

**Check Wallet Status:**
```dart
// Add this to any screen for debugging
final walletStatus = WalletService.instance.statistics;
print('Wallet Status: $walletStatus');
```

**Force Ad Reload:**
```dart
// Force reload all ads
await AdMobService.instance.rewarded.loadAd();
await AdMobService.instance.interstitial.loadAd();
await AdMobService.instance.banner.loadAd();
```

## Production Testing

### Before Release
1. Set `test_mode: false` in `config/admob_config.json`
2. Verify real ad unit IDs are being used
3. Test on real devices (not just simulators)
4. Verify ad performance and user experience
5. Check compliance with AdMob policies

### Production Checklist
- [ ] Real ad unit IDs configured
- [ ] Test mode disabled
- [ ] Ads loading successfully
- [ ] No crashes or errors
- [ ] User experience is smooth
- [ ] Policy compliance verified
- [ ] Analytics tracking enabled

## Performance Monitoring

### Key Metrics to Track
- Ad load success rate
- Ad display completion rate
- User engagement with ads
- Revenue per user
- App performance impact

### Recommended Tools
- Firebase Analytics
- AdMob Console
- Flutter Performance Profiler
- Crash reporting tools

## Support

If you encounter issues:
1. Check the console logs for error messages
2. Verify configuration settings
3. Test with different devices/emulators
4. Review AdMob documentation
5. Check Flutter and google_mobile_ads package versions
