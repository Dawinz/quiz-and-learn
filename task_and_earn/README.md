# 📋 Task & Earn

A Flutter application that allows users to complete educational tasks and earn rewards.

## 🚀 Features

- **Task Management**: Complete various educational tasks
- **Progress Tracking**: Monitor your task completion progress
- **Reward System**: Earn coins for completed tasks
- **User Authentication**: Secure login and registration
- **Profile Management**: Manage your account and preferences
- **AdMob Integration**: Monetization through ads

## 🛠️ Technology Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Node.js with Express
- **Database**: MongoDB
- **Authentication**: JWT
- **Ads**: Google AdMob

## 📋 Prerequisites

- Flutter SDK (3.0.0 or higher)
- Node.js (18.0.0 or higher)
- MongoDB
- Xcode (for iOS development)
- Android Studio (for Android development)

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone <repository-url>
cd task_and_earn
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Backend
Make sure the backend server is running:
```bash
cd ../backend
npm install
cp env.example .env
# Configure your .env file
npm start
```

### 4. Run the App
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
│   └── app_constants.dart
├── models/
│   └── user_model.dart
├── providers/
│   └── auth_provider.dart
├── screens/
│   ├── auth/
│   │   └── login_screen.dart
│   ├── main/
│   │   └── home_screen.dart
│   ├── tasks/
│   ├── wallet/
│   ├── referrals/
│   └── profile/
├── services/
│   └── api_service.dart
├── widgets/
└── main.dart
```

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the backend directory:
```env
MONGO_URI=mongodb://localhost:27017/task_and_earn
JWT_SECRET=your_jwt_secret
JWT_EXPIRES_IN=7d
PORT=3001
NODE_ENV=development
```

### API Configuration
Update the API base URL in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://localhost:3001/api';
```

## 📊 Features

### Authentication
- Email/password registration and login
- JWT token-based authentication
- Secure password handling

### Task Management
- Browse available tasks
- Complete tasks and earn rewards
- Track completion progress
- Task categories and difficulty levels

### Wallet Integration
- View current balance
- Track earnings from tasks
- Transaction history

### User Profile
- Update personal information
- View statistics and achievements
- Manage account settings

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

### Backend Deployment
Deploy to your preferred hosting service:
- Vercel
- Heroku
- DigitalOcean
- AWS

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

## 📝 API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get user profile

### Tasks
- `GET /api/tasks` - Get available tasks
- `GET /api/tasks/:id` - Get task details
- `POST /api/tasks/:id/complete` - Complete a task

### Wallet
- `GET /api/wallet/balance` - Get wallet balance
- `GET /api/wallet/transactions` - Get transaction history

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 📞 Support

For support and questions, please open an issue in the repository.
