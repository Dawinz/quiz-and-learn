const express = require('express');
const { body } = require('express-validator');
const { protect } = require('../middleware/auth');
const { handleValidationErrors } = require('../middleware/validate');
const {
  addCoins,
  spendCoins,
  getCoinBalance,
  getEarningsHistory,
  getSpendingHistory
} = require('../controllers/coinsController');

const router = express.Router();

// Validation rules
const coinsValidation = [
  body('amount')
    .isFloat({ min: 0.01 })
    .withMessage('Amount must be at least 0.01'),
  body('source')
    .isIn(['spin', 'survey', 'task', 'referral', 'bonus', 'withdrawal', 'admin', 'system'])
    .withMessage('Invalid source'),
  body('description')
    .optional()
    .isLength({ max: 200 })
    .withMessage('Description cannot exceed 200 characters')
];

// All routes require authentication
router.use(protect);

// Routes
router.post('/add', coinsValidation, handleValidationErrors, addCoins);
router.post('/spend', coinsValidation, handleValidationErrors, spendCoins);
router.get('/balance', getCoinBalance);
router.get('/earnings', getEarningsHistory);
router.get('/spending', getSpendingHistory);

module.exports = router; 