const Wallet = require('../models/Wallet');
const Transaction = require('../models/Transaction');
const { successResponse, errorResponse, notFoundResponse, paginatedResponse } = require('../utils/response');
const asyncHandler = require('../utils/asyncHandler');

// @desc    Get wallet balance
// @route   GET /api/wallet/balance
// @access  Private
const getBalance = asyncHandler(async (req, res) => {
  const wallet = await Wallet.findByUserId(req.user._id);
  
  if (!wallet) {
    return notFoundResponse(res, 'Wallet');
  }

  successResponse(res, {
    balance: wallet.balance,
    availableBalance: wallet.availableBalance,
    totalEarned: wallet.totalEarned,
    totalSpent: wallet.totalSpent,
    totalWithdrawn: wallet.totalWithdrawn,
    goals: wallet.goals,
    pendingWithdrawalsCount: wallet.pendingWithdrawalsCount,
    pendingAmount: wallet.pendingAmount
  }, 'Wallet balance retrieved successfully');
});

// @desc    Request withdrawal
// @route   POST /api/wallet/withdraw
// @access  Private
const requestWithdrawal = asyncHandler(async (req, res) => {
  const { amount, method, accountDetails } = req.body;

  const wallet = await Wallet.findByUserId(req.user._id);
  if (!wallet) {
    return notFoundResponse(res, 'Wallet');
  }

  try {
    // Request withdrawal
    await wallet.requestWithdrawal(amount, method, accountDetails);

    // Create transaction record
    await Transaction.create({
      userId: req.user._id,
      type: 'withdrawal',
      amount,
      source: 'withdrawal',
      description: `Withdrawal request for ${amount} coins via ${method}`,
      balanceBefore: wallet.balance + amount, // Balance before withdrawal
      balanceAfter: wallet.balance, // Balance after withdrawal
      metadata: {
        withdrawalId: wallet.withdrawals[wallet.withdrawals.length - 1]._id,
        withdrawalMethod: method
      }
    });

    successResponse(res, {
      withdrawal: wallet.withdrawals[wallet.withdrawals.length - 1],
      newBalance: wallet.balance
    }, 'Withdrawal request submitted successfully');
  } catch (error) {
    return errorResponse(res, error.message, 400);
  }
});

// @desc    Get withdrawal history
// @route   GET /api/wallet/withdrawals
// @access  Private
const getWithdrawals = asyncHandler(async (req, res) => {
  const { page = 1, limit = 10, status } = req.query;

  const wallet = await Wallet.findByUserId(req.user._id);
  if (!wallet) {
    return notFoundResponse(res, 'Wallet');
  }

  let withdrawals = wallet.withdrawals;

  // Filter by status if provided
  if (status) {
    withdrawals = withdrawals.filter(w => w.status === status);
  }

  // Sort by creation date (newest first)
  withdrawals.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

  // Pagination
  const startIndex = (page - 1) * limit;
  const endIndex = page * limit;
  const paginatedWithdrawals = withdrawals.slice(startIndex, endIndex);

  successResponse(res, {
    withdrawals: paginatedWithdrawals,
    total: withdrawals.length,
    page: parseInt(page),
    limit: parseInt(limit),
    totalPages: Math.ceil(withdrawals.length / limit)
  }, 'Withdrawal history retrieved successfully');
});

// @desc    Update wallet goals
// @route   PUT /api/wallet/goals
// @access  Private
const updateGoals = asyncHandler(async (req, res) => {
  const { weeklyTarget, monthlyTarget } = req.body;

  const wallet = await Wallet.findByUserId(req.user._id);
  if (!wallet) {
    return notFoundResponse(res, 'Wallet');
  }

  await wallet.updateGoals(weeklyTarget, monthlyTarget);

  successResponse(res, {
    goals: wallet.goals
  }, 'Goals updated successfully');
});

// @desc    Get wallet statistics
// @route   GET /api/wallet/stats
// @access  Private
const getWalletStats = asyncHandler(async (req, res) => {
  const { period = 'all' } = req.query;

  const wallet = await Wallet.findByUserId(req.user._id);
  if (!wallet) {
    return notFoundResponse(res, 'Wallet');
  }

  // Get transaction statistics
  const transactionStats = await Transaction.getTransactionStats(req.user._id, period);
  const earningsBySource = await Transaction.getEarningsBySource(req.user._id, period);

  successResponse(res, {
    wallet: {
      balance: wallet.balance,
      availableBalance: wallet.availableBalance,
      totalEarned: wallet.totalEarned,
      totalSpent: wallet.totalSpent,
      totalWithdrawn: wallet.totalWithdrawn,
      goals: wallet.goals
    },
    transactions: transactionStats,
    earningsBySource,
    period
  }, 'Wallet statistics retrieved successfully');
});

// @desc    Get recent transactions
// @route   GET /api/wallet/transactions
// @access  Private
const getTransactions = asyncHandler(async (req, res) => {
  const { page = 1, limit = 20, type, source } = req.query;

  const options = {
    page: parseInt(page),
    limit: parseInt(limit),
    type,
    source
  };

  const transactions = await Transaction.getUserTransactions(req.user._id, options);
  const total = await Transaction.countDocuments({ userId: req.user._id });

  paginatedResponse(res, transactions, page, limit, total);
});

// @desc    Get transaction by ID
// @route   GET /api/wallet/transactions/:id
// @access  Private
const getTransaction = asyncHandler(async (req, res) => {
  const transaction = await Transaction.findById(req.params.id)
    .populate('userId', 'name email')
    .populate('metadata.referredUserId', 'name email')
    .populate('metadata.adminId', 'name email');

  if (!transaction) {
    return notFoundResponse(res, 'Transaction');
  }

  // Check if transaction belongs to user
  if (transaction.userId.toString() !== req.user._id.toString()) {
    return errorResponse(res, 'Not authorized to view this transaction', 403);
  }

  successResponse(res, transaction, 'Transaction retrieved successfully');
});

module.exports = {
  getBalance,
  requestWithdrawal,
  getWithdrawals,
  updateGoals,
  getWalletStats,
  getTransactions,
  getTransaction
}; 