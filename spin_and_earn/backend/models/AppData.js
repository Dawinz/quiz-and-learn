const mongoose = require('mongoose');

const spinHistorySchema = new mongoose.Schema({
  spinId: {
    type: String,
    required: true
  },
  result: {
    type: String,
    required: true
  },
  coinsEarned: {
    type: Number,
    required: true,
    min: 0
  },
  multiplier: {
    type: Number,
    default: 1
  },
  timestamp: {
    type: Date,
    default: Date.now
  }
});

const taskCompletionSchema = new mongoose.Schema({
  taskId: {
    type: String,
    required: true
  },
  taskType: {
    type: String,
    enum: ['survey', 'video', 'download', 'signup', 'custom'],
    required: true
  },
  title: {
    type: String,
    required: true
  },
  coinsEarned: {
    type: Number,
    required: true,
    min: 0
  },
  completedAt: {
    type: Date,
    default: Date.now
  },
  status: {
    type: String,
    enum: ['pending', 'completed', 'verified', 'rejected'],
    default: 'pending'
  },
  metadata: {
    surveyId: String,
    videoUrl: String,
    appName: String,
    customData: mongoose.Schema.Types.Mixed
  }
});

const surveyResponseSchema = new mongoose.Schema({
  surveyId: {
    type: String,
    required: true
  },
  surveyTitle: {
    type: String,
    required: true
  },
  coinsEarned: {
    type: Number,
    required: true,
    min: 0
  },
  completedAt: {
    type: Date,
    default: Date.now
  },
  responses: {
    type: mongoose.Schema.Types.Mixed,
    default: {}
  }
});

const appDataSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User ID is required']
  },
  appName: {
    type: String,
    enum: ['spin_and_earn', 'wallet_hub', 'survey_earn', 'task_earn', 'refer_earn'],
    required: [true, 'App name is required']
  },
  // Spin & Earn specific data
  spinData: {
    dailySpinsUsed: {
      type: Number,
      default: 0,
      min: 0
    },
    dailySpinsLimit: {
      type: Number,
      default: 10,
      min: 1
    },
    lastSpinDate: {
      type: Date,
      default: null
    },
    totalSpins: {
      type: Number,
      default: 0,
      min: 0
    },
    totalCoinsFromSpins: {
      type: Number,
      default: 0,
      min: 0
    },
    spinHistory: [spinHistorySchema],
    favoriteSpins: [String], // Array of favorite spin results
    achievements: {
      firstSpin: { type: Boolean, default: false },
      tenSpins: { type: Boolean, default: false },
      hundredSpins: { type: Boolean, default: false },
      bigWin: { type: Boolean, default: false }
    }
  },
  // Survey & Earn specific data
  surveyData: {
    totalSurveysCompleted: {
      type: Number,
      default: 0,
      min: 0
    },
    totalCoinsFromSurveys: {
      type: Number,
      default: 0,
      min: 0
    },
    surveyHistory: [surveyResponseSchema],
    preferredCategories: [String], // Array of preferred survey categories
    averageCompletionTime: {
      type: Number,
      default: 0
    }
  },
  // Task & Earn specific data
  taskData: {
    totalTasksCompleted: {
      type: Number,
      default: 0,
      min: 0
    },
    totalCoinsFromTasks: {
      type: Number,
      default: 0,
      min: 0
    },
    taskHistory: [taskCompletionSchema],
    skills: [String], // Array of user skills for task matching
    preferredTaskTypes: [String] // Array of preferred task types
  },
  // Refer & Earn specific data
  referralData: {
    totalReferrals: {
      type: Number,
      default: 0,
      min: 0
    },
    totalCoinsFromReferrals: {
      type: Number,
      default: 0,
      min: 0
    },
    referralHistory: [{
      referredUserId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
      },
      referredAt: {
        type: Date,
        default: Date.now
      },
      coinsEarned: {
        type: Number,
        default: 0
      },
      status: {
        type: String,
        enum: ['pending', 'active', 'completed'],
        default: 'pending'
      }
    }],
    referralCode: {
      type: String,
      unique: true,
      sparse: true
    },
    referralLink: {
      type: String,
      default: null
    }
  },
  // General app preferences and settings
  preferences: {
    notifications: {
      email: { type: Boolean, default: true },
      push: { type: Boolean, default: true },
      sms: { type: Boolean, default: false }
    },
    privacy: {
      shareData: { type: Boolean, default: false },
      publicProfile: { type: Boolean, default: false }
    },
    theme: {
      type: String,
      enum: ['light', 'dark', 'auto'],
      default: 'auto'
    },
    language: {
      type: String,
      default: 'en'
    }
  },
  // App usage statistics
  usageStats: {
    lastActive: {
      type: Date,
      default: Date.now
    },
    totalSessions: {
      type: Number,
      default: 0
    },
    totalTimeSpent: {
      type: Number,
      default: 0 // in minutes
    },
    averageSessionTime: {
      type: Number,
      default: 0 // in minutes
    }
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for app summary
appDataSchema.virtual('appSummary').get(function() {
  const summary = {
    appName: this.appName,
    isActive: this.isActive,
    lastActive: this.usageStats.lastActive,
    totalSessions: this.usageStats.totalSessions
  };

  // Add app-specific summaries
  switch (this.appName) {
    case 'spin_and_earn':
      summary.dailySpinsUsed = this.spinData.dailySpinsUsed;
      summary.dailySpinsLimit = this.spinData.dailySpinsLimit;
      summary.totalSpins = this.spinData.totalSpins;
      summary.totalCoinsFromSpins = this.spinData.totalCoinsFromSpins;
      break;
    case 'survey_earn':
      summary.totalSurveysCompleted = this.surveyData.totalSurveysCompleted;
      summary.totalCoinsFromSurveys = this.surveyData.totalCoinsFromSurveys;
      break;
    case 'task_earn':
      summary.totalTasksCompleted = this.taskData.totalTasksCompleted;
      summary.totalCoinsFromTasks = this.taskData.totalCoinsFromTasks;
      break;
    case 'refer_earn':
      summary.totalReferrals = this.referralData.totalReferrals;
      summary.totalCoinsFromReferrals = this.referralData.totalCoinsFromReferrals;
      break;
  }

  return summary;
});

// Index for better query performance
// Note: Indexes are already defined in the schema fields

// Pre-save middleware to update last active
appDataSchema.pre('save', function(next) {
  this.usageStats.lastActive = new Date();
  next();
});

// Instance method to update spin data
appDataSchema.methods.updateSpinData = function(spinResult, coinsEarned, multiplier = 1) {
  if (this.appName !== 'spin_and_earn') {
    throw new Error('This method is only available for spin_and_earn app');
  }

  const today = new Date().toDateString();
  const lastSpinDate = this.spinData.lastSpinDate ? new Date(this.spinData.lastSpinDate).toDateString() : null;

  // Reset daily spins if it's a new day
  if (lastSpinDate !== today) {
    this.spinData.dailySpinsUsed = 0;
  }

  // Update spin data
  this.spinData.dailySpinsUsed += 1;
  this.spinData.lastSpinDate = new Date();
  this.spinData.totalSpins += 1;
  this.spinData.totalCoinsFromSpins += coinsEarned;

  // Add to spin history
  this.spinData.spinHistory.push({
    spinId: `spin_${Date.now()}`,
    result: spinResult,
    coinsEarned,
    multiplier,
    timestamp: new Date()
  });

  // Update achievements
  if (!this.spinData.achievements.firstSpin) {
    this.spinData.achievements.firstSpin = true;
  }
  if (this.spinData.totalSpins >= 10 && !this.spinData.achievements.tenSpins) {
    this.spinData.achievements.tenSpins = true;
  }
  if (this.spinData.totalSpins >= 100 && !this.spinData.achievements.hundredSpins) {
    this.spinData.achievements.hundredSpins = true;
  }
  if (coinsEarned >= 100 && !this.spinData.achievements.bigWin) {
    this.spinData.achievements.bigWin = true;
  }

  return this.save();
};

// Instance method to check if user can spin today
appDataSchema.methods.canSpinToday = function() {
  if (this.appName !== 'spin_and_earn') {
    return false;
  }

  const today = new Date().toDateString();
  const lastSpinDate = this.spinData.lastSpinDate ? new Date(this.spinData.lastSpinDate).toDateString() : null;

  // If it's a new day, reset daily spins
  if (lastSpinDate !== today) {
    this.spinData.dailySpinsUsed = 0;
    this.save();
  }

  return this.spinData.dailySpinsUsed < this.spinData.dailySpinsLimit;
};

// Instance method to update survey data
appDataSchema.methods.updateSurveyData = function(surveyId, surveyTitle, coinsEarned, responses = {}) {
  if (this.appName !== 'survey_earn') {
    throw new Error('This method is only available for survey_earn app');
  }

  this.surveyData.totalSurveysCompleted += 1;
  this.surveyData.totalCoinsFromSurveys += coinsEarned;

  this.surveyData.surveyHistory.push({
    surveyId,
    surveyTitle,
    coinsEarned,
    responses,
    completedAt: new Date()
  });

  return this.save();
};

// Instance method to update task data
appDataSchema.methods.updateTaskData = function(taskId, taskType, title, coinsEarned, metadata = {}) {
  if (this.appName !== 'task_earn') {
    throw new Error('This method is only available for task_earn app');
  }

  this.taskData.totalTasksCompleted += 1;
  this.taskData.totalCoinsFromTasks += coinsEarned;

  this.taskData.taskHistory.push({
    taskId,
    taskType,
    title,
    coinsEarned,
    status: 'completed',
    metadata
  });

  return this.save();
};

// Instance method to update referral data
appDataSchema.methods.updateReferralData = function(referredUserId, coinsEarned) {
  if (this.appName !== 'refer_earn') {
    throw new Error('This method is only available for refer_earn app');
  }

  this.referralData.totalReferrals += 1;
  this.referralData.totalCoinsFromReferrals += coinsEarned;

  this.referralData.referralHistory.push({
    referredUserId,
    coinsEarned,
    status: 'active'
  });

  return this.save();
};

// Static method to find app data by user and app
appDataSchema.statics.findByUserAndApp = function(userId, appName) {
  return this.findOne({ userId, appName });
};

// Static method to get all app data for a user
appDataSchema.statics.getUserAppData = function(userId) {
  return this.find({ userId }).sort({ appName: 1 });
};

module.exports = mongoose.model('AppData', appDataSchema); 