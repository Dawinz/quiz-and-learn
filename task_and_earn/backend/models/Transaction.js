const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User ID is required']
  },
  type: {
    type: String,
    enum: ['earn', 'spend', 'withdrawal', 'refund', 'bonus', 'referral'],
    required: [true, 'Transaction type is required']
  },
  amount: {
    type: Number,
    required: [true, 'Amount is required'],
    min: [0.01, 'Amount must be at least 0.01']
  },
  source: {
    type: String,
    enum: ['spin', 'survey', 'task', 'referral', 'bonus', 'withdrawal', 'admin', 'system'],
    required: [true, 'Source is required']
  },
  description: {
    type: String,
    required: [true, 'Description is required'],
    maxlength: [200, 'Description cannot exceed 200 characters']
  },
  balanceBefore: {
    type: Number,
    required: [true, 'Balance before is required']
  },
  balanceAfter: {
    type: Number,
    required: [true, 'Balance after is required']
  },
  metadata: {
    // For spin transactions
    spinResult: {
      type: String,
      default: null
    },
    spinMultiplier: {
      type: Number,
      default: null
    },
    // For survey/task transactions
    surveyId: {
      type: String,
      default: null
    },
    taskId: {
      type: String,
      default: null
    },
    // For referral transactions
    referredUserId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null
    },
    referralCode: {
      type: String,
      default: null
    },
    // For withdrawal transactions
    withdrawalId: {
      type: mongoose.Schema.Types.ObjectId,
      default: null
    },
    withdrawalMethod: {
      type: String,
      default: null
    },
    // For admin/system transactions
    adminId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null
    },
    reason: {
      type: String,
      default: null
    }
  },
  status: {
    type: String,
    enum: ['completed', 'pending', 'failed', 'cancelled'],
    default: 'completed'
  },
  isReversible: {
    type: Boolean,
    default: false
  },
  reversedAt: {
    type: Date,
    default: null
  },
  reversedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null
  },
  reversalReason: {
    type: String,
    default: null
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for transaction summary
transactionSchema.virtual('summary').get(function() {
  return {
    id: this._id,
    type: this.type,
    amount: this.amount,
    source: this.source,
    description: this.description,
    balanceBefore: this.balanceBefore,
    balanceAfter: this.balanceAfter,
    status: this.status,
    createdAt: this.createdAt
  };
});

// Virtual for formatted amount
transactionSchema.virtual('formattedAmount').get(function() {
  const sign = this.type === 'earn' || this.type === 'bonus' || this.type === 'referral' ? '+' : '-';
  return `${sign}${this.amount} coins`;
});

// Index for better query performance
// Note: Indexes are already defined in the schema fields

// Pre-save middleware to validate balance consistency
transactionSchema.pre('save', function(next) {
  // Validate that balanceAfter = balanceBefore + amount (for earn) or - amount (for spend)
  const expectedBalanceAfter = this.type === 'earn' || this.type === 'bonus' || this.type === 'referral' 
    ? this.balanceBefore + this.amount 
    : this.balanceBefore - this.amount;
  
  if (Math.abs(this.balanceAfter - expectedBalanceAfter) > 0.01) {
    return next(new Error('Balance inconsistency detected'));
  }
  
  next();
});

// Instance method to reverse transaction
transactionSchema.methods.reverse = function(reversedBy, reason) {
  if (this.reversedAt) {
    throw new Error('Transaction already reversed');
  }
  
  if (!this.isReversible) {
    throw new Error('Transaction is not reversible');
  }
  
  this.reversedAt = new Date();
  this.reversedBy = reversedBy;
  this.reversalReason = reason;
  
  return this.save();
};

// Static method to get user transactions
transactionSchema.statics.getUserTransactions = function(userId, options = {}) {
  const { page = 1, limit = 20, type, source, status } = options;
  const skip = (page - 1) * limit;
  
  const query = { userId };
  if (type) query.type = type;
  if (source) query.source = source;
  if (status) query.status = status;
  
  return this.find(query)
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(limit)
    .populate('userId', 'name email')
    .populate('metadata.referredUserId', 'name email')
    .populate('metadata.adminId', 'name email');
};

// Static method to get transaction statistics
transactionSchema.statics.getTransactionStats = function(userId, period = 'all') {
  const dateFilter = {};
  
  if (period === 'today') {
    dateFilter.createdAt = { $gte: new Date().setHours(0, 0, 0, 0) };
  } else if (period === 'week') {
    dateFilter.createdAt = { $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) };
  } else if (period === 'month') {
    dateFilter.createdAt = { $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) };
  }
  
  const query = { userId, ...dateFilter };
  
  return this.aggregate([
    { $match: query },
    {
      $group: {
        _id: '$type',
        totalAmount: { $sum: '$amount' },
        count: { $sum: 1 }
      }
    }
  ]);
};

// Static method to get earnings by source
transactionSchema.statics.getEarningsBySource = function(userId, period = 'all') {
  const dateFilter = {};
  
  if (period === 'today') {
    dateFilter.createdAt = { $gte: new Date().setHours(0, 0, 0, 0) };
  } else if (period === 'week') {
    dateFilter.createdAt = { $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) };
  } else if (period === 'month') {
    dateFilter.createdAt = { $gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) };
  }
  
  const query = { userId, type: 'earn', ...dateFilter };
  
  return this.aggregate([
    { $match: query },
    {
      $group: {
        _id: '$source',
        totalEarned: { $sum: '$amount' },
        count: { $sum: 1 }
      }
    },
    { $sort: { totalEarned: -1 } }
  ]);
};

module.exports = mongoose.model('Transaction', transactionSchema); 