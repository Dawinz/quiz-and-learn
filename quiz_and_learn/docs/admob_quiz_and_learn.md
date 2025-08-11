# AdMob Integration - Quiz & Learn App

## Overview
This document outlines the Google Mobile Ads (AdMob) integration for the Quiz & Learn app, including ad unit IDs, placement strategies, and implementation details.

## AdMob IDs

### Android
- **App ID**: `ca-app-pub-6181092189054832~7096810595`
- **Rewarded Video**: `ca-app-pub-6181092189054832/9985847751` (Reward: +10 coins)
- **Interstitial**: `ca-app-pub-6181092189054832/7351945552`
- **Banner**: `ca-app-pub-6181092189054832/6857121530`
- **Native**: `ca-app-pub-6181092189054832/9505118560`

### iOS
- **App ID**: `ca-app-pub-6181092189054832~6038879798`
- **Rewarded Video**: `ca-app-pub-6181092189054832/9814457364` (Reward: +10 coins)
- **Interstitial**: `ca-app-pub-6181092189054832/2068679347`
- **Banner**: `ca-app-pub-6181092189054832/5160896483`
- **Native**: Not provided — not implemented on iOS

## Ad Placements

### 1. Rewarded Video
- **Location**: User-initiated actions (e.g., "Watch & Earn" button)
- **Trigger**: Results screen, dedicated earn screen, or user choice
- **Reward**: +10 coins upon successful completion
- **Frequency**: Unlimited (user-controlled)

### 2. Interstitial
- **Location**: Between quiz levels, navigation back to category list
- **Trigger**: Level completion, category navigation
- **Frequency Capping**: Maximum once every 3 minutes, max 5 per session
- **Behavior**: Non-blocking, respects back-press

### 3. Banner
- **Location**: Bottom-fixed on quiz screens, home/landing
- **Sizes**: 320x50 (mobile), 728x90 (tablet)
- **Behavior**: Stable positioning, no layout shift, no overlap with controls

### 4. Native (Android Only)
- **Location**: Quiz results screen
- **Styling**: Brand-consistent, non-deceptive
- **Platform**: Android only (gracefully skipped on iOS)

## Implementation Details

### Configuration
- All ad IDs stored in `config/admob_config.json`
- No hardcoded IDs in UI components
- Environment-based test mode activation

### Ad Managers
- **RewardedAdManager**: Handles rewarded video lifecycle
- **InterstitialAdManager**: Manages interstitial with frequency capping
- **BannerAdManager**: Provides banner widgets
- **NativeAdManager**: Android-only native ad handling

### Integration Points
- **Wallet Service**: Coin rewards triggered by ad completion
- **Navigation**: Interstitial ads between major screen transitions
- **User Actions**: Rewarded ads for bonus coin opportunities

## Policy Compliance

### Google AdMob Policies
- No accidental clicks or deceptive overlays
- Clear ad labeling and non-intrusive placement
- Respect for user navigation and back-press
- Proper ad loading states and fallbacks

### User Experience
- Ads don't gate core navigation
- Clear indication when ads are loading
- Graceful fallbacks when ads fail to load
- Consistent reward delivery

## Testing & Development

### Test Mode
- Automatically enabled in debug builds
- Uses test ad unit IDs
- Safe for development and testing

### Production Mode
- Real ad unit IDs
- Proper analytics and monitoring
- Compliance verification

## Maintenance

### Configuration Updates
- Modify `config/admob_config.json` for ID changes
- Update documentation when new ad units added
- Version control for configuration changes

### Monitoring
- Ad load success/failure rates
- User engagement metrics
- Revenue tracking
- Policy compliance monitoring

## File Structure
```
quiz_and_learn/
├── config/
│   └── admob_config.json          # AdMob configuration
├── lib/
│   ├── services/
│   │   ├── ad_managers/           # Ad manager classes
│   │   └── wallet_service.dart    # Coin management
│   └── screens/                   # UI integration
└── docs/
    └── admob_quiz_and_learn.md    # This documentation
```
