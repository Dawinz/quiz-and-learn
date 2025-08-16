const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const {
  getTasks,
  getTaskById,
  getRecommendedTasks,
  completeTask,
  getUserTaskProgress,
  getTaskCategories,
  getTaskTypes
} = require('../controllers/taskController');

// Public routes
router.get('/categories', getTaskCategories);
router.get('/types', getTaskTypes);

// Protected routes
router.use(protect);
router.get('/', getTasks);
router.get('/recommended', getRecommendedTasks);
router.get('/progress', getUserTaskProgress);
router.get('/:id', getTaskById);
router.post('/:id/complete', completeTask);

module.exports = router; 