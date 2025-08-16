const express = require('express');
const app = express();
const PORT = 8080;

app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    message: '5-in-1 Earning System API is running',
    timestamp: new Date().toISOString()
  });
});

// Test endpoint
app.get('/api/test', (req, res) => {
  res.json({
    success: true,
    message: 'API is working!',
    data: {
      timestamp: new Date().toISOString()
    }
  });
});

// Test auth endpoint
app.post('/api/auth/test', (req, res) => {
  res.json({
    success: true,
    message: 'Test authentication endpoint',
    data: {
      user: {
        id: 'test-user',
        name: 'Test User',
        email: 'test@example.com'
      },
      token: 'test-token-123'
    }
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Simple server running on http://localhost:${PORT}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
}); 