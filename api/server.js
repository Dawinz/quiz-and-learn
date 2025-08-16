const express = require('express');
const cors = require('cors');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    message: 'Quiz & Learn Backend API is running',
    timestamp: new Date().toISOString(),
    environment: 'production'
  });
});

// Test endpoint
app.get('/api/test', (req, res) => {
  res.json({
    success: true,
    message: 'API routing is working',
    timestamp: new Date().toISOString()
  });
});

// Auth endpoints (mock for now)
app.post('/api/auth/register', (req, res) => {
  const { name, email, password } = req.body;
  
  if (!name || !email || !password) {
    return res.status(400).json({
      success: false,
      error: 'Missing required fields'
    });
  }
  
  res.json({
    success: true,
    message: 'User registered successfully',
    data: {
      user: { name, email },
      token: 'mock_token_' + Date.now()
    }
  });
});

app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;
  
  if (!email || !password) {
    return res.status(400).json({
      success: false,
      error: 'Missing required fields'
    });
  }
  
  res.json({
    success: true,
    message: 'Login successful',
    data: {
      user: { email },
      token: 'mock_token_' + Date.now()
    }
  });
});

app.get('/api/auth/me', (req, res) => {
  res.json({
    success: true,
    data: {
      user: {
        name: 'Test User',
        email: 'test@example.com'
      }
    }
  });
});

// Quiz endpoints (mock for now)
app.get('/api/quizzes', (req, res) => {
  res.json({
    success: true,
    data: {
      quizzes: [
        {
          id: '1',
          title: 'Sample Quiz',
          description: 'A sample quiz for testing',
          category: 'general',
          difficulty: 'easy'
        }
      ]
    }
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

// Export for Vercel
module.exports = app;
