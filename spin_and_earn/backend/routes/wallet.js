const express = require('express');
const { body } = require('express-validator');
const { protect } = require('../middleware/auth');
const { handleValidationErrors } = require('../middleware/validate');
const {
  getBalance,
  requestWithdrawal,
  getWithdrawals,
  updateGoals,
  getWalletStats,
  getTransactions,
  getTransaction
} = require('../controllers/walletController');

const router = express.Router();

// Validation rules
const withdrawalValidation = [
  body('amount')
    .isFloat({ min: 1 })
    .withMessage('Amount must be at least 1 coin'),
  body('method')
    .isIn(['paypal', 'bank_transfer', 'crypto', 'gift_card'])
    .withMessage('Invalid withdrawal method'),
  body('accountDetails')
    .notEmpty()
    .withMessage('Account details are required')
];

const goalsValidation = [
  body('weeklyTarget')
    .optional()
    .isFloat({ min: 0 })
    .withMessage('Weekly target must be a positive number'),
  body('monthlyTarget')
    .optional()
    .isFloat({ min: 0 })
    .withMessage('Monthly target must be a positive number')
];

// All routes require authentication
router.use(protect);

// Routes
router.get('/balance', getBalance);
router.post('/withdraw', withdrawalValidation, handleValidationErrors, requestWithdrawal);
router.get('/withdrawals', getWithdrawals);
router.put('/goals', goalsValidation, handleValidationErrors, updateGoals);
router.get('/stats', getWalletStats);
router.get('/transactions', getTransactions);
router.get('/transactions/:id', getTransaction);

module.exports = router; 