const asyncHandler = require('../utils/asyncHandler');
const Task = require('../models/Task');
const UserProgress = require('../models/UserProgress');
const Wallet = require('../models/Wallet');
const Transaction = require('../models/Transaction');
const { successResponse, errorResponse } = require('../utils/response');

// @desc    Get all available tasks
// @route   GET /api/tasks
// @access  Private
const getTasks = asyncHandler(async (req, res) => {
  const { category, type, difficulty, page = 1, limit = 20 } = req.query;
  
  const filter = { isActive: true };
  if (category) filter.category = category;
  if (type) filter.type = type;
  if (difficulty) filter.difficulty = difficulty;
  
  const skip = (page - 1) * limit;
  
  const tasks = await Task.find(filter)
    .sort({ reward: -1, createdAt: -1 })
    .skip(skip)
    .limit(parseInt(limit));
  
  const total = await Task.countDocuments(filter);
  
  res.json(successResponse('Tasks retrieved successfully', {
    tasks,
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      total,
      pages: Math.ceil(total / limit)
    }
  }));
});

// @desc    Get task by ID
// @route   GET /api/tasks/:id
// @access  Private
const getTaskById = asyncHandler(async (req, res) => {
  const task = await Task.findById(req.params.id);
  
  if (!task) {
    return res.status(404).json(errorResponse('Task not found'));
  }
  
  if (!task.isActive) {
    return res.status(400).json(errorResponse('Task is not available'));
  }
  
  res.json(successResponse('Task retrieved successfully', { task }));
});

// @desc    Get recommended tasks for user
// @route   GET /api/tasks/recommended
// @access  Private
const getRecommendedTasks = asyncHandler(async (req, res) => {
  const tasks = await Task.getRecommendedTasks(req.user.id);
  
  res.json(successResponse('Recommended tasks retrieved successfully', { tasks }));
});

// @desc    Submit task completion
// @route   POST /api/tasks/:id/complete
// @access  Private
const completeTask = asyncHandler(async (req, res) => {
  const { rating, feedback } = req.body;
  const taskId = req.params.id;
  const userId = req.user.id;
  
  // Get task
  const task = await Task.findById(taskId);
  if (!task || !task.isActive) {
    return res.status(404).json(errorResponse('Task not found or unavailable'));
  }
  
  // Get or create user progress
  let userProgress = await UserProgress.getUserProgress(userId, 'task');
  if (!userProgress) {
    userProgress = new UserProgress({
      userId,
      app: 'task'
    });
  }
  
  // Check if user already completed this task today
  const today = new Date();
  const alreadyCompleted = userProgress.taskProgress.completedTasks.some(completion => {
    const completionDate = new Date(completion.completedAt);
    return completion.taskId.toString() === taskId && 
           completionDate.toDateString() === today.toDateString();
  });
  
  if (alreadyCompleted) {
    return res.status(400).json(errorResponse('Task already completed today'));
  }
  
  // Check daily limit
  await userProgress.updateDailyCompletions();
  if (userProgress.taskProgress.dailyCompletions > task.dailyLimit) {
    return res.status(400).json(errorResponse('Daily task limit reached'));
  }
  
  // Calculate reward (with potential bonus for streak)
  let reward = task.reward;
  const streak = userProgress.taskProgress.streak;
  
  // Streak bonus (every 7 days = 50% bonus)
  if (streak > 0 && streak % 7 === 0) {
    reward = Math.floor(reward * 1.5);
  }
  
  // Update user progress
  userProgress.taskProgress.completedTasks.push({
    taskId,
    completedAt: new Date(),
    reward,
    rating: rating || null
  });
  
  userProgress.taskProgress.totalEarnings += reward;
  await userProgress.updateStreak();
  await userProgress.save();
  
  // Update task stats
  task.totalCompletions += 1;
  if (rating) {
    const currentTotal = task.averageRating * (task.totalCompletions - 1);
    task.averageRating = (currentTotal + rating) / task.totalCompletions;
  }
  await task.save();
  
  // Update wallet
  const wallet = await Wallet.findByUserId(userId);
  if (wallet) {
    await wallet.addCoins(reward, 'task', `Completed task: ${task.title}`);
  }
  
  // Create transaction
  await Transaction.create({
    userId,
    type: 'earn',
    amount: reward,
    source: 'task',
    description: `Task completion: ${task.title}`,
    metadata: {
      taskId,
      taskTitle: task.title,
      taskType: task.type,
      rating,
      streak: userProgress.taskProgress.streak
    }
  });
  
  res.json(successResponse('Task completed successfully', {
    reward,
    totalEarnings: userProgress.taskProgress.totalEarnings,
    streak: userProgress.taskProgress.streak,
    dailyCompletions: userProgress.taskProgress.dailyCompletions
  }));
});

// @desc    Get user task progress
// @route   GET /api/tasks/progress
// @access  Private
const getUserTaskProgress = asyncHandler(async (req, res) => {
  const userProgress = await UserProgress.getUserProgress(req.user.id, 'task');
  
  if (!userProgress) {
    return res.json(successResponse('No task progress found', {
      progress: {
        totalEarnings: 0,
        streak: 0,
        dailyCompletions: 0,
        completedTasks: []
      }
    }));
  }
  
  res.json(successResponse('Task progress retrieved successfully', {
    progress: {
      totalEarnings: userProgress.taskProgress.totalEarnings,
      streak: userProgress.taskProgress.streak,
      dailyCompletions: userProgress.taskProgress.dailyCompletions,
      completedTasks: userProgress.taskProgress.completedTasks
    }
  }));
});

// @desc    Get task categories
// @route   GET /api/tasks/categories
// @access  Public
const getTaskCategories = asyncHandler(async (req, res) => {
  const categories = await Task.distinct('category');
  
  res.json(successResponse('Task categories retrieved successfully', { categories }));
});

// @desc    Get task types
// @route   GET /api/tasks/types
// @access  Public
const getTaskTypes = asyncHandler(async (req, res) => {
  const types = await Task.distinct('type');
  
  res.json(successResponse('Task types retrieved successfully', { types }));
});

module.exports = {
  getTasks,
  getTaskById,
  getRecommendedTasks,
  completeTask,
  getUserTaskProgress,
  getTaskCategories,
  getTaskTypes
}; 