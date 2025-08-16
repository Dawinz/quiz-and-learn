# Mobile App Integration Guide

This guide explains how to integrate your Flutter mobile app with the hosted Quiz and Learn backend on Vercel.

## 🚀 Quick Start

### 1. Update API Base URL

In your Flutter app, update the `API_BASE_URL` to point to your Vercel backend:

```dart
// In lib/config/api_config.dart or similar
class ApiConfig {
  // Development
  static const String devApiUrl = 'http://localhost:3000';
  
  // Production (Vercel)
  static const String prodApiUrl = 'https://your-app-name.vercel.app';
  
  // Use this in your app
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: prodApiUrl,
  );
}
```

### 2. Build with API URL

When building your app, specify the API URL:

```bash
# For production
flutter build apk --dart-define=API_BASE_URL=https://your-app-name.vercel.app

# For development
flutter build apk --dart-define=API_BASE_URL=http://localhost:3000
```

## 🔧 Configuration

### Environment Variables

Your Vercel backend needs these environment variables:

```env
NODE_ENV=production
MONGO_URL=your_mongodb_connection_string
JWT_SECRET=your_super_secret_jwt_key
ADMOB_SSV_SECRET=your_admob_ssv_secret
APP_SIGNATURE_HASHES=hash1,hash2
PLAY_INTEGRITY_KEYS=key1,key2
APP_ATTEST_KEYS=key1,key2
```

### MongoDB Setup

1. **MongoDB Atlas** (Recommended for production):
   - Create a free cluster at [MongoDB Atlas](https://www.mongodb.com/atlas)
   - Get your connection string
   - Add your Vercel domain to IP whitelist

2. **Local MongoDB** (Development only):
   - Use Docker: `docker run -d -p 27017:27017 mongo:6`

## 📱 Flutter App Updates

### 1. Update Security Guard

Make sure your `SecurityGuard` is properly configured:

```dart
// In lib/security/security_guard.dart
class SecurityGuard {
  // ... existing code ...
  
  /// Initialize all security components
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize remote config first
      _remoteConfig = RemoteConfigService();
      await _remoteConfig.initialize();
      
      // ... rest of initialization
    } catch (e) {
      debugPrint('Error initializing SecurityGuard: $e');
      _isInitialized = true;
    }
  }
}
```

### 2. Update Remote Config Service

Ensure your `RemoteConfigService` uses the correct API URL:

```dart
// In lib/services/remote_config_service.dart
class RemoteConfigService {
  // ... existing code ...
  
  /// Fetch configuration from server
  Future<void> fetchConfig() async {
    try {
      final apiBaseUrl = const String.fromEnvironment('API_BASE_URL');
      if (apiBaseUrl.isEmpty) {
        debugPrint('API_BASE_URL not defined, using default config');
        _config = Map.from(_defaultConfig);
        return;
      }

      final response = await _dio.get('$apiBaseUrl/v1/config');
      // ... rest of the method
    } catch (e) {
      debugPrint('Error fetching remote config: $e');
      _config = Map.from(_defaultConfig);
    }
  }
}
```

### 3. Update API Client

Make sure your `ApiClient` uses the correct base URL:

```dart
// In lib/services/api_client.dart
class ApiClient {
  late final Dio _dio;
  
  ApiClient() {
    final apiBaseUrl = const String.fromEnvironment('API_BASE_URL');
    if (apiBaseUrl.isEmpty) {
      throw Exception('API_BASE_URL not defined');
    }
    
    _dio = Dio(BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    
    // Add interceptors
    _dio.interceptors.addAll([
      AuthInterceptor(),
      CacheInterceptor(),
      RetryInterceptor(),
    ]);
  }
}
```

## 🚀 Deployment Steps

### 1. Deploy Backend to Vercel

```bash
# Install Vercel CLI
npm install -g vercel

# Login to Vercel
vercel login

# Deploy
vercel --prod
```

### 2. Set Environment Variables

In your Vercel dashboard:
1. Go to your project settings
2. Navigate to "Environment Variables"
3. Add all required environment variables
4. Redeploy if needed

### 3. Test the Backend

```bash
# Test health endpoint
curl https://your-app-name.vercel.app/health

# Test config endpoint
curl https://your-app-name.vercel.app/v1/config
```

### 4. Update Mobile App

```bash
# Build with production API URL
flutter build apk --dart-define=API_BASE_URL=https://your-app-name.vercel.app

# Or for iOS
flutter build ios --dart-define=API_BASE_URL=https://your-app-name.vercel.app
```

## 🔒 Security Features

### Device Attestation

Your mobile app will now use the hosted backend for:
- **Android**: Play Integrity API verification
- **iOS**: App Attest + DeviceCheck verification
- **Environment Checks**: Emulator, root, debug detection

### Risk Scoring

The backend will:
- Analyze user behavior patterns
- Detect suspicious activities
- Apply risk-based restrictions
- Log all security decisions

### AdMob SSV

Server-Side Verification will:
- Verify ad impressions on the server
- Prevent client-side fraud
- Credit rewards securely
- Maintain audit trails

## 🧪 Testing

### 1. Local Testing

```bash
# Start local backend
cd backend
npm run dev

# Test mobile app with local backend
flutter run --dart-define=API_BASE_URL=http://localhost:3000
```

### 2. Production Testing

```bash
# Test with production backend
flutter run --dart-define=API_BASE_URL=https://your-app-name.vercel.app
```

### 3. Security Testing

```bash
# Run security checks
cd backend
npm run security:check
```

## 📊 Monitoring

### Vercel Analytics

- Monitor API performance
- Track error rates
- Analyze usage patterns

### MongoDB Monitoring

- Database performance
- Connection health
- Query optimization

### Security Monitoring

- Failed attestations
- Risk events
- Suspicious activities

## 🚨 Troubleshooting

### Common Issues

1. **CORS Errors**:
   - Ensure Vercel is configured for your domain
   - Check environment variables

2. **MongoDB Connection**:
   - Verify connection string
   - Check IP whitelist
   - Ensure database exists

3. **Security Failures**:
   - Check attestation keys
   - Verify app signatures
   - Review audit logs

### Debug Mode

Enable debug logging in your Flutter app:

```dart
// In main.dart
void main() {
  if (kDebugMode) {
    debugPrint('API Base URL: ${const String.fromEnvironment('API_BASE_URL')}');
  }
  
  runApp(MyApp());
}
```

## 🔄 Updates

### Backend Updates

1. Push changes to GitHub
2. Vercel automatically redeploys
3. Test endpoints
4. Update mobile app if needed

### Mobile App Updates

1. Update API endpoints if changed
2. Test with new backend
3. Deploy app updates
4. Monitor for issues

## 📞 Support

For issues:
1. Check Vercel deployment logs
2. Review MongoDB connection
3. Test endpoints manually
4. Check Flutter app logs
5. Review security audit logs

## 🎯 Next Steps

1. **Deploy backend to Vercel**
2. **Update mobile app configuration**
3. **Test all endpoints**
4. **Monitor performance**
5. **Set up alerts**
6. **Scale as needed**

Your Quiz and Learn app is now ready to use the hosted backend with full security features!
