const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5001;

// Security middleware
app.use(helmet());

// CORS configuration
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000,
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
  message: 'Too many requests from this IP, please try again later.'
});
app.use('/api/', limiter);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging middleware
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    message: '5-in-1 Earning System API is running (Test Mode)',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV
  });
});

// Test endpoints
app.get('/api/test', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'API is working correctly',
    data: {
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV
    }
  });
});

// Test authentication endpoint
app.post('/api/auth/test-login', (req, res) => {
  const { email, password } = req.body;
  
  if (email === 'test@example.com' && password === 'password123') {
    res.status(200).json({
      success: true,
      message: 'Test login successful',
      data: {
        user: {
          id: 'test-user-id',
          name: 'Test User',
          email: 'test@example.com',
          totalCoins: 1000,
          roles: ['user']
        },
        token: 'test-jwt-token-12345'
      }
    });
  } else {
    res.status(401).json({
      success: false,
      error: 'Invalid credentials'
    });
  }
});

// Test wallet endpoint
app.get('/api/wallet/test-balance', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Test wallet balance retrieved',
    data: {
      balance: 1000,
      availableBalance: 950,
      totalEarned: 1500,
      totalSpent: 500,
      totalWithdrawn: 0,
      goals: {
        weeklyTarget: 500,
        monthlyTarget: 2000,
        progress: 75
      },
      pendingWithdrawalsCount: 0,
      pendingAmount: 0
    }
  });
});

// Test spin endpoint
app.post('/api/spin/test-play', (req, res) => {
  const spinResult = {
    result: '50 coins',
    coinsEarned: 50,
    multiplier: 5,
    newBalance: 1050
  };
  
  res.status(200).json({
    success: true,
    message: 'Test spin completed successfully!',
    data: spinResult
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
    path: req.originalUrl
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('❌ Error:', err);
  res.status(500).json({
    success: false,
    error: 'Internal Server Error'
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Test Server running on port ${PORT}`);
  console.log(`📊 Environment: ${process.env.NODE_ENV}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
  console.log(`🧪 Test endpoints available`);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err, promise) => {
  console.error('❌ Unhandled Rejection:', err);
  process.exit(1);
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  console.error('❌ Uncaught Exception:', err);
  process.exit(1);
}); 