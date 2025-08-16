# Spin & Earn Backend API Documentation

## 🔐 Authentication

All protected endpoints require a valid JWT token in the Authorization header:
```
Authorization: Bearer <your_jwt_token>
```

## 📋 Base URL
```
Development: http://localhost:3001
Production: https://your-vercel-domain.vercel.app
```

## 🔑 Authentication Endpoints

### User Registration
```http
POST /api/auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "phone": "+1234567890",
  "referralCode": "ABC12345"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user_id",
      "name": "John Doe",
      "email": "john@example.com",
      "totalCoins": 0,
      "referralCode": "ABC12345"
    },
    "token": "jwt_token_here"
  },
  "message": "User registered successfully"
}
```

### User Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "user_id",
      "name": "John Doe",
      "email": "john@example.com",
      "totalCoins": 150
    },
    "token": "jwt_token_here"
  },
  "message": "Login successful"
}
```

### Get User Profile
```http
GET /api/auth/me
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "user_id",
    "name": "John Doe",
    "email": "john@example.com",
    "totalCoins": 150,
    "roles": ["user"],
    "isActive": true,
    "lastLogin": "2024-01-15T10:30:00Z",
    "referralCode": "ABC12345",
    "referralCount": 2,
    "referralEarnings": 50
  },
  "message": "Profile retrieved successfully"
}
```

## 🎰 Spin & Earn Endpoints

### Play Spin Wheel
```http
POST /api/spin/play
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "prize": {
      "result": "50 coins",
      "coins": 50
    },
    "coinsEarned": 50,
    "multiplier": 5,
    "newBalance": 200,
    "spinData": {
      "dailySpinsUsed": 1,
      "dailySpinsLimit": 3,
      "totalSpins": 15,
      "totalCoinsFromSpins": 450,
      "canSpinToday": true,
      "achievements": ["First Spin", "Daily Player"]
    }
  },
  "message": "Spin completed successfully!"
}
```

### Get Spin Status
```http
GET /api/spin/status
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "canSpinToday": true,
    "dailySpinsUsed": 1,
    "dailySpinsLimit": 3,
    "totalSpins": 15,
    "totalCoinsFromSpins": 450,
    "lastSpinDate": "2024-01-15T10:30:00Z",
    "achievements": ["First Spin", "Daily Player"],
    "prizes": [
      { "result": "10 coins", "probability": 0.3 },
      { "result": "25 coins", "probability": 0.25 },
      { "result": "50 coins", "probability": 0.2 },
      { "result": "100 coins", "probability": 0.15 },
      { "result": "200 coins", "probability": 0.08 },
      { "result": "500 coins", "probability": 0.02 }
    ]
  },
  "message": "Spin status retrieved successfully"
}
```

### Get Spin History
```http
GET /api/spin/history?page=1&limit=20
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "history": [
      {
        "timestamp": "2024-01-15T10:30:00Z",
        "result": "50 coins",
        "coinsEarned": 50,
        "multiplier": 5
      }
    ],
    "total": 15,
    "page": 1,
    "limit": 20,
    "totalPages": 1
  },
  "message": "Spin history retrieved successfully"
}
```

### Get Spin Statistics
```http
GET /api/spin/stats
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "totalSpins": 15,
    "totalCoinsEarned": 450,
    "averageCoinsPerSpin": 30,
    "todaySpins": 1,
    "weekSpins": 7,
    "monthSpins": 15,
    "achievements": ["First Spin", "Daily Player"],
    "dailySpinsLimit": 3,
    "canSpinToday": true
  },
  "message": "Spin statistics retrieved successfully"
}
```

## 💰 Wallet & Coins Endpoints

### Get Wallet Balance
```http
GET /api/wallet/balance
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "balance": 200,
    "totalEarned": 450,
    "totalSpent": 250,
    "lastTransaction": "2024-01-15T10:30:00Z"
  },
  "message": "Wallet balance retrieved successfully"
}
```

### Get Coin Balance
```http
GET /api/coins/balance
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "totalCoins": 200,
    "availableCoins": 200,
    "lockedCoins": 0,
    "pendingCoins": 0
  },
  "message": "Coin balance retrieved successfully"
}
```

## 📊 Analytics Endpoints

### User Dashboard Analytics
```http
GET /api/analytics/user-dashboard
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "totalEarnings": 450,
    "totalStreak": 5,
    "totalAchievements": 3,
    "recentActivity": 7,
    "walletBalance": 200,
    "recentTransactions": [
      {
        "type": "earn",
        "amount": 50,
        "source": "spin",
        "description": "Won 50 coins from spin wheel",
        "createdAt": "2024-01-15T10:30:00Z"
      }
    ],
    "appProgress": [
      {
        "app": "spin",
        "earnings": 450,
        "streak": 5,
        "lastActivity": "2024-01-15T10:30:00Z"
      }
    ]
  },
  "message": "User dashboard analytics retrieved successfully"
}
```

### Spin & Earn Analytics
```http
GET /api/analytics/spin-earn
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "overview": {
      "totalSpins": 15,
      "totalCoinsEarned": 450,
      "averageCoinsPerSpin": 30,
      "currentStreak": 5,
      "dailySpinsLimit": 3,
      "dailySpinsUsed": 1
    },
    "trends": {
      "dailySpins": [
        { "date": "2024-01-15", "spins": 1 },
        { "date": "2024-01-14", "spins": 3 }
      ],
      "timeSlotPerformance": [
        {
          "timeSlot": "10:00-11:00",
          "spins": 5,
          "totalCoins": 150,
          "averageCoins": 30
        }
      ]
    },
    "achievements": ["First Spin", "Daily Player"],
    "recentSpins": [
      {
        "timestamp": "2024-01-15T10:30:00Z",
        "result": "50 coins",
        "coinsEarned": 50
      }
    ]
  },
  "message": "Spin and earn analytics retrieved successfully"
}
```

### App Performance Analytics (Admin Only)
```http
GET /api/analytics/app-performance
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "overview": {
      "totalUsers": 1250,
      "totalTransactions": 5670,
      "totalCoinsInCirculation": 125000
    },
    "trends": {
      "userGrowth": [
        { "_id": "2024-01-15", "newUsers": 25 },
        { "_id": "2024-01-14", "newUsers": 30 }
      ],
      "transactionVolume": [
        { "_id": "2024-01-15", "totalAmount": 2500, "count": 150 }
      ]
    },
    "topEarners": [
      {
        "name": "John Doe",
        "email": "john@example.com",
        "totalCoins": 1500,
        "referralCount": 5
      }
    ],
    "appUsage": [
      {
        "_id": "spin",
        "totalUsers": 1250,
        "totalEarnings": 75000
      }
    ]
  },
  "message": "App performance analytics retrieved successfully"
}
```

### User Engagement Metrics (Admin Only)
```http
GET /api/analytics/engagement?period=7d
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "period": "7d",
    "activeUsers": 850,
    "dailyActiveUsers": [
      { "date": "2024-01-15", "activeUsers": 120 },
      { "date": "2024-01-14", "activeUsers": 115 }
    ],
    "retention": [
      {
        "app": "spin",
        "totalUsers": 1250,
        "usersWithStreak": 850,
        "retentionRate": "68.00"
      }
    ]
  },
  "message": "User engagement metrics retrieved successfully"
}
```

## 🎯 Task & Quiz Endpoints

### Get Available Tasks
```http
GET /api/tasks
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "task_id",
      "title": "Complete Daily Survey",
      "description": "Complete a quick survey to earn coins",
      "reward": 25,
      "estimatedTime": 5,
      "category": "survey",
      "isAvailable": true
    }
  ],
  "message": "Tasks retrieved successfully"
}
```

### Complete Task
```http
POST /api/tasks/complete
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "taskId": "task_id",
  "rating": 5
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "taskCompleted": true,
    "coinsEarned": 25,
    "newBalance": 225,
    "streak": 6
  },
  "message": "Task completed successfully"
}
```

### Get Available Quizzes
```http
GET /api/quizzes
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "quiz_id",
      "title": "Financial Literacy Quiz",
      "description": "Test your knowledge about personal finance",
      "category": "finance",
      "questions": 10,
      "timeLimit": 300,
      "reward": 50,
      "isAvailable": true
    }
  ],
  "message": "Quizzes retrieved successfully"
}
```

## 🔗 Referral Endpoints

### Get Referral Code
```http
GET /api/referrals/code
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "referralCode": "ABC12345",
    "referralCount": 2,
    "referralEarnings": 50,
    "referralLink": "https://yourapp.com/ref/ABC12345"
  },
  "message": "Referral code retrieved successfully"
}
```

### Get Referral Statistics
```http
GET /api/referrals/stats
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "totalReferrals": 2,
    "activeReferrals": 2,
    "totalEarnings": 50,
    "referralHistory": [
      {
        "referredUser": "Jane Doe",
        "joinedAt": "2024-01-10T10:00:00Z",
        "status": "active",
        "earnings": 25
      }
    ]
  },
  "message": "Referral statistics retrieved successfully"
}
```

## 📝 Error Responses

### Validation Error
```json
{
  "success": false,
  "error": "Validation failed",
  "message": "Name must be between 2 and 50 characters"
}
```

### Authentication Error
```json
{
  "success": false,
  "error": "Unauthorized",
  "message": "Invalid or expired token"
}
```

### Not Found Error
```json
{
  "success": false,
  "error": "Not Found",
  "message": "Resource not found"
}
```

### Server Error
```json
{
  "success": false,
  "error": "Internal Server Error",
  "message": "Something went wrong"
}
```

## 🔒 Rate Limiting

- **Window**: 15 minutes
- **Limit**: 100 requests per IP address
- **Headers**: Rate limit information included in response headers

## 🌐 CORS Configuration

- **Origin**: Configurable via environment variable
- **Credentials**: Supported
- **Methods**: GET, POST, PUT, DELETE
- **Headers**: Content-Type, Authorization

## 📊 Response Format

All API responses follow this standard format:

```json
{
  "success": boolean,
  "data": object | array | null,
  "error": string | null,
  "message": string
}
```

## 🚀 Getting Started

1. **Set up environment variables** using the `.env` file
2. **Install dependencies**: `npm install`
3. **Start development server**: `npm run dev`
4. **Test endpoints** using the provided examples
5. **Deploy to Vercel** using the deployment script

## 📚 Additional Resources

- **Postman Collection**: `5in1_Earning_System_API.postman_collection.json`
- **Environment Template**: `env.example`
- **Deployment Script**: `deploy-vercel.sh`
- **Vercel Config**: `vercel.json`
