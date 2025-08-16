# GitHub Repository Setup & Vercel Deployment

## 🗂️ Repository Structure

Your backend is now organized as a standalone repository:

```
quiz_and_learn_backend/
├── src/                    # TypeScript source code
├── bin/                    # CLI tools
├── .github/workflows/      # GitHub Actions
├── vercel.json            # Vercel configuration
├── Dockerfile             # Docker configuration
├── docker-compose.yml     # Local development
├── deploy.sh              # Deployment script
├── deploy-vercel.sh       # Vercel deployment
└── README.md              # Project documentation
```

## 🚀 GitHub Repository Setup

### 1. Create New Repository

1. Go to [GitHub](https://github.com)
2. Click "New repository"
3. Name: `quiz-and-learn-backend`
4. Description: "Secure anti-fraud backend API for Quiz and Learn mobile app"
5. Make it **Public** (for free hosting)
6. Don't initialize with README (we already have one)

### 2. Push to GitHub

```bash
# Initialize git (if not already done)
git init

# Add remote origin
git remote add origin https://github.com/YOUR_USERNAME/quiz-and-learn-backend.git

# Add all files
git add .

# Initial commit
git commit -m "Initial commit: Quiz and Learn Backend with anti-fraud security"

# Push to main branch
git push -u origin main
```

## 🌐 Vercel Deployment

### 1. Connect to Vercel

1. Go to [Vercel](https://vercel.com)
2. Sign in with GitHub
3. Click "New Project"
4. Import your `quiz-and-learn-backend` repository

### 2. Configure Environment Variables

In Vercel project settings, add:

```env
MONGO_URL=mongodb+srv://username:password@cluster.mongodb.net/quiz_and_learn
JWT_SECRET=your-super-secret-jwt-key-here
ADMOB_SSV_SECRET=your-admob-ssv-secret
APP_SIGNATURE_HASHES=hash1,hash2
PLAY_INTEGRITY_KEYS=key1,key2
APP_ATTEST_KEYS=key1,key2
```

### 3. Deploy

Vercel will automatically deploy when you push to GitHub!

## 📱 Mobile App Integration

### 1. Update Flutter App

In your Flutter app, update the API configuration:

```dart
// lib/config/api_config.dart
class ApiConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://your-app-name.vercel.app',
  );
}
```

### 2. Build with New API URL

```bash
# Development
flutter run --dart-define=API_BASE_URL=http://localhost:3000

# Production
flutter build apk --dart-define=API_BASE_URL=https://your-app-name.vercel.app
```

## 🔒 Security Features

Your hosted backend now provides:

- **Device Attestation**: Android Play Integrity + iOS App Attest
- **Environment Checks**: Emulator, root, debug detection
- **Risk Scoring**: Multi-factor fraud detection
- **AdMob SSV**: Server-side verification
- **Audit Logging**: Complete security audit trail

## 🧪 Testing

### 1. Test Backend Endpoints

```bash
# Health check
curl https://your-app-name.vercel.app/health

# Security config
curl https://your-app-name.vercel.app/v1/config

# Test attestation
curl -X POST https://your-app-name.vercel.app/v1/attest/start
```

### 2. Test Mobile App

1. Update API URL in Flutter app
2. Run security checks
3. Test device attestation
4. Verify reward flows

## 📊 Monitoring

### Vercel Dashboard

- **Analytics**: API performance metrics
- **Functions**: Serverless function logs
- **Deployments**: Automatic deployment history

### MongoDB Atlas

- **Performance**: Database query optimization
- **Security**: Connection monitoring
- **Backups**: Automated data protection

## 🔄 Continuous Deployment

Every push to `main` branch automatically:

1. Runs tests
2. Builds the project
3. Deploys to Vercel
4. Updates your live API

## 🚨 Troubleshooting

### Common Issues

1. **Build Failures**: Check TypeScript compilation
2. **Environment Variables**: Verify all required vars are set
3. **MongoDB Connection**: Check connection string and IP whitelist
4. **CORS Issues**: Verify Vercel configuration

### Debug Steps

1. Check Vercel deployment logs
2. Verify environment variables
3. Test endpoints manually
4. Review security audit logs

## 🎯 Next Steps

1. **Deploy to Vercel** ✅
2. **Update mobile app** ✅
3. **Test all endpoints** ✅
4. **Monitor performance** ✅
5. **Scale as needed** ✅

Your Quiz and Learn backend is now hosted on Vercel with full security features!
