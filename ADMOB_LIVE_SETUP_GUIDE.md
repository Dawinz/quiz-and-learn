# AdMob Live Setup Guide

## 🚀 **Setting Up Live Ad Units**

### **Step 1: Create AdMob Account**

1. **Go to AdMob Console**: https://admob.google.com/
2. **Sign in** with your Google account
3. **Create a new app** or link existing app

### **Step 2: Create Live Ad Units**

#### **Banner Ad Unit**
1. **Navigate to**: AdMob Console → Apps → Your App → Ad Units
2. **Click**: "Create Ad Unit"
3. **Select**: "Banner"
4. **Configure**:
   - **Name**: "Spin & Earn Banner"
   - **Size**: Banner (320x50)
   - **Format**: Standard Banner
5. **Copy the Ad Unit ID** (format: `ca-app-pub-XXXXXXXXXX/YYYYYYYYYY`)

#### **Rewarded Ad Unit**
1. **Click**: "Create Ad Unit"
2. **Select**: "Rewarded"
3. **Configure**:
   - **Name**: "Spin & Earn Rewarded"
   - **Reward**: 1 spin
   - **Reward Type**: Custom
4. **Copy the Ad Unit ID**

#### **Rewarded Interstitial Ad Unit**
1. **Click**: "Create Ad Unit"
2. **Select**: "Rewarded Interstitial"
3. **Configure**:
   - **Name**: "Spin & Earn Rewarded Interstitial"
   - **Reward**: 5 coins
   - **Reward Type**: Custom
4. **Copy the Ad Unit ID**

### **Step 3: Update Code with Live Ad Unit IDs**

#### **Update AdMob Service**
```dart
// lib/services/admob_service.dart
class AdMobService {
  // Replace these with your live ad unit IDs
  static const String _androidRewardedAdUnitId = 'YOUR_LIVE_REWARDED_AD_UNIT_ID';
  static const String _androidRewardedInterstitialAdUnitId = 'YOUR_LIVE_REWARDED_INTERSTITIAL_AD_UNIT_ID';
  static const String _androidBannerAdUnitId = 'YOUR_LIVE_BANNER_AD_UNIT_ID';
}
```

#### **Example with Real IDs**
```dart
// Example (replace with your actual IDs)
static const String _androidRewardedAdUnitId = 'ca-app-pub-6181092189054832/5896249880';
static const String _androidRewardedInterstitialAdUnitId = 'ca-app-pub-6181092189054832/5879922109';
static const String _androidBannerAdUnitId = 'ca-app-pub-6181092189054832/1234567890'; // Replace this
```

### **Step 4: Test Live Ads**

#### **Testing Checklist**
- [ ] Banner ads load correctly
- [ ] Rewarded ads show properly
- [ ] Rewards are granted after ad completion
- [ ] Error handling works for failed ads
- [ ] Ad loading states display correctly

#### **Testing Commands**
```bash
# Build and test the app
cd spin_and_earn
flutter build apk --debug
flutter run --debug
```

### **Step 5: Production Deployment**

#### **Build for Production**
```bash
# Android
flutter build apk --release

# iOS (when implementing)
flutter build ios --release
```

#### **Update App Store/Play Store**
1. **Upload** the production APK/IPA
2. **Update** app description to mention ads
3. **Comply** with store policies regarding ads

## 🔧 **Configuration Details**

### **Current Test IDs**
```dart
// Current test configuration
static const String _androidRewardedAdUnitId = 'ca-app-pub-6181092189054832/5896249880';
static const String _androidRewardedInterstitialAdUnitId = 'ca-app-pub-6181092189054832/5879922109';
static const String _androidBannerAdUnitId = 'ca-app-pub-6181092189054832/1234567890'; // PLACEHOLDER
```

### **Live IDs Format**
```dart
// Expected live format
static const String _androidRewardedAdUnitId = 'ca-app-pub-XXXXXXXXXX/YYYYYYYYYY';
static const String _androidRewardedInterstitialAdUnitId = 'ca-app-pub-XXXXXXXXXX/ZZZZZZZZZZ';
static const String _androidBannerAdUnitId = 'ca-app-pub-XXXXXXXXXX/WWWWWWWWWW';
```

## 📊 **Revenue Optimization**

### **Ad Placement Strategy**
- **Banner Ads**: Bottom of spin screen (non-intrusive)
- **Rewarded Ads**: When user runs out of spins (high engagement)
- **Rewarded Interstitial**: Bonus rewards (future implementation)

### **User Experience**
- **Clear Value**: Users understand they get extra spins
- **Non-Intrusive**: Ads don't disrupt core gameplay
- **Reliable**: Consistent ad loading and reward delivery

### **Performance Monitoring**
- **AdMob Console**: Monitor revenue and performance
- **User Analytics**: Track ad engagement rates
- **A/B Testing**: Test different ad placements

## ⚠️ **Important Notes**

### **Testing vs Production**
- **Test IDs**: Use during development
- **Live IDs**: Use for production release
- **Never mix**: Test and live IDs in same build

### **Store Compliance**
- **Google Play**: Follow AdMob policies
- **App Store**: Comply with Apple's ad guidelines
- **User Privacy**: Respect user data and consent

### **Revenue Tracking**
- **AdMob Reports**: Monitor daily/weekly revenue
- **User Retention**: Ensure ads don't hurt retention
- **Performance**: Optimize based on data

## 🎯 **Success Metrics**

### **Key Performance Indicators**
- **Ad Fill Rate**: Percentage of ad requests filled
- **Click-Through Rate**: User engagement with ads
- **Revenue per User**: Average revenue per active user
- **User Retention**: Impact of ads on user retention

### **Expected Results**
- **Banner Ads**: 60-80% fill rate
- **Rewarded Ads**: 90%+ completion rate
- **Revenue**: $0.50-$2.00 per user per month
- **Retention**: Minimal impact on user retention

## ✅ **Final Checklist**

### **Before Production**
- [ ] Replace all test ad unit IDs with live ones
- [ ] Test ad functionality thoroughly
- [ ] Verify Cloud Functions are deployed
- [ ] Check ad loading and error handling
- [ ] Monitor initial ad performance

### **After Launch**
- [ ] Monitor revenue in AdMob Console
- [ ] Track user engagement metrics
- [ ] Optimize ad placement based on data
- [ ] Address any user feedback about ads
- [ ] Scale based on performance data

## 🚀 **Next Steps**

1. **Create live ad units** in AdMob Console
2. **Replace test IDs** with live ones
3. **Test thoroughly** before production
4. **Deploy to app stores** with live ads
5. **Monitor and optimize** based on performance

**Status**: Ready for live ad unit setup and production deployment! 🎉 