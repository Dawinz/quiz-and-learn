const mongoose = require('mongoose');

const taskSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Task title is required'],
    trim: true,
    maxlength: [100, 'Title cannot exceed 100 characters']
  },
  description: {
    type: String,
    required: [true, 'Task description is required'],
    trim: true,
    maxlength: [500, 'Description cannot exceed 500 characters']
  },
  type: {
    type: String,
    enum: ['video', 'article', 'quiz', 'survey'],
    required: [true, 'Task type is required']
  },
  category: {
    type: String,
    enum: ['education', 'finance', 'technology', 'health', 'lifestyle', 'entertainment'],
    required: [true, 'Task category is required']
  },
  difficulty: {
    type: String,
    enum: ['easy', 'medium', 'hard'],
    default: 'easy'
  },
  duration: {
    type: Number, // in minutes
    required: [true, 'Task duration is required'],
    min: [1, 'Duration must be at least 1 minute'],
    max: [60, 'Duration cannot exceed 60 minutes']
  },
  reward: {
    type: Number,
    required: [true, 'Task reward is required'],
    min: [1, 'Reward must be at least 1 coin'],
    max: [100, 'Reward cannot exceed 100 coins']
  },
  content: {
    videoUrl: String,
    articleUrl: String,
    quizQuestions: [{
      question: String,
      options: [String],
      correctAnswer: Number,
      explanation: String
    }],
    surveyQuestions: [{
      question: String,
      type: {
        type: String,
        enum: ['multiple_choice', 'text', 'rating']
      },
      options: [String],
      required: Boolean
    }]
  },
  requirements: {
    minAge: {
      type: Number,
      default: 13
    },
    location: [String],
    deviceType: [String]
  },
  isActive: {
    type: Boolean,
    default: true
  },
  dailyLimit: {
    type: Number,
    default: 1
  },
  totalCompletions: {
    type: Number,
    default: 0
  },
  averageRating: {
    type: Number,
    default: 0,
    min: 0,
    max: 5
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

// Virtual for task summary
taskSchema.virtual('summary').get(function() {
  return {
    id: this._id,
    title: this.title,
    type: this.type,
    category: this.category,
    difficulty: this.difficulty,
    duration: this.duration,
    reward: this.reward,
    isActive: this.isActive,
    totalCompletions: this.totalCompletions,
    averageRating: this.averageRating
  };
});

// Index for better query performance
taskSchema.index({ type: 1, category: 1, isActive: 1 });
taskSchema.index({ difficulty: 1, reward: 1 });
taskSchema.index({ createdAt: -1 });

// Static method to get active tasks by category
taskSchema.statics.getActiveTasksByCategory = function(category) {
  return this.find({ 
    category: category, 
    isActive: true 
  }).sort({ reward: -1 });
};

// Static method to get tasks by type
taskSchema.statics.getTasksByType = function(type) {
  return this.find({ 
    type: type, 
    isActive: true 
  }).sort({ createdAt: -1 });
};

// Static method to get recommended tasks
taskSchema.statics.getRecommendedTasks = function(userId) {
  return this.find({ 
    isActive: true 
  }).sort({ averageRating: -1, reward: -1 }).limit(10);
};

module.exports = mongoose.model('Task', taskSchema); 