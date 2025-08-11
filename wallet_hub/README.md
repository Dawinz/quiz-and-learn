# Wallet Hub

A Flutter app for managing user accounts, coin balance, withdrawals, and earning goals as part of a 5-in-1 earning ecosystem.

## Features

### 🔐 Authentication
- Email and password login/registration
- Google Sign-In integration
- Secure user profile management

### 💰 Balance Management
- Real-time coin balance display
- Transaction history tracking
- Secure balance updates via Cloud Functions

### 💸 Withdrawals
- Multiple payment methods:
  - M-Pesa
  - Tigo Pesa
  - Airtel Money
  - HaloPesa
  - USDT (TRC20)
- Manual withdrawal requests with admin approval
- Withdrawal history tracking

### 📊 Goals & Progress
- Set weekly and monthly earning targets
- Visual progress tracking
- Daily task recommendations
- Goal achievement monitoring

### 🔔 Notifications
- Push notifications for withdrawal updates
- Goal reminders
- Transaction notifications

## Tech Stack

- **Frontend**: Flutter 3.8+
- **Backend**: Firebase
  - Authentication
  - Firestore Database
  - Cloud Functions
  - Cloud Messaging
- **State Management**: Provider
- **UI**: Material Design with custom theming

## Project Structure

```
lib/
├── constants/
│   └── app_constants.dart      # App-wide constants and styling
├── models/
│   ├── user_model.dart         # User data model
│   ├── transaction_model.dart  # Transaction data model
│   └── withdrawal_model.dart   # Withdrawal request model
├── providers/
│   └── auth_provider.dart      # Authentication state management
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart   # Login screen
│   │   └── register_screen.dart # Registration screen
│   └── main/
│       ├── home_screen.dart    # Main dashboard
│       ├── transactions_screen.dart # Transaction history
│       ├── goals_screen.dart   # Goals and progress
│       ├── settings_screen.dart # User settings
│       └── withdrawal_screen.dart # Withdrawal requests
├── services/
│   └── firebase_service.dart   # Firebase operations
└── main.dart                   # App entry point
```

## Setup Instructions

### Prerequisites

1. **Flutter SDK**: Install Flutter 3.8+ from [flutter.dev](https://flutter.dev)
2. **Firebase Project**: Create a Firebase project at [firebase.google.com](https://firebase.google.com)
3. **Development Environment**: Android Studio, VS Code, or your preferred IDE

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd wallet_hub
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**

   a. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create a new project
   - Enable Authentication, Firestore, and Cloud Functions

   b. **Add Android App**
   - In Firebase Console, go to Project Settings
   - Add Android app with package name: `com.example.wallet_hub`
   - Download `google-services.json` and place it in `android/app/`

   c. **Add iOS App** (if developing for iOS)
   - Add iOS app with bundle ID: `com.example.walletHub`
   - Download `GoogleService-Info.plist` and place it in `ios/Runner/`

   d. **Enable Authentication Methods**
   - Go to Authentication > Sign-in method
   - Enable Email/Password
   - Enable Google Sign-In (configure OAuth consent screen)

   e. **Set up Firestore Database**
   - Go to Firestore Database
   - Create database in production mode
   - Set up security rules (see below)

   f. **Configure Cloud Functions** (optional)
   - Install Firebase CLI: `npm install -g firebase-tools`
   - Initialize functions: `firebase init functions`
   - Deploy functions: `firebase deploy --only functions`

4. **Update Firebase Configuration**

   Create `lib/firebase_options.dart` (or use Firebase CLI to generate):
   ```dart
   import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
   import 'package:flutter/foundation.dart'
       show defaultTargetPlatform, kIsWeb, TargetPlatform;

   class DefaultFirebaseOptions {
     static FirebaseOptions get currentPlatform {
       // Add your Firebase configuration here
       // Generated from Firebase Console
     }
   }
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## Firebase Security Rules

### Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Transactions - users can only access their own
    match /transactions/{transactionId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // Withdrawals - users can only access their own
    match /withdrawals/{withdrawalId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

### Cloud Functions (Optional)

Create functions for secure balance updates:

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.updateBalance = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  const { userId, amount, type } = data;
  
  // Validate user owns the account
  if (context.auth.uid !== userId) {
    throw new functions.https.HttpsError('permission-denied', 'Unauthorized');
  }
  
  const userRef = admin.firestore().collection('users').doc(userId);
  
  return admin.firestore().runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);
    const currentBalance = userDoc.data().balance.coins || 0;
    
    let newBalance;
    if (type === 'earning') {
      newBalance = currentBalance + amount;
    } else if (type === 'spending' || type === 'withdrawal') {
      newBalance = currentBalance - amount;
    } else {
      throw new functions.https.HttpsError('invalid-argument', 'Invalid transaction type');
    }
    
    if (newBalance < 0) {
      throw new functions.https.HttpsError('failed-precondition', 'Insufficient balance');
    }
    
    transaction.update(userRef, {
      'balance.coins': newBalance
    });
    
    return { success: true, newBalance };
  });
});
```

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

## Environment Variables

Create a `.env` file in the project root (optional):

```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key
```

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

For support, email support@wallethub.com or create an issue in the repository.

## Changelog

### v1.0.0
- Initial release
- User authentication
- Balance management
- Withdrawal system
- Goals tracking
- Transaction history
