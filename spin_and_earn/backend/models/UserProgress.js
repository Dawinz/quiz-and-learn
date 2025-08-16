const mongoose = require('mongoose');

const userProgressSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User ID is required']
  },
  app: {
    type: String,
    enum: ['spin', 'task', 'quiz', 'survey'],
    required: [true, 'App type is required']
  },
  // Task & Earn specific fields
  taskProgress: {
    completedTasks: [{
      taskId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Task'
      },
      completedAt: {
        type: Date,
        default: Date.now
      },
      reward: Number,
      rating: {
        type: Number,
        min: 1,
        max: 5
      }
    }],
    dailyCompletions: {
      type: Number,
      default: 0
    },
    lastResetDate: {
      type: Date,
      default: Date.now
    },
    streak: {
      type: Number,
      default: 0
    },
    totalEarnings: {
      type: Number,
      default: 0
    }
  },
  // Quiz & Learn specific fields
  quizProgress: {
    completedQuizzes: [{
      quizId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Quiz'
      },
      completedAt: {
        type: Date,
        default: Date.now
      },
      score: Number,
      timeTaken: Number, // in seconds
      reward: Number,
      attempts: {
        type: Number,
        default: 1
      }
    }],
    categoryStats: {
      finance: { totalScore: { type: Number, default: 0 }, attempts: { type: Number, default: 0 }, averageScore: { type: Number, default: 0 } },
      technology: { totalScore: { type: Number, default: 0 }, attempts: { type: Number, default: 0 }, averageScore: { type: Number, default: 0 } },
      health: { totalScore: { type: Number, default: 0 }, attempts: { type: Number, default: 0 }, averageScore: { type: Number, default: 0 } },
      education: { totalScore: { type: Number, default: 0 }, attempts: { type: Number, default: 0 }, averageScore: { type: Number, default: 0 } },
      entertainment: { totalScore: { type: Number, default: 0 }, attempts: { type: Number, default: 0 }, averageScore: { type: Number, default: 0 } },
      sports: { totalScore: { type: Number, default: 0 }, attempts: { type: Number, default: 0 }, averageScore: { type: Number, default: 0 } },
      science: { totalScore: { type: Number, default: 0 }, attempts: { type: Number, default: 0 }, averageScore: { type: Number, default: 0 } },
      history: { totalScore: { type: Number, default: 0 }, attempts: { type: Number, default: 0 }, averageScore: { type: Number, default: 0 } }
    },
    streak: {
      type: Number,
      default: 0
    },
    totalEarnings: {
      type: Number,
      default: 0
    },
    perfectScores: {
      type: Number,
      default: 0
    }
  },
  // Spin & Earn specific fields
  spinProgress: {
    totalSpins: {
      type: Number,
      default: 0
    },
    dailySpins: {
      type: Number,
      default: 0
    },
    lastSpinDate: {
      type: Date,
      default: Date.now
    },
    streak: {
      type: Number,
      default: 0
    },
    totalEarnings: {
      type: Number,
      default: 0
    }
  },
  // General progress fields
  achievements: [{
    id: String,
    name: String,
    description: String,
    unlockedAt: {
      type: Date,
      default: Date.now
    },
    icon: String
  }],
  milestones: [{
    type: String,
    value: Number,
    achievedAt: {
      type: Date,
      default: Date.now
    }
  }],
  lastActivity: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for overall progress summary
userProgressSchema.virtual('summary').get(function() {
  return {
    userId: this.userId,
    app: this.app,
    totalEarnings: this.getTotalEarnings(),
    streak: this.getCurrentStreak(),
    achievements: this.achievements.length,
    lastActivity: this.lastActivity
  };
});

// Index for better query performance
userProgressSchema.index({ userId: 1, app: 1 });
userProgressSchema.index({ lastActivity: -1 });

// Instance method to get total earnings for this app
userProgressSchema.methods.getTotalEarnings = function() {
  switch (this.app) {
    case 'task':
      return this.taskProgress.totalEarnings;
    case 'quiz':
      return this.quizProgress.totalEarnings;
    case 'spin':
      return this.spinProgress.totalEarnings;
    default:
      return 0;
  }
};

// Instance method to get current streak
userProgressSchema.methods.getCurrentStreak = function() {
  switch (this.app) {
    case 'task':
      return this.taskProgress.streak;
    case 'quiz':
      return this.quizProgress.streak;
    case 'spin':
      return this.spinProgress.streak;
    default:
      return 0;
  }
};

// Instance method to update daily completions
userProgressSchema.methods.updateDailyCompletions = function() {
  const today = new Date();
  const lastReset = new Date(this.taskProgress.lastResetDate);
  
  // Reset daily completions if it's a new day
  if (today.toDateString() !== lastReset.toDateString()) {
    this.taskProgress.dailyCompletions = 0;
    this.taskProgress.lastResetDate = today;
  }
  
  this.taskProgress.dailyCompletions += 1;
  return this.save();
};

// Instance method to update streak
userProgressSchema.methods.updateStreak = function() {
  const today = new Date();
  const lastActivity = new Date(this.lastActivity);
  
  // Check if user was active yesterday
  const yesterday = new Date(today);
  yesterday.setDate(yesterday.getDate() - 1);
  
  if (lastActivity.toDateString() === yesterday.toDateString()) {
    // Continue streak
    switch (this.app) {
      case 'task':
        this.taskProgress.streak += 1;
        break;
      case 'quiz':
        this.quizProgress.streak += 1;
        break;
      case 'spin':
        this.spinProgress.streak += 1;
        break;
    }
  } else if (lastActivity.toDateString() !== today.toDateString()) {
    // Reset streak if more than 1 day gap
    switch (this.app) {
      case 'task':
        this.taskProgress.streak = 1;
        break;
      case 'quiz':
        this.quizProgress.streak = 1;
        break;
      case 'spin':
        this.spinProgress.streak = 1;
        break;
    }
  }
  
  this.lastActivity = today;
  return this.save();
};

// Static method to get user progress by app
userProgressSchema.statics.getUserProgress = function(userId, app) {
  return this.findOne({ userId, app });
};

// Static method to get all user progress
userProgressSchema.statics.getAllUserProgress = function(userId) {
  return this.find({ userId });
};

module.exports = mongoose.model('UserProgress', userProgressSchema); 