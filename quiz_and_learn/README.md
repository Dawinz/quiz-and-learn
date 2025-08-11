# Quiz & Learn App

A Flutter application that allows users to take quizzes, earn coins, and learn through interactive content. The app includes a complete authentication system, user management, and quiz functionality.

## Features

### ✅ Authentication System
- User registration with email and password
- User login with email and password
- Secure token-based authentication
- Password validation and security

### ✅ User Management
- User profiles with personal information
- Referral system with unique referral codes
- Coin earning and tracking system
- User statistics and progress tracking

### ✅ Quiz System
- Multiple quiz categories (General, Science, History)
- Different difficulty levels (Easy, Medium, Hard)
- Question-based learning with multiple choice answers
- Score tracking and coin rewards
- Time-based quiz completion

### ✅ Wallet System
- Coin balance tracking
- Transaction history
- Referral bonuses
- Quiz completion rewards

### ✅ Demo Mode
- Fully functional demo without backend
- Simulated data and responses
- Perfect for testing and development
- Easy switch to production mode

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code
- Android Emulator or Physical Device

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd quiz_and_learn
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Usage

### Demo Mode (Default)
The app runs in demo mode by default, which means:
- All features are fully functional
- No backend server required
- Data is simulated locally
- Perfect for testing and development

### Switching to Production Mode
To use with a real backend:

1. Set up a backend server (see `BACKEND_SETUP.md`)
2. Update the API URL in `lib/services/api_service.dart`:
   ```dart
   static const String baseUrl = "https://your-backend-domain.com/api";
   ```
3. Set `_useDemoMode = false` in the same file

## App Structure

```
lib/
├── constants/
│   └── app_constants.dart      # App colors, text styles, and sizes
├── models/
│   └── user_model.dart         # User data model
├── providers/
│   └── auth_provider.dart      # Authentication state management
├── screens/
│   ├── auth/
│   │   └── login_screen.dart   # Login and registration screen
│   └── main/
│       └── home_screen.dart    # Main app home screen
├── services/
│   ├── api_service.dart        # API communication service
│   └── demo_service.dart       # Demo mode service
└── main.dart                   # App entry point
```

## Key Components

### Authentication Provider
- Manages user authentication state
- Handles login, registration, and logout
- Provides user data to the app
- Manages loading states and errors

### API Service
- Handles all backend communication
- Supports both real API and demo mode
- Manages authentication tokens
- Handles error responses

### Demo Service
- Simulates backend functionality
- Provides realistic data for testing
- Includes network delay simulation
- Supports all app features

## Testing the App

### Login/Registration
1. Open the app
2. Enter any valid email and password (6+ characters)
3. For registration, provide a name
4. Optional: Enter a referral code
5. Submit the form

### Demo Data
The demo mode provides:
- Sample user with 150 coins
- 5 referral count
- 3 sample quizzes
- Sample transaction history

### Features to Test
- User authentication flow
- Profile information display
- Coin balance and statistics
- Quiz browsing (coming soon)
- Referral system

## Customization

### Colors and Themes
Update `lib/constants/app_constants.dart` to customize:
- App colors
- Text styles
- Sizes and spacing
- Background colors

### Demo Data
Modify `lib/services/demo_service.dart` to change:
- Sample user information
- Quiz content
- Coin amounts
- Referral data

### API Configuration
Update `lib/services/api_service.dart` to:
- Change backend URL
- Modify timeout settings
- Add custom headers
- Handle specific error cases

## Troubleshooting

### Common Issues

1. **App won't start**
   - Ensure Flutter is properly installed
   - Run `flutter doctor` to check setup
   - Clear build cache: `flutter clean`

2. **Authentication not working**
   - Check if demo mode is enabled
   - Verify form validation
   - Check console for error messages

3. **UI not displaying correctly**
   - Ensure all dependencies are installed
   - Check for Flutter version compatibility
   - Verify device/emulator compatibility

### Debug Mode
The app includes extensive logging in debug mode:
- Authentication attempts
- API responses
- Error details
- User actions

## Development

### Adding New Features
1. Create new models in `lib/models/`
2. Add API methods in `lib/services/api_service.dart`
3. Create corresponding demo methods in `lib/services/demo_service.dart`
4. Update providers for state management
5. Create UI screens in `lib/screens/`

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable names
- Include proper error handling
- Add comments for complex logic

## Deployment

### Android
1. Update `android/app/build.gradle` version
2. Configure signing keys
3. Build APK: `flutter build apk --release`
4. Build App Bundle: `flutter build appbundle --release`

### iOS
1. Update `ios/Runner/Info.plist` version
2. Configure signing certificates
3. Build: `flutter build ios --release`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Check the troubleshooting section
- Review the backend setup guide
- Open an issue on GitHub
- Contact the development team

## Roadmap

### Upcoming Features
- [ ] Quiz taking functionality
- [ ] Progress tracking
- [ ] Leaderboards
- [ ] Social features
- [ ] Offline mode
- [ ] Push notifications

### Future Enhancements
- [ ] Multiple languages
- [ ] Dark mode
- [ ] Custom themes
- [ ] Advanced analytics
- [ ] Admin panel
- [ ] Content management system
