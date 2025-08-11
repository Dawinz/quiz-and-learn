const express = require('express');
const { protect } = require('../middleware/auth');
const {
  playSpin,
  getSpinStatus,
  getSpinHistory,
  getSpinStats
} = require('../controllers/spinController');

const router = express.Router();

// All routes require authentication
router.use(protect);

// Routes
router.post('/play', playSpin);
router.get('/status', getSpinStatus);
router.get('/history', getSpinHistory);
router.get('/stats', getSpinStats);

module.exports = router; 