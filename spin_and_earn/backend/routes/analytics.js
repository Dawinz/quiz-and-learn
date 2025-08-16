const express = require('express');
const { protect } = require('../middleware/auth');
const {
  getUserDashboard,
  getSpinEarnAnalytics,
  getAppPerformance,
  getUserEngagement
} = require('../controllers/analyticsController');

const router = express.Router();

// All routes require authentication
router.use(protect);

// User analytics routes
router.get('/user-dashboard', getUserDashboard);
router.get('/spin-earn', getSpinEarnAnalytics);

// Admin analytics routes (require admin role)
router.get('/app-performance', getAppPerformance);
router.get('/engagement', getUserEngagement);

module.exports = router;
