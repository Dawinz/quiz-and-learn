const express = require('express');
const { body } = require('express-validator');
const { protect } = require('../middleware/auth');
const { handleValidationErrors } = require('../middleware/validate');
const {
  addReferral,
  getReferralStats,
  getReferralLink,
  getReferralHistory,
  validateReferralCode
} = require('../controllers/referralController');

const router = express.Router();

// Validation rules
const referralValidation = [
  body('referralCode')
    .isLength({ min: 6, max: 10 })
    .withMessage('Referral code must be between 6 and 10 characters')
];

// Routes
router.post('/add', protect, referralValidation, handleValidationErrors, addReferral);
router.get('/stats', protect, getReferralStats);
router.get('/link', protect, getReferralLink);
router.get('/history', protect, getReferralHistory);
router.post('/validate', referralValidation, handleValidationErrors, validateReferralCode);

module.exports = router; 