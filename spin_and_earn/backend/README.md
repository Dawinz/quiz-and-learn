# Spin & Earn Backend API

A comprehensive Node.js backend API for the Spin & Earn mobile application, built with Express.js and MongoDB.

## 🚀 Features

### ✅ User Authentication
- JWT-based authentication with bcrypt password hashing
- User registration and login
- Profile management and password changes
- Role-based access control (User, Admin, Moderator)
- Referral system with unique codes

### ✅ Reward System
- Virtual coin system for in-app rewards
- Transaction tracking and wallet management
- Spin wheel with configurable prizes and probabilities
- Achievement system with unlockable rewards
- Referral bonuses and earnings

### ✅ User Progress Tracking
- Comprehensive progress tracking across all app features
- Daily streaks and activity monitoring
- Achievement and milestone tracking
- Performance analytics and statistics

### ✅ Analytics Dashboard
- **User Analytics**: Personal progress, earnings, streaks, achievements
- **Spin & Earn Analytics**: Spin statistics, trends, time slot performance
- **App Performance**: Overall app metrics, user growth, transaction volume
- **User Engagement**: Active users, retention rates, engagement metrics

## 🛠️ Tech Stack

- **Runtime**: Node.js (>=18.0.0)
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: JWT (JSON Web Tokens)
- **Security**: bcryptjs, helmet, cors, express-rate-limit
- **Validation**: express-validator
- **Logging**: morgan

## 📁 Project Structure

```
backend/
├── controllers/          # Route controllers
│   ├── analyticsController.js
│   ├── authController.js
│   ├── coinsController.js
│   ├── quizController.js
│   ├── referralController.js
│   ├── spinController.js
│   ├── taskController.js
│   └── walletController.js
├── middleware/           # Custom middleware
│   ├── auth.js          # JWT authentication
│   ├── errorHandler.js  # Global error handling
│   └── validate.js      # Request validation
├── models/              # MongoDB schemas
│   ├── AppData.js       # App-specific data
│   ├── Quiz.js          # Quiz management
│   ├── Task.js          # Task management
│   ├── Transaction.js   # Transaction records
│   ├── User.js          # User accounts
│   ├── UserProgress.js  # User progress tracking
│   └── Wallet.js        # User wallet
├── routes/              # API route definitions
│   ├── analytics.js     # Analytics endpoints
│   ├── auth.js          # Authentication routes
│   ├── coins.js         # Coin management
│   ├── quizzes.js       # Quiz routes
│   ├── referrals.js     # Referral system
│   ├── spin.js          # Spin wheel routes
│   ├── tasks.js         # Task routes
│   └── wallet.js        # Wallet management
├── utils/               # Utility functions
│   ├── asyncHandler.js  # Async error handling
│   └── response.js      # Standardized responses
├── server.js            # Main server file
├── package.json         # Dependencies
└── env.example          # Environment variables template
```

## 🔧 Installation & Setup

### Prerequisites
- Node.js >= 18.0.0
- MongoDB database (local or cloud)

### 1. Clone and Install
```bash
cd spin_and_earn/backend
npm install
```

### 2. Environment Configuration
Copy the environment template and configure your variables:
```bash
cp env.example .env
```

Update `.env` with your configuration:
```env
# MongoDB Connection
MONGO_URI=mongodb+srv://your_username:your_password@your_cluster.mongodb.net/?retryWrites=true&w=majority

# JWT Configuration
JWT_SECRET=your_super_secret_jwt_key
JWT_EXPIRES_IN=7d

# Server Configuration
PORT=3001
NODE_ENV=development

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# CORS Configuration
CORS_ORIGIN=http://localhost:3000
```

### 3. Start the Server
```bash
# Development mode with auto-reload
npm run dev

# Production mode
npm start
```

## 📊 API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get user profile
- `PUT /api/auth/me` - Update user profile
- `PUT /api/auth/change-password` - Change password
- `POST /api/auth/refresh` - Refresh JWT token

### Spin & Earn
- `POST /api/spin/play` - Play spin wheel
- `GET /api/spin/status` - Get spin status
- `GET /api/spin/history` - Get spin history
- `GET /api/spin/stats` - Get spin statistics

### Wallet & Coins
- `GET /api/wallet/balance` - Get wallet balance
- `POST /api/wallet/withdraw` - Withdraw coins
- `GET /api/coins/balance` - Get coin balance
- `POST /api/coins/transfer` - Transfer coins

### Analytics
- `GET /api/analytics/user-dashboard` - User analytics dashboard
- `GET /api/analytics/spin-earn` - Spin & earn specific analytics
- `GET /api/analytics/app-performance` - App performance metrics (Admin)
- `GET /api/analytics/engagement` - User engagement metrics (Admin)

### Tasks & Quizzes
- `GET /api/tasks` - Get available tasks
- `POST /api/tasks/complete` - Complete a task
- `GET /api/quizzes` - Get available quizzes
- `POST /api/quizzes/submit` - Submit quiz answers

### Referrals
- `GET /api/referrals/code` - Get referral code
- `GET /api/referrals/stats` - Get referral statistics
- `GET /api/referrals/list` - Get referral list

## 🔒 Security Features

- **Rate Limiting**: Prevents API abuse with configurable limits
- **CORS**: Cross-origin resource sharing configuration
- **Helmet**: Security headers for protection
- **Input Validation**: Request validation using express-validator
- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: bcrypt with salt rounds
- **Role-based Access**: Admin-only endpoints protection

## 📈 Analytics Features

### User Analytics
- Personal earnings across all apps
- Streak tracking and achievements
- Recent activity and transaction history
- App-specific progress metrics

### Spin & Earn Analytics
- Spin wheel performance statistics
- Daily spin trends and patterns
- Time slot performance analysis
- Achievement tracking and rewards

### Business Analytics (Admin)
- User growth and retention metrics
- Transaction volume and coin circulation
- Top performing users
- App usage statistics across features

### Engagement Metrics
- Daily/Monthly active users
- User retention rates
- Feature adoption statistics
- Performance benchmarking

## 🚀 Deployment

### Vercel Deployment
This backend is configured for Vercel deployment with:
- Serverless function support
- Automatic scaling
- Global CDN distribution
- Environment variable management

### Environment Variables for Production
Ensure these are set in your Vercel dashboard:
- `MONGO_URI` - Your MongoDB connection string
- `JWT_SECRET` - Strong secret key for JWT
- `NODE_ENV` - Set to "production"
- `CORS_ORIGIN` - Your frontend domain

## 🧪 Testing

Run the test suite:
```bash
npm test
```

## 📝 API Documentation

For detailed API documentation, see the Postman collection:
`5in1_Earning_System_API.postman_collection.json`

## 🤝 Contributing

1. Follow the existing code style
2. Add tests for new features
3. Update documentation
4. Ensure all tests pass

## 📄 License

MIT License - see LICENSE file for details

## 🆘 Support

For support and questions:
- Check the API documentation
- Review the Postman collection
- Check server logs for errors
- Verify environment configuration 