const mongoose = require('mongoose');

const quizSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Quiz title is required'],
    trim: true,
    maxlength: [100, 'Title cannot exceed 100 characters']
  },
  description: {
    type: String,
    required: [true, 'Quiz description is required'],
    trim: true,
    maxlength: [500, 'Description cannot exceed 500 characters']
  },
  category: {
    type: String,
    enum: ['finance', 'technology', 'health', 'education', 'entertainment', 'sports', 'science', 'history'],
    required: [true, 'Quiz category is required']
  },
  difficulty: {
    type: String,
    enum: ['easy', 'medium', 'hard', 'expert'],
    default: 'easy'
  },
  timeLimit: {
    type: Number, // in seconds
    default: 300, // 5 minutes
    min: [30, 'Time limit must be at least 30 seconds'],
    max: [1800, 'Time limit cannot exceed 30 minutes']
  },
  questions: [{
    question: {
      type: String,
      required: [true, 'Question text is required'],
      trim: true
    },
    options: {
      type: [String],
      required: [true, 'Question options are required'],
      validate: {
        validator: function(v) {
          return v.length >= 2 && v.length <= 6;
        },
        message: 'Question must have between 2 and 6 options'
      }
    },
    correctAnswer: {
      type: Number,
      required: [true, 'Correct answer index is required'],
      min: [0, 'Correct answer index must be 0 or greater']
    },
    explanation: {
      type: String,
      trim: true
    },
    points: {
      type: Number,
      default: 10,
      min: [1, 'Points must be at least 1'],
      max: [50, 'Points cannot exceed 50']
    }
  }],
  reward: {
    baseReward: {
      type: Number,
      required: [true, 'Base reward is required'],
      min: [1, 'Base reward must be at least 1 coin'],
      max: [200, 'Base reward cannot exceed 200 coins']
    },
    perfectScoreBonus: {
      type: Number,
      default: 50,
      min: [0, 'Perfect score bonus cannot be negative']
    },
    timeBonus: {
      type: Number,
      default: 25,
      min: [0, 'Time bonus cannot be negative']
    }
  },
  requirements: {
    minScore: {
      type: Number,
      default: 60,
      min: [0, 'Minimum score cannot be negative'],
      max: [100, 'Minimum score cannot exceed 100']
    },
    maxAttempts: {
      type: Number,
      default: 3,
      min: [1, 'Maximum attempts must be at least 1'],
      max: [10, 'Maximum attempts cannot exceed 10']
    }
  },
  isActive: {
    type: Boolean,
    default: true
  },
  isFeatured: {
    type: Boolean,
    default: false
  },
  totalAttempts: {
    type: Number,
    default: 0
  },
  averageScore: {
    type: Number,
    default: 0,
    min: 0,
    max: 100
  },
  averageTime: {
    type: Number, // in seconds
    default: 0
  },
  tags: [String],
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for quiz summary
quizSchema.virtual('summary').get(function() {
  return {
    id: this._id,
    title: this.title,
    category: this.category,
    difficulty: this.difficulty,
    timeLimit: this.timeLimit,
    questionCount: this.questions.length,
    baseReward: this.reward.baseReward,
    isActive: this.isActive,
    isFeatured: this.isFeatured,
    totalAttempts: this.totalAttempts,
    averageScore: this.averageScore
  };
});

// Virtual for total possible points
quizSchema.virtual('totalPoints').get(function() {
  return this.questions.reduce((total, question) => total + question.points, 0);
});

// Index for better query performance
quizSchema.index({ category: 1, isActive: 1 });
quizSchema.index({ difficulty: 1, isFeatured: 1 });
quizSchema.index({ createdAt: -1 });

// Static method to get active quizzes by category
quizSchema.statics.getActiveQuizzesByCategory = function(category) {
  return this.find({ 
    category: category, 
    isActive: true 
  }).sort({ isFeatured: -1, averageScore: -1 });
};

// Static method to get featured quizzes
quizSchema.statics.getFeaturedQuizzes = function() {
  return this.find({ 
    isFeatured: true, 
    isActive: true 
  }).sort({ createdAt: -1 });
};

// Static method to get quizzes by difficulty
quizSchema.statics.getQuizzesByDifficulty = function(difficulty) {
  return this.find({ 
    difficulty: difficulty, 
    isActive: true 
  }).sort({ averageScore: -1 });
};

// Instance method to calculate reward
quizSchema.methods.calculateReward = function(score, timeTaken) {
  let reward = this.reward.baseReward;
  
  // Perfect score bonus
  if (score === 100) {
    reward += this.reward.perfectScoreBonus;
  }
  
  // Time bonus (faster = more bonus)
  const timeBonus = Math.max(0, this.reward.timeBonus - Math.floor(timeTaken / 30));
  reward += timeBonus;
  
  return reward;
};

module.exports = mongoose.model('Quiz', quizSchema); 