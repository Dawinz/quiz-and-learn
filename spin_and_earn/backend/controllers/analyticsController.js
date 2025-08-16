const User = require('../models/User');
const UserProgress = require('../models/UserProgress');
const Transaction = require('../models/Transaction');
const AppData = require('../models/AppData');
const Wallet = require('../models/Wallet');
const { successResponse, errorResponse } = require('../utils/response');
const asyncHandler = require('../utils/asyncHandler');

// @desc    Get user analytics dashboard
// @route   GET /api/analytics/user-dashboard
// @access  Private
const getUserDashboard = asyncHandler(async (req, res) => {
  const userId = req.user._id;
  
  // Get user's overall progress across all apps
  const userProgress = await UserProgress.getAllUserProgress(userId);
  
  // Get user's wallet and transaction data
  const wallet = await Wallet.findByUserId(userId);
  const transactions = await Transaction.find({ userId }).sort({ createdAt: -1 }).limit(10);
  
  // Calculate total earnings across all apps
  const totalEarnings = userProgress.reduce((sum, progress) => {
    return sum + progress.getTotalEarnings();
  }, 0);
  
  // Calculate total streak across all apps
  const totalStreak = userProgress.reduce((sum, progress) => {
    return sum + progress.getCurrentStreak();
  }, 0);
  
  // Get achievement count
  const totalAchievements = userProgress.reduce((sum, progress) => {
    return sum + progress.achievements.length;
  }, 0);
  
  // Calculate activity in last 7 days
  const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
  const recentActivity = userProgress.filter(progress => 
    progress.lastActivity >= weekAgo
  ).length;
  
  successResponse(res, {
    totalEarnings,
    totalStreak,
    totalAchievements,
    recentActivity,
    walletBalance: wallet ? wallet.balance : 0,
    recentTransactions: transactions,
    appProgress: userProgress.map(progress => ({
      app: progress.app,
      earnings: progress.getTotalEarnings(),
      streak: progress.getCurrentStreak(),
      lastActivity: progress.lastActivity
    }))
  }, 'User dashboard analytics retrieved successfully');
});

// @desc    Get spin and earn specific analytics
// @route   GET /api/analytics/spin-earn
// @access  Private
const getSpinEarnAnalytics = asyncHandler(async (req, res) => {
  const userId = req.user._id;
  
  // Get spin data
  const spinData = await AppData.findByUserAndApp(userId, 'spin_and_earn');
  const userProgress = await UserProgress.getUserProgress(userId, 'spin');
  
  if (!spinData || !userProgress) {
    return errorResponse(res, 'Spin data not found', 404);
  }
  
  // Calculate spin statistics
  const totalSpins = spinData.spinData.totalSpins;
  const totalCoinsEarned = spinData.spinData.totalCoinsFromSpins;
  const averageCoinsPerSpin = totalSpins > 0 ? totalCoinsEarned / totalSpins : 0;
  
  // Calculate daily spin trends (last 30 days)
  const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
  const dailySpins = [];
  
  for (let i = 0; i < 30; i++) {
    const date = new Date(Date.now() - i * 24 * 60 * 60 * 1000);
    const daySpins = spinData.spinData.spinHistory.filter(spin => 
      new Date(spin.timestamp).toDateString() === date.toDateString()
    ).length;
    
    dailySpins.unshift({
      date: date.toISOString().split('T')[0],
      spins: daySpins
    });
  }
  
  // Calculate best performing time slots
  const timeSlotStats = {};
  spinData.spinData.spinHistory.forEach(spin => {
    const hour = new Date(spin.timestamp).getHours();
    const timeSlot = `${hour}:00-${hour + 1}:00`;
    
    if (!timeSlotStats[timeSlot]) {
      timeSlotStats[timeSlot] = { spins: 0, totalCoins: 0 };
    }
    
    timeSlotStats[timeSlot].spins += 1;
    timeSlotStats[timeSlot].totalCoins += spin.coinsEarned;
  });
  
  // Convert to array and sort by spins
  const timeSlotArray = Object.entries(timeSlotStats).map(([slot, stats]) => ({
    timeSlot: slot,
    spins: stats.spins,
    totalCoins: stats.totalCoins,
    averageCoins: stats.spins > 0 ? stats.totalCoins / stats.spins : 0
  })).sort((a, b) => b.spins - a.spins);
  
  successResponse(res, {
    overview: {
      totalSpins,
      totalCoinsEarned,
      averageCoinsPerSpin: Math.round(averageCoinsPerSpin * 100) / 100,
      currentStreak: userProgress.spinProgress.streak,
      dailySpinsLimit: spinData.spinData.dailySpinsLimit,
      dailySpinsUsed: spinData.spinData.dailySpinsUsed
    },
    trends: {
      dailySpins,
      timeSlotPerformance: timeSlotArray.slice(0, 5) // Top 5 time slots
    },
    achievements: spinData.spinData.achievements,
    recentSpins: spinData.spinData.spinHistory.slice(-10).reverse() // Last 10 spins
  }, 'Spin and earn analytics retrieved successfully');
});

// @desc    Get app performance analytics (Admin only)
// @route   GET /api/analytics/app-performance
// @access  Private (Admin)
const getAppPerformance = asyncHandler(async (req, res) => {
  // Check if user is admin
  if (!req.user.roles.includes('admin')) {
    return errorResponse(res, 'Access denied. Admin role required.', 403);
  }
  
  // Get overall app statistics
  const totalUsers = await User.countDocuments({ isActive: true });
  const totalTransactions = await Transaction.countDocuments();
  const totalCoinsInCirculation = await Wallet.aggregate([
    { $group: { _id: null, total: { $sum: '$balance' } } }
  ]);
  
  // Get user growth over time (last 30 days)
  const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
  const userGrowth = await User.aggregate([
    { $match: { createdAt: { $gte: thirtyDaysAgo } } },
    {
      $group: {
        _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
        newUsers: { $sum: 1 }
      }
    },
    { $sort: { _id: 1 } }
  ]);
  
  // Get transaction volume over time
  const transactionVolume = await Transaction.aggregate([
    { $match: { createdAt: { $gte: thirtyDaysAgo } } },
    {
      $group: {
        _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
        totalAmount: { $sum: '$amount' },
        count: { $sum: 1 }
      }
    },
    { $sort: { _id: 1 } }
  ]);
  
  // Get top earning users
  const topEarners = await User.aggregate([
    { $match: { isActive: true } },
    { $sort: { totalCoins: -1 } },
    { $limit: 10 },
    {
      $project: {
        name: 1,
        email: 1,
        totalCoins: 1,
        referralCount: 1
      }
    }
  ]);
  
  // Get app usage statistics
  const appUsage = await UserProgress.aggregate([
    {
      $group: {
        _id: '$app',
        totalUsers: { $sum: 1 },
        totalEarnings: { $sum: { $switch: {
          branches: [
            { case: { $eq: ['$app', 'spin'] }, then: '$spinProgress.totalEarnings' },
            { case: { $eq: ['$app', 'task'] }, then: '$taskProgress.totalEarnings' },
            { case: { $eq: ['$app', 'quiz'] }, then: '$quizProgress.totalEarnings' }
          ],
          default: 0
        }}}
      }
    }
  ]);
  
  successResponse(res, {
    overview: {
      totalUsers,
      totalTransactions,
      totalCoinsInCirculation: totalCoinsInCirculation[0]?.total || 0
    },
    trends: {
      userGrowth,
      transactionVolume
    },
    topEarners,
    appUsage
  }, 'App performance analytics retrieved successfully');
});

// @desc    Get user engagement metrics
// @route   GET /api/analytics/engagement
// @access  Private (Admin)
const getUserEngagement = asyncHandler(async (req, res) => {
  // Check if user is admin
  if (!req.user.roles.includes('admin')) {
    return errorResponse(res, 'Access denied. Admin role required.', 403);
  }
  
  const { period = '7d' } = req.query;
  
  // Calculate period in milliseconds
  let periodMs;
  switch (period) {
    case '1d':
      periodMs = 24 * 60 * 60 * 1000;
      break;
    case '7d':
      periodMs = 7 * 24 * 60 * 60 * 1000;
      break;
    case '30d':
      periodMs = 30 * 24 * 60 * 60 * 1000;
      break;
    default:
      periodMs = 7 * 24 * 60 * 60 * 1000;
  }
  
  const periodStart = new Date(Date.now() - periodMs);
  
  // Get active users in period
  const activeUsers = await UserProgress.aggregate([
    { $match: { lastActivity: { $gte: periodStart } } },
    { $group: { _id: '$userId' } },
    { $count: 'total' }
  ]);
  
  // Get daily active users
  const dailyActiveUsers = await UserProgress.aggregate([
    { $match: { lastActivity: { $gte: periodStart } } },
    {
      $group: {
        _id: { $dateToString: { format: '%Y-%m-%d', date: '$lastActivity' } },
        uniqueUsers: { $addToSet: '$userId' }
      }
    },
    {
      $project: {
        date: '$_id',
        activeUsers: { $size: '$uniqueUsers' }
      }
    },
    { $sort: { date: 1 } }
  ]);
  
  // Get retention metrics
  const retentionData = await UserProgress.aggregate([
    { $match: { lastActivity: { $gte: periodStart } } },
    {
      $group: {
        _id: '$app',
        totalUsers: { $sum: 1 },
        usersWithStreak: {
          $sum: {
            $cond: [
              { $gt: [{ $switch: {
                branches: [
                  { case: { $eq: ['$app', 'spin'] }, then: '$spinProgress.streak' },
                  { case: { $eq: ['$app', 'task'] }, then: '$taskProgress.streak' },
                  { case: { $eq: ['$app', 'quiz'] }, then: '$quizProgress.streak' }
                ],
                default: 0
              }}, 0] },
              1,
              0
            ]
          }
        }
      }
    }
  ]);
  
  successResponse(res, {
    period,
    activeUsers: activeUsers[0]?.total || 0,
    dailyActiveUsers,
    retention: retentionData.map(app => ({
      app: app._id,
      totalUsers: app.totalUsers,
      usersWithStreak: app.usersWithStreak,
      retentionRate: app.totalUsers > 0 ? (app.usersWithStreak / app.totalUsers * 100).toFixed(2) : 0
    }))
  }, 'User engagement metrics retrieved successfully');
});

module.exports = {
  getUserDashboard,
  getSpinEarnAnalytics,
  getAppPerformance,
  getUserEngagement
};
