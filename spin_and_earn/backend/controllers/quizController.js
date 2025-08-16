const asyncHandler = require('../utils/asyncHandler');
const Quiz = require('../models/Quiz');
const UserProgress = require('../models/UserProgress');
const Wallet = require('../models/Wallet');
const Transaction = require('../models/Transaction');
const { successResponse, errorResponse } = require('../utils/response');

// Get all available quizzes
const getQuizzes = asyncHandler(async (req, res) => {
  const { category, difficulty, featured, page = 1, limit = 20 } = req.query;
  
  const filter = { isActive: true };
  if (category) filter.category = category;
  if (difficulty) filter.difficulty = difficulty;
  if (featured === 'true') filter.isFeatured = true;
  
  const skip = (page - 1) * limit;
  
  const quizzes = await Quiz.find(filter)
    .sort({ isFeatured: -1, averageScore: -1, createdAt: -1 })
    .skip(skip)
    .limit(parseInt(limit));
  
  const total = await Quiz.countDocuments(filter);
  
  res.json(successResponse('Quizzes retrieved successfully', {
    quizzes,
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      total,
      pages: Math.ceil(total / limit)
    }
  }));
});

// Get quiz by ID
const getQuizById = asyncHandler(async (req, res) => {
  const quiz = await Quiz.findById(req.params.id);
  
  if (!quiz) {
    return res.status(404).json(errorResponse('Quiz not found'));
  }
  
  if (!quiz.isActive) {
    return res.status(400).json(errorResponse('Quiz is not available'));
  }
  
  // Remove correct answers for security
  const quizForUser = quiz.toObject();
  quizForUser.questions = quizForUser.questions.map(q => ({
    question: q.question,
    options: q.options,
    points: q.points
  }));
  
  res.json(successResponse('Quiz retrieved successfully', { quiz: quizForUser }));
});

// Submit quiz answers
const submitQuiz = asyncHandler(async (req, res) => {
  const { answers, timeTaken } = req.body;
  const quizId = req.params.id;
  const userId = req.user.id;
  
  const quiz = await Quiz.findById(quizId);
  if (!quiz || !quiz.isActive) {
    return res.status(404).json(errorResponse('Quiz not found or unavailable'));
  }
  
  let userProgress = await UserProgress.getUserProgress(userId, 'quiz');
  if (!userProgress) {
    userProgress = new UserProgress({
      userId,
      app: 'quiz'
    });
  }
  
  // Calculate score
  let correctAnswers = 0;
  let totalPoints = 0;
  
  quiz.questions.forEach((question, index) => {
    const userAnswer = answers[index];
    const isCorrect = userAnswer === question.correctAnswer;
    
    if (isCorrect) {
      correctAnswers++;
      totalPoints += question.points;
    }
  });
  
  const score = Math.round((correctAnswers / quiz.questions.length) * 100);
  const reward = quiz.calculateReward(score, timeTaken);
  
  // Update user progress
  userProgress.quizProgress.completedQuizzes.push({
    quizId,
    completedAt: new Date(),
    score,
    timeTaken,
    reward,
    attempts: 1
  });
  
  userProgress.quizProgress.totalEarnings += reward;
  await userProgress.updateStreak();
  await userProgress.save();
  
  // Update wallet
  const wallet = await Wallet.findByUserId(userId);
  if (wallet) {
    await wallet.addCoins(reward, 'quiz', `Quiz completion: ${quiz.title}`);
  }
  
  res.json(successResponse('Quiz submitted successfully', {
    score,
    reward,
    totalEarnings: userProgress.quizProgress.totalEarnings,
    streak: userProgress.quizProgress.streak
  }));
});

module.exports = {
  getQuizzes,
  getQuizById,
  submitQuiz
}; 