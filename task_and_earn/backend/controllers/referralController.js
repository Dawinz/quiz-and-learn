const User = require('../models/User');
const AppData = require('../models/AppData');
const Wallet = require('../models/Wallet');
const Transaction = require('../models/Transaction');
const { successResponse, errorResponse, notFoundResponse } = require('../utils/response');
const asyncHandler = require('../utils/asyncHandler');

// Referral reward configuration
const REFERRAL_REWARDS = {
  referrer: 100, // Coins for referrer
  referred: 50   // Bonus coins for referred user
};

// @desc    Add referral
// @route   POST /api/referrals/add
// @access  Private
const addReferral = asyncHandler(async (req, res) => {
  const { referralCode } = req.body;

  if (!referralCode) {
    return errorResponse(res, 'Referral code is required', 400);
  }

  // Check if user already has a referrer
  const currentUser = await User.findById(req.user._id);
  if (currentUser.referredBy) {
    return errorResponse(res, 'User already has a referrer', 400);
  }

  // Find referrer by referral code
  const referrer = await User.findByReferralCode(referralCode);
  if (!referrer) {
    return errorResponse(res, 'Invalid referral code', 400);
  }

  // Prevent self-referral
  if (referrer._id.toString() === req.user._id.toString()) {
    return errorResponse(res, 'Cannot refer yourself', 400);
  }

  try {
    // Update current user with referrer
    await User.findByIdAndUpdate(req.user._id, {
      referredBy: referrer._id
    });

    // Update referrer's referral count
    await User.findByIdAndUpdate(referrer._id, {
      $inc: { referralCount: 1 }
    });

    // Add coins to referrer
    const referrerWallet = await Wallet.findByUserId(referrer._id);
    if (referrerWallet) {
      await referrerWallet.addCoins(REFERRAL_REWARDS.referrer);

      // Create transaction for referrer
      await Transaction.create({
        userId: referrer._id,
        type: 'referral',
        amount: REFERRAL_REWARDS.referrer,
        source: 'referral',
        description: `Referral bonus for referring ${currentUser.name}`,
        balanceBefore: referrerWallet.balance - REFERRAL_REWARDS.referrer,
        balanceAfter: referrerWallet.balance,
        metadata: {
          referredUserId: req.user._id,
          referralCode: referralCode
        }
      });
    }

    // Add bonus coins to referred user
    const userWallet = await Wallet.findByUserId(req.user._id);
    if (userWallet) {
      await userWallet.addCoins(REFERRAL_REWARDS.referred);

      // Create transaction for referred user
      await Transaction.create({
        userId: req.user._id,
        type: 'referral',
        amount: REFERRAL_REWARDS.referred,
        source: 'referral',
        description: 'Sign-up bonus from referral',
        balanceBefore: userWallet.balance - REFERRAL_REWARDS.referred,
        balanceAfter: userWallet.balance,
        metadata: {
          referredUserId: req.user._id,
          referralCode: referralCode
        }
      });
    }

    // Update referral data in app data
    let referrerAppData = await AppData.findByUserAndApp(referrer._id, 'refer_earn');
    if (!referrerAppData) {
      referrerAppData = await AppData.create({
        userId: referrer._id,
        appName: 'refer_earn'
      });
    }
    await referrerAppData.updateReferralData(req.user._id, REFERRAL_REWARDS.referrer);

    successResponse(res, {
      referrer: {
        name: referrer.name,
        referralCode: referrer.referralCode
      },
      rewards: {
        referrer: REFERRAL_REWARDS.referrer,
        referred: REFERRAL_REWARDS.referred
      }
    }, 'Referral added successfully');
  } catch (error) {
    return errorResponse(res, error.message, 400);
  }
});

// @desc    Get referral statistics
// @route   GET /api/referrals/stats
// @access  Private
const getReferralStats = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id).populate('referredBy', 'name email');
  
  if (!user) {
    return notFoundResponse(res, 'User');
  }

  // Get referral app data
  let referralAppData = await AppData.findByUserAndApp(req.user._id, 'refer_earn');
  if (!referralAppData) {
    referralAppData = await AppData.create({
      userId: req.user._id,
      appName: 'refer_earn'
    });
  }

  // Get referred users
  const referredUsers = await User.find({ referredBy: req.user._id }).select('name email createdAt');

  // Get wallet for earnings calculation
  const wallet = await Wallet.findByUserId(req.user._id);
  const totalReferralEarnings = wallet ? wallet.totalEarned : 0;

  successResponse(res, {
    referralCode: user.referralCode,
    referredBy: user.referredBy,
    referralCount: user.referralCount,
    referralEarnings: user.referralEarnings,
    totalReferralEarnings,
    referredUsers: referredUsers.map(user => ({
      name: user.name,
      email: user.email,
      joinedAt: user.createdAt
    })),
    appData: {
      totalReferrals: referralAppData.referralData.totalReferrals,
      totalCoinsFromReferrals: referralAppData.referralData.totalCoinsFromReferrals,
      referralHistory: referralAppData.referralData.referralHistory
    }
  }, 'Referral statistics retrieved successfully');
});

// @desc    Get referral link
// @route   GET /api/referrals/link
// @access  Private
const getReferralLink = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id);
  
  if (!user) {
    return notFoundResponse(res, 'User');
  }

  const baseUrl = process.env.FRONTEND_URL || 'https://yourapp.com';
  const referralLink = `${baseUrl}/register?ref=${user.referralCode}`;

  successResponse(res, {
    referralCode: user.referralCode,
    referralLink,
    shareText: `Join me on the 5-in-1 Earning System and earn coins together! Use my referral code: ${user.referralCode}`
  }, 'Referral link generated successfully');
});

// @desc    Get referral history
// @route   GET /api/referrals/history
// @access  Private
const getReferralHistory = asyncHandler(async (req, res) => {
  const { page = 1, limit = 20 } = req.query;

  // Get referral transactions
  const query = { 
    userId: req.user._id, 
    type: 'referral',
    source: 'referral'
  };

  const skip = (page - 1) * limit;
  
  const referrals = await Transaction.find(query)
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(parseInt(limit))
    .populate('metadata.referredUserId', 'name email');

  const total = await Transaction.countDocuments(query);

  successResponse(res, {
    referrals,
    total,
    page: parseInt(page),
    limit: parseInt(limit),
    totalPages: Math.ceil(total / limit)
  }, 'Referral history retrieved successfully');
});

// @desc    Validate referral code
// @route   POST /api/referrals/validate
// @access  Public
const validateReferralCode = asyncHandler(async (req, res) => {
  const { referralCode } = req.body;

  if (!referralCode) {
    return errorResponse(res, 'Referral code is required', 400);
  }

  const referrer = await User.findByReferralCode(referralCode);
  
  if (!referrer) {
    return errorResponse(res, 'Invalid referral code', 400);
  }

  successResponse(res, {
    valid: true,
    referrer: {
      name: referrer.name,
      referralCode: referrer.referralCode
    }
  }, 'Referral code is valid');
});

module.exports = {
  addReferral,
  getReferralStats,
  getReferralLink,
  getReferralHistory,
  validateReferralCode
}; 