# 💰 Wallet Hub

A Flutter application for digital wallet management with AdMob integration for monetization.

## 🚀 Features

- **Digital Wallet**: Manage your digital currency and transactions
- **AdMob Integration**: Banner, interstitial, and rewarded ads
- **Transaction History**: Track all your financial activities
- **User Authentication**: Secure login and registration
- **Balance Management**: Monitor and manage your funds

## 🛠️ Technology Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Node.js with Express
- **Database**: MongoDB
- **Ads**: Google AdMob

## 📋 Prerequisites

- Flutter SDK (3.0.0 or higher)
- Node.js (18.0.0 or higher)
- MongoDB
- Xcode (for iOS development)
- Android Studio (for Android development)

## 🚀 Quick Start

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure Backend
Make sure the backend server is running:
```bash
cd ../backend
npm install
cp env.example .env
# Configure your .env file
npm start
```

### 3. Run the App
```bash
# For iOS
flutter run -d ios

# For Android
flutter run -d android

# For web
flutter run -d chrome
```

## 📱 App Structure

```
lib/
├── constants/
├── models/
├── providers/
├── screens/
│   ├── auth/
│   ├── main/
│   ├── wallet/
│   └── profile/
├── services/
├── widgets/
└── main.dart
```

## 🔧 Configuration

### AdMob Configuration
Update AdMob settings in `lib/config/admob_config.dart`:
```dart
class AdMobConfig {
  static const String bannerAdUnitId = 'your_banner_ad_unit_id';
  static const String interstitialAdUnitId = 'your_interstitial_ad_unit_id';
  static const String rewardedAdUnitId = 'your_rewarded_ad_unit_id';
}
```

### API Configuration
Update the API base URL in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://localhost:3001/api';
```

## 📊 Features

### Wallet Management
- View current balance
- Track transaction history
- Manage multiple currencies
- Set financial goals

### AdMob Integration
- Banner ads at the bottom
- Interstitial ads between screens
- Rewarded ads for bonuses
- Test mode for development

### User Management
- Registration and login
- Profile management
- Security settings
- Transaction notifications

## 🚀 Deployment

### iOS Deployment
1. Build the app:
   ```bash
   flutter build ios --release
   ```
2. Open in Xcode and configure signing
3. Upload to App Store Connect

### Android Deployment
1. Build the app:
   ```bash
   flutter build appbundle --release
   ```
2. Upload to Google Play Console

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

## 📄 License

This project is licensed under the MIT License.

## 📞 Support

For support and questions, please open an issue in the repository.
