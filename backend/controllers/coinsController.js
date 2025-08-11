const Wallet = require('../models/Wallet');
const Transaction = require('../models/Transaction');
const { successResponse, errorResponse, notFoundResponse } = require('../utils/response');
const asyncHandler = require('../utils/asyncHandler');

// @desc    Add coins to user wallet
// @route   POST /api/coins/add
// @access  Private
const addCoins = asyncHandler(async (req, res) => {
  const { amount, source, description, metadata = {} } = req.body;

  if (amount <= 0) {
    return errorResponse(res, 'Amount must be positive', 400);
  }

  const wallet = await Wallet.findByUserId(req.user._id);
  if (!wallet) {
    return notFoundResponse(res, 'Wallet');
  }

  try {
    // Add coins to wallet
    await wallet.addCoins(amount);

    // Create transaction record
    const transaction = await Transaction.create({
      userId: req.user._id,
      type: 'earn',
      amount,
      source,
      description: description || `Earned ${amount} coins from ${source}`,
      balanceBefore: wallet.balance - amount, // Balance before adding
      balanceAfter: wallet.balance, // Balance after adding
      metadata
    });

    successResponse(res, {
      newBalance: wallet.balance,
      transaction: transaction.summary
    }, 'Coins added successfully');
  } catch (error) {
    return errorResponse(res, error.message, 400);
  }
});

// @desc    Spend coins from user wallet
// @route   POST /api/coins/spend
// @access  Private
const spendCoins = asyncHandler(async (req, res) => {
  const { amount, source, description, metadata = {} } = req.body;

  if (amount <= 0) {
    return errorResponse(res, 'Amount must be positive', 400);
  }

  const wallet = await Wallet.findByUserId(req.user._id);
  if (!wallet) {
    return notFoundResponse(res, 'Wallet');
  }

  try {
    // Spend coins from wallet
    await wallet.spendCoins(amount);

    // Create transaction record
    const transaction = await Transaction.create({
      userId: req.user._id,
      type: 'spend',
      amount,
      source,
      description: description || `Spent ${amount} coins on ${source}`,
      balanceBefore: wallet.balance + amount, // Balance before spending
      balanceAfter: wallet.balance, // Balance after spending
      metadata
    });

    successResponse(res, {
      newBalance: wallet.balance,
      transaction: transaction.summary
    }, 'Coins spent successfully');
  } catch (error) {
    return errorResponse(res, error.message, 400);
  }
});

// @desc    Get coin balance
// @route   GET /api/coins/balance
// @access  Private
const getCoinBalance = asyncHandler(async (req, res) => {
  const wallet = await Wallet.findByUserId(req.user._id);
  
  if (!wallet) {
    return notFoundResponse(res, 'Wallet');
  }

  successResponse(res, {
    balance: wallet.balance,
    availableBalance: wallet.availableBalance,
    totalEarned: wallet.totalEarned,
    totalSpent: wallet.totalSpent
  }, 'Coin balance retrieved successfully');
});

// @desc    Get coin earning history
// @route   GET /api/coins/earnings
// @access  Private
const getEarningsHistory = asyncHandler(async (req, res) => {
  const { page = 1, limit = 20, source, period = 'all' } = req.query;

  const query = { userId: req.user._id, type: 'earn' };
  
  // Add source filter if provided
  if (source) {
    query.source = source;
  }

  // Add period filter
  if (period !== 'all') {
    const dateFilter = {};
    if (period === 'today') {
      dateFilter.createdAt = { $gte: new Date().setHours(0, 0, 0, 0) };
    } else if (period === 'week') {
      dateFilter.createdAt = { $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) };
    } else if (period === 'month') {
      dateFilter.createdAt = { $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) };
    }
    Object.assign(query, dateFilter);
  }

  const skip = (page - 1) * limit;
  
  const earnings = await Transaction.find(query)
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(parseInt(limit));

  const total = await Transaction.countDocuments(query);

  successResponse(res, {
    earnings,
    total,
    page: parseInt(page),
    limit: parseInt(limit),
    totalPages: Math.ceil(total / limit)
  }, 'Earnings history retrieved successfully');
});

// @desc    Get coin spending history
// @route   GET /api/coins/spending
// @access  Private
const getSpendingHistory = asyncHandler(async (req, res) => {
  const { page = 1, limit = 20, source, period = 'all' } = req.query;

  const query = { userId: req.user._id, type: 'spend' };
  
  // Add source filter if provided
  if (source) {
    query.source = source;
  }

  // Add period filter
  if (period !== 'all') {
    const dateFilter = {};
    if (period === 'today') {
      dateFilter.createdAt = { $gte: new Date().setHours(0, 0, 0, 0) };
    } else if (period === 'week') {
      dateFilter.createdAt = { $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) };
    } else if (period === 'month') {
      dateFilter.createdAt = { $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) };
    }
    Object.assign(query, dateFilter);
  }

  const skip = (page - 1) * limit;
  
  const spending = await Transaction.find(query)
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(parseInt(limit));

  const total = await Transaction.countDocuments(query);

  successResponse(res, {
    spending,
    total,
    page: parseInt(page),
    limit: parseInt(limit),
    totalPages: Math.ceil(total / limit)
  }, 'Spending history retrieved successfully');
});

module.exports = {
  addCoins,
  spendCoins,
  getCoinBalance,
  getEarningsHistory,
  getSpendingHistory
}; 