# 📋 Task & Earn Backend

Backend API server for the Task & Earn Flutter application.

## 🚀 Features

- **User Authentication**: JWT-based authentication system
- **Task Management**: CRUD operations for tasks
- **User Progress**: Track task completion and progress
- **Reward System**: Manage coin rewards and transactions
- **Profile Management**: User profile and settings

## 🛠️ Technology Stack

- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: MongoDB with Mongoose
- **Authentication**: JWT (JSON Web Tokens)
- **Security**: bcryptjs, helmet, cors

## 📋 Prerequisites

- Node.js (18.0.0 or higher)
- MongoDB (local or cloud instance)
- npm or yarn package manager

## 🚀 Quick Start

### 1. Install Dependencies
```bash
npm install
```

### 2. Environment Configuration
```bash
cp env.example .env
```

Update the `.env` file with your configuration:
```env
# MongoDB Connection
MONGO_URI=mongodb://127.0.0.1:27017/task_and_earn

# JWT Configuration
JWT_SECRET=your_jwt_secret_key
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
# Development mode
npm run dev

# Production mode
npm start
```

## 📊 API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get user profile

### Tasks
- `GET /api/tasks` - Get available tasks
- `GET /api/tasks/:id` - Get task details
- `POST /api/tasks/:id/complete` - Complete a task
- `GET /api/tasks/categories` - Get task categories
- `GET /api/tasks/types` - Get task types

### User Progress
- `GET /api/tasks/progress` - Get user task progress
- `POST /api/tasks/progress` - Update task progress

### Wallet
- `GET /api/wallet/balance` - Get wallet balance
- `GET /api/wallet/transactions` - Get transaction history

### Referrals
- `GET /api/referrals/stats` - Get referral statistics
- `GET /api/referrals/link` - Get referral link

## 🗄️ Database Schema

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

### Tasks Collection
```javascript
{
  _id: ObjectId,
  title: String,
  description: String,
  category: String,
  type: String,
  difficulty: String,
  reward: Number,
  requirements: [String],
  isActive: Boolean,
  createdAt: Date,
  updatedAt: Date
}
```

### UserProgress Collection
```javascript
{
  _id: ObjectId,
  userId: ObjectId,
  app: String,
  taskProgress: {
    completedTasks: [{
      taskId: ObjectId,
      completedAt: Date,
      reward: Number,
      rating: Number
    }],
    dailyCompletions: Number,
    lastResetDate: Date,
    streak: Number,
    totalEarnings: Number
  },
  lastActivity: Date,
  createdAt: Date,
  updatedAt: Date
}
```

## 🔧 Configuration

### Environment Variables
- `MONGO_URI`: MongoDB connection string
- `JWT_SECRET`: Secret key for JWT tokens
- `JWT_EXPIRES_IN`: JWT token expiration time
- `PORT`: Server port (default: 3001)
- `NODE_ENV`: Environment (development/production)
- `RATE_LIMIT_WINDOW_MS`: Rate limiting window
- `RATE_LIMIT_MAX_REQUESTS`: Maximum requests per window
- `CORS_ORIGIN`: Allowed CORS origins

### Security Features
- **Rate Limiting**: Prevents API abuse
- **CORS**: Cross-origin resource sharing
- **Helmet**: Security headers
- **Input Validation**: Request validation
- **JWT Authentication**: Secure token-based auth

## 🚀 Deployment

### Local Development
```bash
npm run dev
```

### Production Deployment
```bash
npm start
```

### Docker Deployment
```bash
# Build image
docker build -t task-and-earn-backend .

# Run container
docker run -p 3001:3001 task-and-earn-backend
```

## 🧪 Testing

```bash
# Run tests
npm test

# Run tests with coverage
npm run test:coverage
```

## 📝 API Documentation

### Request/Response Format
All API responses follow this format:
```javascript
{
  success: Boolean,
  data: Object | Array,
  error: String (optional),
  message: String (optional)
}
```

### Error Handling
- `400`: Bad Request
- `401`: Unauthorized
- `403`: Forbidden
- `404`: Not Found
- `500`: Internal Server Error

## 📄 License

This project is licensed under the MIT License.

## 📞 Support

For support and questions, please open an issue in the repository. 