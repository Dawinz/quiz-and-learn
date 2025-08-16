const AppData = require('../models/AppData');
const Wallet = require('../models/Wallet');
const Transaction = require('../models/Transaction');
const { successResponse, errorResponse, notFoundResponse } = require('../utils/response');
const asyncHandler = require('../utils/asyncHandler');

// Spin wheel prizes configuration
const SPIN_PRIZES = [
  { result: '10 coins', coins: 10, probability: 0.3 },
  { result: '25 coins', coins: 25, probability: 0.25 },
  { result: '50 coins', coins: 50, probability: 0.2 },
  { result: '100 coins', coins: 100, probability: 0.15 },
  { result: '200 coins', coins: 200, probability: 0.08 },
  { result: '500 coins', coins: 500, probability: 0.02 }
];

// Generate spin result based on probabilities
const generateSpinResult = () => {
  const random = Math.random();
  let cumulativeProbability = 0;
  
  for (const prize of SPIN_PRIZES) {
    cumulativeProbability += prize.probability;
    if (random <= cumulativeProbability) {
      return prize;
    }
  }
  
  // Fallback to first prize
  return SPIN_PRIZES[0];
};

// @desc    Play spin wheel
// @route   POST /api/spin/play
// @access  Private
const playSpin = asyncHandler(async (req, res) => {
  // Get user's spin data
  let spinData = await AppData.findByUserAndApp(req.user._id, 'spin_and_earn');
  
  if (!spinData) {
    // Create spin data if it doesn't exist
    spinData = await AppData.create({
      userId: req.user._id,
      appName: 'spin_and_earn'
    });
  }

  // Check if user can spin today
  if (!spinData.canSpinToday()) {
    return errorResponse(res, 'Daily spin limit reached. Try again tomorrow!', 400);
  }

  // Generate spin result
  const spinResult = generateSpinResult();
  
  try {
    // Update spin data (this will save the document)
    await spinData.updateSpinData(
      spinResult.result,
      spinResult.coins,
      spinResult.coins / 10 // Simple multiplier calculation
    );

    // Add coins to wallet (this will save the wallet document)
    const wallet = await Wallet.findByUserId(req.user._id);
    if (wallet) {
      await wallet.addCoins(spinResult.coins);

      // Create transaction record
      await Transaction.create({
        userId: req.user._id,
        type: 'earn',
        amount: spinResult.coins,
        source: 'spin',
        description: `Won ${spinResult.coins} coins from spin wheel`,
        balanceBefore: wallet.balance - spinResult.coins,
        balanceAfter: wallet.balance,
        metadata: {
          spinResult: spinResult.result,
          spinMultiplier: spinResult.coins / 10
        }
      });
    }

    // Get fresh data after updates
    const updatedSpinData = await AppData.findByUserAndApp(req.user._id, 'spin_and_earn');
    const updatedWallet = await Wallet.findByUserId(req.user._id);

    successResponse(res, {
      prize: {
        result: spinResult.result,
        coins: spinResult.coins
      },
      coinsEarned: spinResult.coins,
      multiplier: spinResult.coins / 10,
      newBalance: updatedWallet ? updatedWallet.balance : 0,
      spinData: {
        dailySpinsUsed: updatedSpinData.spinData.dailySpinsUsed,
        dailySpinsLimit: updatedSpinData.spinData.dailySpinsLimit,
        totalSpins: updatedSpinData.spinData.totalSpins,
        totalCoinsFromSpins: updatedSpinData.spinData.totalCoinsFromSpins,
        canSpinToday: updatedSpinData.canSpinToday(),
        achievements: updatedSpinData.spinData.achievements
      }
    }, 'Spin completed successfully!');
  } catch (error) {
    return errorResponse(res, error.message, 400);
  }
});

// @desc    Get spin status
// @route   GET /api/spin/status
// @access  Private
const getSpinStatus = asyncHandler(async (req, res) => {
  let spinData = await AppData.findByUserAndApp(req.user._id, 'spin_and_earn');
  
  if (!spinData) {
    // Create spin data if it doesn't exist
    spinData = await AppData.create({
      userId: req.user._id,
      appName: 'spin_and_earn'
    });
  }

  // Check if user can spin today
  const canSpinToday = spinData.canSpinToday();

  successResponse(res, {
    canSpinToday,
    dailySpinsUsed: spinData.spinData.dailySpinsUsed,
    dailySpinsLimit: spinData.spinData.dailySpinsLimit,
    totalSpins: spinData.spinData.totalSpins,
    totalCoinsFromSpins: spinData.spinData.totalCoinsFromSpins,
    lastSpinDate: spinData.spinData.lastSpinDate,
    achievements: spinData.spinData.achievements,
    prizes: SPIN_PRIZES.map(prize => ({
      result: prize.result,
      probability: prize.probability
    }))
  }, 'Spin status retrieved successfully');
});

// @desc    Get spin history
// @route   GET /api/spin/history
// @access  Private
const getSpinHistory = asyncHandler(async (req, res) => {
  const { page = 1, limit = 20 } = req.query;

  const spinData = await AppData.findByUserAndApp(req.user._id, 'spin_and_earn');
  
  if (!spinData) {
    return notFoundResponse(res, 'Spin data');
  }

  const spinHistory = spinData.spinData.spinHistory;
  
  // Sort by timestamp (newest first)
  spinHistory.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));

  // Pagination
  const startIndex = (page - 1) * limit;
  const endIndex = page * limit;
  const paginatedHistory = spinHistory.slice(startIndex, endIndex);

  successResponse(res, {
    history: paginatedHistory,
    total: spinHistory.length,
    page: parseInt(page),
    limit: parseInt(limit),
    totalPages: Math.ceil(spinHistory.length / limit)
  }, 'Spin history retrieved successfully');
});

// @desc    Get spin statistics
// @route   GET /api/spin/stats
// @access  Private
const getSpinStats = asyncHandler(async (req, res) => {
  const spinData = await AppData.findByUserAndApp(req.user._id, 'spin_and_earn');
  
  if (!spinData) {
    return notFoundResponse(res, 'Spin data');
  }

  // Calculate statistics
  const totalSpins = spinData.spinData.totalSpins;
  const totalCoinsEarned = spinData.spinData.totalCoinsFromSpins;
  const averageCoinsPerSpin = totalSpins > 0 ? totalCoinsEarned / totalSpins : 0;
  
  // Calculate today's spins
  const today = new Date().toDateString();
  const todaySpins = spinData.spinData.spinHistory.filter(spin => 
    new Date(spin.timestamp).toDateString() === today
  ).length;

  // Calculate this week's spins
  const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
  const weekSpins = spinData.spinData.spinHistory.filter(spin => 
    new Date(spin.timestamp) >= weekAgo
  ).length;

  // Calculate this month's spins
  const monthAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
  const monthSpins = spinData.spinData.spinHistory.filter(spin => 
    new Date(spin.timestamp) >= monthAgo
  ).length;

  successResponse(res, {
    totalSpins,
    totalCoinsEarned,
    averageCoinsPerSpin: Math.round(averageCoinsPerSpin * 100) / 100,
    todaySpins,
    weekSpins,
    monthSpins,
    achievements: spinData.spinData.achievements,
    dailySpinsLimit: spinData.spinData.dailySpinsLimit,
    canSpinToday: spinData.canSpinToday()
  }, 'Spin statistics retrieved successfully');
});

module.exports = {
  playSpin,
  getSpinStatus,
  getSpinHistory,
  getSpinStats
}; 