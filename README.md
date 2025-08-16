# 🧠 Quiz & Learn Backend

A secure, anti-fraud backend API for the Quiz & Learn Flutter application, built with Node.js, TypeScript, and MongoDB.

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

## 🛠️ Technology Stack

- **Runtime**: Node.js 18+
- **Language**: TypeScript
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose
- **Security**: JWT, HMAC verification, bcryptjs, helmet, cors
- **Caching**: In-memory cache with ETag support

## 📋 Prerequisites

- Node.js 18+ 
- MongoDB 5+
- npm or yarn

## 🔧 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Dawinz/quiz-and-learn.git
   cd quiz-and-learn/backend
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
   MONGO_URI=mongodb+srv://dawinibra:nP4Xf7NJ11I7db94@cluster0.yi6y2jk.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0
   JWT_SECRET=your-super-secret-jwt-key
   JWT_EXPIRES_IN=7d
   CORS_ORIGIN=*
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
- `GET /api/auth/me` - Get user profile
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
- `GET /api/quizzes/:id` - Get quiz details
- `POST /api/quizzes/:id/start` - Start a quiz
- `POST /api/quizzes/:id/submit` - Submit quiz answers
- `GET /api/quizzes/categories` - Get quiz categories
- `GET /api/quizzes/progress` - Get user quiz progress
- `GET /api/quizzes/history` - Get quiz history
- `GET /api/quizzes/statistics` - Get user statistics

### Wallet
- `GET /api/wallet/balance` - Get wallet balance
- `GET /api/wallet/transactions` - Get transaction history
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
- Rate limiting
- CORS protection
- Helmet security headers

## 📊 Database Schema

### Users Collection
```javascript
{
  _id: ObjectId,
  name: String,
  email: String,
  password: String (hashed),
  totalCoins: Number,
  roles: [String],
  isActive: Boolean,
  lastLogin: Date,
  emailVerified: Boolean,
  profilePicture: String,
  phone: String,
  referralCode: String,
  referralCount: Number,
  referralEarnings: Number,
  createdAt: Date,
  updatedAt: Date
}
```

### Quizzes Collection
```javascript
{
  _id: ObjectId,
  title: String,
  description: String,
  category: String,
  difficulty: String,
  timeLimit: Number,
  questions: [{
    question: String,
    options: [String],
    correctAnswer: Number,
    explanation: String
  }],
  reward: Number,
  isActive: Boolean,
  createdAt: Date,
  updatedAt: Date
}
```

### QuizResults Collection
```javascript
{
  _id: ObjectId,
  userId: ObjectId,
  quizId: ObjectId,
  score: Number,
  totalQuestions: Number,
  correctAnswers: Number,
  timeTaken: Number,
  coinsEarned: Number,
  answers: [{
    questionIndex: Number,
    selectedAnswer: Number,
    isCorrect: Boolean
  }],
  completedAt: Date,
  createdAt: Date
}
```

### Additional Collections
- `devices` - Device integrity and attestation data
- `transactions` - Financial transactions
- `audits` - Security audit logs
- `riskEvents` - Risk assessment events
- `ssvEvents` - AdMob SSV events
- `idempotency` - Idempotency key storage

## 🚀 Deployment

### Quick Deployment
```bash
# Run the deployment script
./deploy.sh
```

### Manual Deployment Options

#### Render (Recommended - Free)
1. Go to [render.com](https://render.com)
2. Connect your GitHub repository
3. Set build command: `cd quiz_and_learn/backend && npm install && npm run build`
4. Set start command: `cd quiz_and_learn/backend && npm start`
5. Add environment variables

#### Railway
```bash
# Install Railway CLI
npm i -g @railway/cli

# Deploy
railway up
```

#### Heroku
```bash
# Add Heroku remote
heroku git:remote -a your-app-name

# Deploy
git push heroku main
```

#### Vercel
```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel --prod
```

#### Docker
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
| `MONGO_URI` | MongoDB connection string | Yes | - |
| `JWT_SECRET` | JWT signing secret | Yes | - |
| `JWT_EXPIRES_IN` | JWT expiration time | No | `7d` |
| `CORS_ORIGIN` | Allowed CORS origins | No | `*` |
| `RATE_LIMIT_WINDOW_MS` | Rate limiting window | No | `900000` |
| `RATE_LIMIT_MAX_REQUESTS` | Max requests per window | No | `100` |

## 📱 Mobile App Integration

Update your Flutter app's API service to point to your hosted backend:

```dart
// In quiz_and_learn/lib/services/api_service.dart
void _initializeBaseUrl() {
  baseUrl = "https://your-backend-domain.com/api";
}
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

# Test auth endpoint
curl -X POST https://your-backend-domain.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test123"}'
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

## 📞 Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Review the security setup guide

## 🔄 Updates

Keep your backend updated with the latest security patches and features by regularly pulling from the main branch.
