# Spin & Earn

A Flutter mini-app in the 5-in-1 earning ecosystem that allows users to earn coins by spinning a wheel. Connects to the same Firebase project as Wallet Hub for seamless user experience.

## Features

### 🎰 Spin Wheel Game
- Animated spin wheel with colorful segments
- Random reward generation (5-100 coins)
- Daily spin limits (5 free spins per day)
- Real-time balance updates

### 🔐 Authentication
- Same Firebase project as Wallet Hub
- Email/password and Google Sign-In
- Automatic user profile sync from Wallet Hub
- Seamless cross-app authentication

### 💰 Rewards System
- Secure coin balance updates via Cloud Functions
- Transaction history tracking
- Real-time sync with Wallet Hub balance
- Reward probability distribution (40% 5 coins, 30% 10 coins, 20% 20 coins, 8% 50 coins, 2% 100 coins)

### 📱 Modern UI
- Playful and engaging design
- Smooth animations and transitions
- Bottom navigation with 3 main sections
- Responsive layout

## Tech Stack

- **Frontend**: Flutter 3.8+
- **Backend**: Firebase (shared with Wallet Hub)
  - Authentication
  - Firestore Database
  - Cloud Functions
- **State Management**: Provider
- **UI**: Material Design with custom theming
- **Ads**: AdMob (Banner ads, Rewarded ads for extra spins)

## Project Structure

```
lib/
├── constants/
│   └── app_constants.dart      # App styling & spin wheel config
├── models/
│   ├── user_model.dart         # User data with spin info
│   └── spin_reward_model.dart  # Spin reward tracking
├── providers/
│   └── auth_provider.dart      # Authentication & user state
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart   # Login screen
│   │   └── register_screen.dart # Registration screen
│   └── main/
│       └── home_screen.dart    # Main app with spin wheel
├── services/
│   └── firebase_service.dart   # Firebase operations
└── main.dart                   # App entry point
```

## Setup Instructions

### Prerequisites

1. **Flutter SDK**: Install Flutter 3.8+ from [flutter.dev](https://flutter.dev)
2. **Firebase Project**: Use the same Firebase project as Wallet Hub
3. **Development Environment**: Android Studio, VS Code, or your preferred IDE

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd spin_and_earn
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**

   **Important**: This app uses the same Firebase project as Wallet Hub. Ensure you have:
   - The same `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files
   - Firebase project configured with Authentication, Firestore, and Cloud Functions
   - Firestore security rules that allow spin-related operations

   a. **Copy Firebase Config Files**
   - Copy `google-services.json` from Wallet Hub to `android/app/`
   - Copy `GoogleService-Info.plist` from Wallet Hub to `ios/Runner/`

   b. **Verify Firestore Schema**
   - Ensure the `users` collection has the `spins` field structure
   - Verify `transactions` collection accepts spin rewards

4. **AdMob Configuration**

   **Android Setup**:
   - AdMob App ID is already configured in `android/app/src/main/AndroidManifest.xml`
   - Rewarded Ad Unit ID: `ca-app-pub-6181092189054832/5896249880`
   - Rewarded Interstitial Ad Unit ID: `ca-app-pub-6181092189054832/5879922109`
   - Banner Ad Unit ID: `ca-app-pub-6181092189054832/1234567890` (placeholder)

   **iOS Setup** (when implementing iOS):
   - Add iOS App ID to `ios/Runner/Info.plist`
   - Replace placeholder iOS ad unit IDs in `lib/services/admob_service.dart`

   **AdMob Features**:
   - Banner ads displayed at bottom of spin screen
   - Rewarded ads for extra spins when daily limit is reached
   - Secure reward processing via Cloud Functions
   - Automatic ad loading and error handling

5. **Run the app**
   ```bash
   flutter run
   ```

## AdMob Integration

### Current Implementation

The app includes comprehensive AdMob integration with the following features:

#### Banner Ads
- Displayed at the bottom of the spin screen
- Automatic loading and error handling
- Responsive design integration

#### Rewarded Ads
- Triggered when user runs out of daily spins
- Secure reward processing via Cloud Functions
- Extra spin granted after watching ad
- Automatic ad reloading after completion

#### AdMob Service (`lib/services/admob_service.dart`)
- Singleton pattern for ad management
- Platform-specific ad unit ID handling
- Comprehensive error handling and logging
- Automatic ad lifecycle management

### Replacing Test Ad Unit IDs

**For Production Deployment**:

1. **Android Banner Ad**:
   - Replace `ca-app-pub-6181092189054832/1234567890` in `lib/services/admob_service.dart`
   - Create a new banner ad unit in AdMob Console
   - Update the `_androidBannerAdUnitId` constant

2. **iOS Ad Unit IDs** (when implementing iOS):
   - Replace placeholder iOS ad unit IDs in `lib/services/admob_service.dart`
   - Add iOS App ID to `ios/Runner/Info.plist`
   - Create iOS ad units in AdMob Console

3. **Testing**:
   - Use test ad unit IDs during development
   - Switch to live ad unit IDs before production release
   - Test ad functionality thoroughly before deployment

### Cloud Functions Integration

The rewarded ad system uses Cloud Functions for secure reward processing:

- **`handleRewardedAdSpin`**: Processes extra spins from rewarded ads
- **Security**: Validates user authentication and prevents tampering
- **Transaction Tracking**: Records ad-based rewards in Firestore
- **Error Handling**: Comprehensive error handling and user feedback

## Firebase Schema

### Users Collection (extends Wallet Hub schema)
```javascript
users/{userId}
├── profile: { name, email, phone }
├── balance: { coins: 0 }
├── goals: { weeklyTarget, monthlyTarget, progress }
└── spins: { 
    dailyUsed: 0, 
    dailyLimit: 5, 
    lastSpinDate: null 
}
```

### Transactions Collection
```javascript
transactions/{transactionId}
├── userId: string
├── type: "earning"
├── amount: number
├── date: timestamp
├── source: "Spin & Earn"
└── description: string (optional)
```

## Cloud Functions

Create a Cloud Function for secure balance updates:

```javascript
// functions/index.js
exports.updateBalanceAfterSpin = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  const { userId, amount, source } = data;
  
  // Validate user owns the account
  if (context.auth.uid !== userId) {
    throw new functions.https.HttpsError('permission-denied', 'Unauthorized');
  }
  
  const userRef = admin.firestore().collection('users').doc(userId);
  
  return admin.firestore().runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);
    const currentBalance = userDoc.data().balance.coins || 0;
    const newBalance = currentBalance + amount;
    
    transaction.update(userRef, {
      'balance.coins': newBalance
    });
    
    return { success: true, newBalance };
  });
});
```

## AdMob Configuration

The app is configured for AdMob but ads are not implemented. To add rewarded ads:

1. **Update AdMobConfig in app_constants.dart**
   ```dart
   static const String androidRewardedAdUnitId = 'your-ad-unit-id';
   static const String iosRewardedAdUnitId = 'your-ad-unit-id';
   ```

2. **Implement rewarded ad logic in home_screen.dart**
   - Load rewarded ad
   - Show ad when user taps "Watch Ad for Extra Spin"
   - Grant extra spin on successful ad view

## Build Instructions

### Android

1. **Generate APK**
   ```bash
   flutter build apk --release
   ```

2. **Generate App Bundle**
   ```bash
   flutter build appbundle --release
   ```

### iOS

1. **Build for iOS**
   ```bash
   flutter build ios --release
   ```

2. **Archive in Xcode**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select Product > Archive
   - Upload to App Store Connect

## Integration with Wallet Hub

### Shared Authentication
- Users log in with the same credentials across both apps
- User profiles are automatically synced
- Balance updates are reflected in real-time

### Data Flow
1. User spins wheel in Spin & Earn
2. Reward is calculated and added to balance via Cloud Function
3. Transaction is logged in Firestore
4. Balance update is reflected immediately in Wallet Hub
5. User can withdraw earned coins through Wallet Hub

### Security
- All balance updates go through Cloud Functions
- No client-side coin manipulation
- Firestore security rules prevent unauthorized access
- User can only access their own data

## Testing

Run tests with:
```bash
flutter test
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email support@spinandearn.com or create an issue in the repository.

## Changelog

### v1.0.0
- Initial release
- Spin wheel game with animations
- Daily spin limits
- Real-time balance sync with Wallet Hub
- Transaction history
- User authentication integration
