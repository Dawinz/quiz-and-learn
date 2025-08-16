# Quiz and Learn Backend API

A secure, anti-fraud backend API for the Quiz and Learn mobile application, built with Node.js, TypeScript, and MongoDB.

## 🚀 Features

- **Anti-Fraud Security Layer**
  - Device attestation (Android Play Integrity, iOS App Attest)
  - Environment integrity checks
  - Risk scoring and velocity analysis
  - Idempotency for write operations
  - Audit logging

- **Core API Endpoints**
  - User authentication and management
  - Quiz management and scoring
  - Reward system with security validation
  - Wallet and transaction management
  - Referral system

- **AdMob Integration**
  - Server-Side Verification (SSV)
  - Secure reward crediting
  - Fraud prevention

## 🛠️ Tech Stack

- **Runtime**: Node.js 18+
- **Language**: TypeScript
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose
- **Security**: JWT, HMAC verification
- **Caching**: In-memory cache with ETag support

## 📋 Prerequisites

- Node.js 18+ 
- MongoDB 5+
- npm or yarn

## 🔧 Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd quiz_and_learn_backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Environment Configuration**
   ```bash
   cp env.example .env
   ```
   
   Fill in your environment variables:
   ```env
   NODE_ENV=production
   PORT=3000
   MONGO_URL=mongodb://localhost:27017/quiz_and_learn
   JWT_SECRET=your-super-secret-jwt-key
   ADMOB_SSV_SECRET=your-admob-ssv-secret
   APP_SIGNATURE_HASHES=hash1,hash2
   PLAY_INTEGRITY_KEYS=key1,key2
   APP_ATTEST_KEYS=key1,key2
   ```

4. **Build the project**
   ```bash
   npm run build
   ```

5. **Start the server**
   ```bash
   npm start
   ```

## 🚀 Development

```bash
# Run in development mode with hot reload
npm run dev

# Run security checks
npm run security:check

# Run tests
npm test
```

## 🌐 API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/refresh` - Refresh token

### Security & Attestation
- `GET /v1/config` - Get security configuration
- `POST /v1/attest/start` - Start device attestation
- `POST /v1/attest/verify` - Verify attestation

### AdMob SSV
- `POST /v1/ads/ssv/admob` - AdMob Server-Side Verification
- `GET /v1/ads/ssv/history` - SSV event history

### Core Features
- `GET /api/quizzes` - Get available quizzes
- `POST /api/quizzes/:id/submit` - Submit quiz answers
- `GET /api/wallet/balance` - Get wallet balance
- `POST /api/wallet/withdraw` - Withdraw funds

## 🔒 Security Features

### Device Integrity
- **Android**: Play Integrity API integration
- **iOS**: App Attest + DeviceCheck
- **Environment Checks**: Emulator, root, debug mode detection

### Risk Management
- Multi-factor risk scoring
- Velocity analysis (burst activity detection)
- Device fingerprinting
- Transaction pattern analysis

### Data Protection
- JWT authentication
- HMAC signature verification
- Idempotency keys for write operations
- Comprehensive audit logging

## 📊 Database Collections

- `users` - User accounts and profiles
- `devices` - Device integrity and attestation data
- `transactions` - Financial transactions
- `quizzes` - Quiz content and results
- `audits` - Security audit logs
- `riskEvents` - Risk assessment events
- `ssvEvents` - AdMob SSV events
- `idempotency` - Idempotency key storage

## 🚀 Deployment

### Heroku
```bash
# Add Heroku remote
heroku git:remote -a your-app-name

# Deploy
git push heroku main
```

### Railway
```bash
# Install Railway CLI
npm i -g @railway/cli

# Deploy
railway up
```

### Vercel
```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel --prod
```

### Docker
```bash
# Build image
docker build -t quiz-and-learn-backend .

# Run container
docker run -p 3000:3000 quiz-and-learn-backend
```

## 🔧 Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `NODE_ENV` | Environment (dev/prod) | Yes | `development` |
| `PORT` | Server port | No | `3000` |
| `MONGO_URL` | MongoDB connection string | Yes | - |
| `JWT_SECRET` | JWT signing secret | Yes | - |
| `ADMOB_SSV_SECRET` | AdMob SSV secret | Yes | - |
| `APP_SIGNATURE_HASHES` | App signature hashes | Yes | - |
| `PLAY_INTEGRITY_KEYS` | Play Integrity keys | Yes | - |
| `APP_ATTEST_KEYS` | App Attest keys | Yes | - |

## 📱 Mobile App Integration

Update your Flutter app's `API_BASE_URL` to point to your hosted backend:

```dart
// In your Flutter app
const String apiBaseUrl = 'https://your-backend-domain.com';
```

## 🧪 Testing

### Security Checks
```bash
npm run security:check
```

### API Testing
Import the Postman collections:
- `5in1_Earning_System_API.postman_collection.json`
- `SECURITY_API_COLLECTION.postman_collection.json`

### Manual Testing
```bash
# Test health endpoint
curl https://your-backend-domain.com/health

# Test config endpoint
curl https://your-backend-domain.com/v1/config
```

## 📈 Monitoring & Logging

- **Audit Logs**: All security decisions are logged
- **Risk Events**: Track suspicious activities
- **Performance**: Monitor API response times
- **Errors**: Comprehensive error logging

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Review the security setup guide

## 🔄 Updates

Keep your backend updated with the latest security patches and features by regularly pulling from the main branch. 