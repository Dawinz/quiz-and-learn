# 🚀 5-in-1 Earning System Backend API

A comprehensive Node.js + Express + MongoDB backend for the 5-in-1 earning ecosystem, supporting multiple earning apps with a unified wallet system.

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Installation](#installation)
- [Environment Variables](#environment-variables)
- [API Documentation](#api-documentation)
- [Database Models](#database-models)
- [Deployment](#deployment)
- [Testing](#testing)

## ✨ Features

### 🔐 Authentication & User Management
- JWT-based authentication
- User registration with referral system
- Password hashing with bcrypt
- Profile management
- Role-based access control

### 💰 Wallet & Transaction System
- Unified wallet across all apps
- Real-time balance tracking
- Transaction history with detailed metadata
- Withdrawal system with multiple payment methods
- Goal setting and progress tracking

### 🎯 Spin & Earn Integration
- Daily spin limits
- Probability-based rewards
- Spin history and statistics
- Achievement system
- Real-time balance updates

### 🔗 Referral System
- Unique referral codes
- Multi-level referral tracking
- Referral rewards for both referrer and referred
- Referral statistics and history

### 📊 Analytics & Statistics
- Comprehensive transaction analytics
- Earnings by source tracking
- User activity monitoring
- Performance metrics

## 🛠 Tech Stack

- **Runtime:** Node.js 18+
- **Framework:** Express.js
- **Database:** MongoDB with Mongoose
- **Authentication:** JWT (JSON Web Tokens)
- **Password Hashing:** bcryptjs
- **Validation:** express-validator
- **Security:** Helmet, CORS, Rate Limiting
- **Logging:** Morgan

## 🚀 Installation

### Prerequisites
- Node.js 18+ 
- MongoDB Atlas account
- Git

### Setup Steps

1. **Clone the repository**
```bash
cd /Users/abdulazizgossage/StudioProjects/5in1_earning_system/backend
```

2. **Install dependencies**
```bash
npm install
```

3. **Set up environment variables**
```bash
cp env.example .env
# Edit .env with your configuration
```

4. **Start the development server**
```bash
npm run dev
```

5. **For production**
```bash
npm start
```

## 🔧 Environment Variables

Create a `.env` file in the root directory:

```env
# MongoDB Connection
MONGO_URI=mongodb+srv://dawinibra:10@@dawMASSAM@fiveinoneearningsystem.litosuo.mongodb.net/fiveinone?retryWrites=true&w=majority&appName=fiveinoneEarningSystem

# JWT Configuration
JWT_SECRET=SuperSecretKey123
JWT_EXPIRES_IN=7d

# Server Configuration
PORT=5000
NODE_ENV=development

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# CORS Configuration
CORS_ORIGIN=http://localhost:3000

# Logging
LOG_LEVEL=info
```

## 📚 API Documentation

### Base URL
```
http://localhost:5000/api
```

### Authentication Endpoints

#### Register User
```http
POST /auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "phone": "+1234567890",
  "referralCode": "ABC123" // Optional
}
```

#### Login User
```http
POST /auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}
```

#### Get Profile
```http
GET /auth/me
Authorization: Bearer <token>
```

### Wallet Endpoints

#### Get Balance
```http
GET /wallet/balance
Authorization: Bearer <token>
```

#### Request Withdrawal
```http
POST /wallet/withdraw
Authorization: Bearer <token>
Content-Type: application/json

{
  "amount": 100,
  "method": "paypal",
  "accountDetails": "john@paypal.com"
}
```

#### Get Transactions
```http
GET /wallet/transactions?page=1&limit=20&type=earn&source=spin
Authorization: Bearer <token>
```

### Coins Endpoints

#### Add Coins
```http
POST /coins/add
Authorization: Bearer <token>
Content-Type: application/json

{
  "amount": 50,
  "source": "spin",
  "description": "Won from spin wheel",
  "metadata": {
    "spinResult": "50 coins",
    "spinMultiplier": 5
  }
}
```

#### Spend Coins
```http
POST /coins/spend
Authorization: Bearer <token>
Content-Type: application/json

{
  "amount": 25,
  "source": "withdrawal",
  "description": "Withdrawal fee"
}
```

### Spin Endpoints

#### Play Spin
```http
POST /spin/play
Authorization: Bearer <token>
```

#### Get Spin Status
```http
GET /spin/status
Authorization: Bearer <token>
```

#### Get Spin History
```http
GET /spin/history?page=1&limit=20
Authorization: Bearer <token>
```

### Referral Endpoints

#### Add Referral
```http
POST /referrals/add
Authorization: Bearer <token>
Content-Type: application/json

{
  "referralCode": "ABC123"
}
```

#### Get Referral Stats
```http
GET /referrals/stats
Authorization: Bearer <token>
```

#### Validate Referral Code
```http
POST /referrals/validate
Content-Type: application/json

{
  "referralCode": "ABC123"
}
```

## 🗄 Database Models

### User Model
- Basic profile information
- Authentication data
- Referral tracking
- Role management

### Wallet Model
- Balance tracking
- Withdrawal management
- Goal setting
- Transaction history

### Transaction Model
- Detailed transaction records
- Source tracking
- Balance consistency
- Metadata support

### AppData Model
- App-specific data storage
- Spin history and statistics
- Survey and task completion
- Referral tracking

## 🚀 Deployment

### Render Deployment

1. **Connect your GitHub repository to Render**

2. **Create a new Web Service**

3. **Configure environment variables:**
   - `MONGO_URI`
   - `JWT_SECRET`
   - `NODE_ENV=production`

4. **Build Command:**
```bash
npm install
```

5. **Start Command:**
```bash
npm start
```

### Heroku Deployment

1. **Install Heroku CLI**

2. **Login and create app:**
```bash
heroku login
heroku create your-app-name
```

3. **Set environment variables:**
```bash
heroku config:set MONGO_URI=your_mongo_uri
heroku config:set JWT_SECRET=your_jwt_secret
heroku config:set NODE_ENV=production
```

4. **Deploy:**
```bash
git push heroku main
```

## 🧪 Testing

### Run Tests
```bash
npm test
```

### API Testing with Postman

Import the provided Postman collection for comprehensive API testing:

1. **Import the collection file**
2. **Set up environment variables**
3. **Run the test suite**

## 📊 API Response Format

### Success Response
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {
    // Response data
  }
}
```

### Error Response
```json
{
  "success": false,
  "error": "Error message",
  "details": [
    {
      "field": "email",
      "message": "Invalid email format",
      "value": "invalid-email"
    }
  ]
}
```

## 🔒 Security Features

- **JWT Authentication:** Secure token-based authentication
- **Password Hashing:** bcryptjs for password security
- **Input Validation:** Comprehensive request validation
- **Rate Limiting:** Protection against abuse
- **CORS:** Cross-origin resource sharing configuration
- **Helmet:** Security headers
- **Error Handling:** Secure error responses

## 📈 Performance Features

- **Database Indexing:** Optimized queries
- **Pagination:** Efficient data loading
- **Caching:** Response caching where appropriate
- **Compression:** Response compression
- **Monitoring:** Request/response logging

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 📞 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation

---

**Built with ❤️ for the 5-in-1 Earning System** 