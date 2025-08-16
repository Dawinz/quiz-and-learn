const User = require('../models/User');
const Wallet = require('../models/Wallet');
const AppData = require('../models/AppData');
const { generateToken } = require('../middleware/auth');
const { successResponse, errorResponse, notFoundResponse } = require('../utils/response');
const asyncHandler = require('../utils/asyncHandler');

// @desc    Register user
// @route   POST /api/auth/register
// @access  Public
const register = asyncHandler(async (req, res) => {
  const { name, email, password, phone, referralCode } = req.body;

  // Check if user already exists
  const existingUser = await User.findByEmail(email);
  if (existingUser) {
    return errorResponse(res, 'User already exists', 400);
  }

  // Handle referral code
  let referredBy = null;
  if (referralCode) {
    const referrer = await User.findByReferralCode(referralCode);
    if (referrer) {
      referredBy = referrer._id;
    }
  }

  // Create user
  const user = await User.create({
    name,
    email,
    password,
    phone,
    referredBy
  });

  // Create wallet for user
  await Wallet.create({
    userId: user._id,
    balance: 0,
    goals: {
      weeklyTarget: 0,
      monthlyTarget: 0,
      progress: 0
    }
  });

  // Create app data for all apps
  const apps = ['spin_and_earn', 'wallet_hub', 'survey_earn', 'task_earn', 'refer_earn'];
  for (const appName of apps) {
    await AppData.create({
      userId: user._id,
      appName
    });
  }

  // Generate token
  const token = generateToken(user._id);

  // Update referrer's referral count if applicable
  if (referredBy) {
    await User.findByIdAndUpdate(referredBy, {
      $inc: { referralCount: 1 }
    });
  }

  successResponse(res, {
    user: user.profile,
    token
  }, 'User registered successfully', 201);
});

// @desc    Login user
// @route   POST /api/auth/login
// @access  Public
const login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  // Check if user exists
  const user = await User.findByEmail(email).select('+password');
  if (!user) {
    return errorResponse(res, 'Invalid credentials', 401);
  }

  // Check if user is active
  if (!user.isActive) {
    return errorResponse(res, 'Account is deactivated', 401);
  }

  // Check password
  const isMatch = await user.comparePassword(password);
  if (!isMatch) {
    return errorResponse(res, 'Invalid credentials', 401);
  }

  // Update last login
  await user.updateLastLogin();

  // Generate token
  const token = generateToken(user._id);

  successResponse(res, {
    user: user.profile,
    token
  }, 'Login successful');
});

// @desc    Get current user profile
// @route   GET /api/auth/me
// @access  Private
const getProfile = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id);
  
  if (!user) {
    return notFoundResponse(res, 'User');
  }

  // Get wallet data
  const wallet = await Wallet.findByUserId(user._id);
  
  // Get app data summary
  const appData = await AppData.getUserAppData(user._id);
  const appSummaries = appData.map(app => app.appSummary);

  successResponse(res, {
    user: user.profile,
    wallet: wallet ? {
      balance: wallet.balance,
      availableBalance: wallet.availableBalance,
      totalEarned: wallet.totalEarned,
      totalSpent: wallet.totalSpent,
      totalWithdrawn: wallet.totalWithdrawn,
      goals: wallet.goals,
      pendingWithdrawalsCount: wallet.pendingWithdrawalsCount,
      pendingAmount: wallet.pendingAmount
    } : null,
    apps: appSummaries
  }, 'Profile retrieved successfully');
});

// @desc    Update user profile
// @route   PUT /api/auth/me
// @access  Private
const updateProfile = asyncHandler(async (req, res) => {
  const { name, phone, profilePicture } = req.body;

  const user = await User.findById(req.user._id);
  if (!user) {
    return notFoundResponse(res, 'User');
  }

  // Update fields
  if (name) user.name = name;
  if (phone !== undefined) user.phone = phone;
  if (profilePicture !== undefined) user.profilePicture = profilePicture;

  await user.save();

  successResponse(res, {
    user: user.profile
  }, 'Profile updated successfully');
});

// @desc    Change password
// @route   PUT /api/auth/change-password
// @access  Private
const changePassword = asyncHandler(async (req, res) => {
  const { currentPassword, newPassword } = req.body;

  const user = await User.findById(req.user._id).select('+password');
  if (!user) {
    return notFoundResponse(res, 'User');
  }

  // Check current password
  const isMatch = await user.comparePassword(currentPassword);
  if (!isMatch) {
    return errorResponse(res, 'Current password is incorrect', 400);
  }

  // Update password
  user.password = newPassword;
  await user.save();

  successResponse(res, null, 'Password changed successfully');
});

// @desc    Refresh token
// @route   POST /api/auth/refresh
// @access  Private
const refreshToken = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id);
  
  if (!user) {
    return notFoundResponse(res, 'User');
  }

  // Generate new token
  const token = generateToken(user._id);

  successResponse(res, {
    user: user.profile,
    token
  }, 'Token refreshed successfully');
});

module.exports = {
  register,
  login,
  getProfile,
  updateProfile,
  changePassword,
  refreshToken
}; 