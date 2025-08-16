const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const {
  getQuizzes,
  getQuizById,
  submitQuiz
} = require('../controllers/quizController');

// Protected routes
router.use(protect);
router.get('/', getQuizzes);
router.get('/:id', getQuizById);
router.post('/:id/submit', submitQuiz);

module.exports = router; 