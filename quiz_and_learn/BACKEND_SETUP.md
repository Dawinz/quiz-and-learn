# Backend Setup Guide for Quiz & Learn App

## Overview
The Quiz & Learn app requires a backend server to handle authentication, user management, and quiz functionality. This guide will help you set up the backend server.

## Prerequisites
- Node.js (v16 or higher)
- MongoDB or PostgreSQL database
- Git

## Quick Start with Existing Backend

If you already have the backend from the main project:

1. Navigate to the backend directory:
   ```bash
   cd ../backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Set up environment variables:
   ```bash
   cp env.example .env
   ```
   
   Edit `.env` file with your database and JWT secret:
   ```env
   PORT=3001
   MONGODB_URI=mongodb://localhost:27017/quiz_learn_db
   JWT_SECRET=your_jwt_secret_here
   NODE_ENV=development
   ```

4. Start the server:
   ```bash
   npm start
   ```

5. Update the API URL in the Flutter app:
   - Open `lib/services/api_service.dart`
   - Change the `baseUrl` to match your backend:
     ```dart
     static const String baseUrl = "http://YOUR_IP_ADDRESS:3001/api";
     ```

## Setting Up from Scratch

### 1. Create Backend Directory
```bash
mkdir quiz_learn_backend
cd quiz_learn_backend
npm init -y
```

### 2. Install Dependencies
```bash
npm install express mongoose bcryptjs jsonwebtoken cors dotenv express-validator
npm install --save-dev nodemon
```

### 3. Create Basic Server Structure
```bash
mkdir src
mkdir src/controllers
mkdir src/models
mkdir src/routes
mkdir src/middleware
mkdir src/utils
```

### 4. Create Main Server File (`src/index.js`)
```javascript
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
require('dotenv').config();

const authRoutes = require('./routes/auth');
const quizRoutes = require('./routes/quizzes');
const walletRoutes = require('./routes/wallet');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/quizzes', quizRoutes);
app.use('/api/wallet', walletRoutes);

// Health check
app.get('/api/health', (req, res) => {
  res.json({ success: true, message: 'Server is running' });
});

// Connect to database
mongoose.connect(process.env.MONGODB_URI)
  .then(() => {
    console.log('Connected to MongoDB');
    const PORT = process.env.PORT || 3001;
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  })
  .catch(err => {
    console.error('Database connection failed:', err);
  });
```

### 5. Create User Model (`src/models/User.js`)
```javascript
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true
  },
  password: {
    type: String,
    required: true,
    minlength: 6
  },
  totalCoins: {
    type: Number,
    default: 0
  },
  roles: {
    type: [String],
    default: ['user']
  },
  isActive: {
    type: Boolean,
    default: true
  },
  emailVerified: {
    type: Boolean,
    default: false
  },
  referralCode: {
    type: String,
    unique: true,
    sparse: true
  },
  referredBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  referralCount: {
    type: Number,
    default: 0
  },
  referralEarnings: {
    type: Number,
    default: 0
  }
}, {
  timestamps: true
});

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Generate referral code
userSchema.pre('save', function(next) {
  if (!this.referralCode) {
    this.referralCode = Math.random().toString(36).substring(2, 8).toUpperCase();
  }
  next();
});

// Compare password method
userSchema.methods.comparePassword = async function(candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('User', userSchema);
```

### 6. Create Auth Controller (`src/controllers/authController.js`)
```javascript
const User = require('../models/User');
const jwt = require('jsonwebtoken');

const generateToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_SECRET, { expiresIn: '7d' });
};

exports.register = async (req, res) => {
  try {
    const { name, email, password, referralCode } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        error: 'User with this email already exists'
      });
    }

    // Handle referral
    let referredBy = null;
    if (referralCode) {
      referredBy = await User.findOne({ referralCode });
      if (!referredBy) {
        return res.status(400).json({
          success: false,
          error: 'Invalid referral code'
        });
      }
    }

    // Create user
    const user = new User({
      name,
      email,
      password,
      referredBy
    });

    await user.save();

    // Update referrer stats
    if (referredBy) {
      referredBy.referralCount += 1;
      referredBy.referralEarnings += 10; // Give 10 coins for referral
      await referredBy.save();
    }

    // Generate token
    const token = generateToken(user._id);

    res.status(201).json({
      success: true,
      data: {
        token,
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          totalCoins: user.totalCoins,
          referralCode: user.referralCode
        }
      }
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({
      success: false,
      error: 'Registration failed'
    });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({
        success: false,
        error: 'Invalid credentials'
      });
    }

    // Check password
    const isPasswordValid = await user.comparePassword(password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        error: 'Invalid credentials'
      });
    }

    // Generate token
    const token = generateToken(user._id);

    res.json({
      success: true,
      data: {
        token,
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          totalCoins: user.totalCoins,
          referralCode: user.referralCode
        }
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      error: 'Login failed'
    });
  }
};

exports.getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.userId).select('-password');
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    res.json({
      success: true,
      data: { user }
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get profile'
    });
  }
};
```

### 7. Create Auth Routes (`src/routes/auth.js`)
```javascript
const express = require('express');
const { body } = require('express-validator');
const authController = require('../controllers/authController');
const auth = require('../middleware/auth');

const router = express.Router();

// Validation middleware
const registerValidation = [
  body('name').trim().isLength({ min: 2 }).withMessage('Name must be at least 2 characters'),
  body('email').isEmail().normalizeEmail().withMessage('Invalid email'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters')
];

const loginValidation = [
  body('email').isEmail().normalizeEmail().withMessage('Invalid email'),
  body('password').notEmpty().withMessage('Password is required')
];

// Routes
router.post('/register', registerValidation, authController.register);
router.post('/login', loginValidation, authController.login);
router.get('/me', auth, authController.getProfile);

module.exports = router;
```

### 8. Create Auth Middleware (`src/middleware/auth.js`)
```javascript
const jwt = require('jsonwebtoken');
const User = require('../models/User');

module.exports = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({
        success: false,
        error: 'Access denied. No token provided.'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.userId);
    
    if (!user) {
      return res.status(401).json({
        success: false,
        error: 'Invalid token.'
      });
    }

    req.userId = user._id;
    next();
  } catch (error) {
    res.status(401).json({
      success: false,
      error: 'Invalid token.'
    });
  }
};
```

### 9. Create Environment File (`.env`)
```env
PORT=3001
MONGODB_URI=mongodb://localhost:27017/quiz_learn_db
JWT_SECRET=your_super_secret_jwt_key_here
NODE_ENV=development
```

### 10. Update Package.json Scripts
```json
{
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js"
  }
}
```

## Testing the Backend

1. Start the server:
   ```bash
   npm run dev
   ```

2. Test the health endpoint:
   ```bash
   curl http://localhost:3001/api/health
   ```

3. Test registration:
   ```bash
   curl -X POST http://localhost:3001/api/auth/register \
     -H "Content-Type: application/json" \
     -d '{"name":"Test User","email":"test@example.com","password":"password123"}'
   ```

## Updating Flutter App

After setting up the backend, update the API URL in your Flutter app:

1. Open `lib/services/api_service.dart`
2. Change the `baseUrl`:
   ```dart
   static const String baseUrl = "http://YOUR_IP_ADDRESS:3001/api";
   ```
   
   For local testing on same network:
   ```dart
   static const String baseUrl = "http://192.168.1.100:3001/api";
   ```

## Common Issues and Solutions

### 1. Connection Refused
- Ensure the backend server is running
- Check if the port is correct
- Verify the IP address is accessible from your device

### 2. CORS Issues
- The backend includes CORS middleware
- If issues persist, check the CORS configuration

### 3. Database Connection
- Ensure MongoDB is running
- Check the connection string in `.env`
- Verify database permissions

### 4. JWT Token Issues
- Check if JWT_SECRET is set in `.env`
- Verify token expiration settings

## Next Steps

Once the backend is working:

1. Implement quiz functionality
2. Add wallet and transaction features
3. Implement referral system
4. Add admin panel
5. Deploy to production

## Support

If you encounter issues:
1. Check the console logs
2. Verify all environment variables
3. Ensure all dependencies are installed
4. Check database connectivity
