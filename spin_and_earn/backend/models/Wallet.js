const mongoose = require('mongoose');

const withdrawalSchema = new mongoose.Schema({
  amount: {
    type: Number,
    required: [true, 'Withdrawal amount is required'],
    min: [1, 'Withdrawal amount must be at least 1 coin']
  },
  status: {
    type: String,
    enum: ['pending', 'approved', 'rejected', 'completed'],
    default: 'pending'
  },
  method: {
    type: String,
    enum: ['paypal', 'bank_transfer', 'crypto', 'gift_card'],
    required: [true, 'Withdrawal method is required']
  },
  accountDetails: {
    type: String,
    required: [true, 'Account details are required']
  },
  processedAt: {
    type: Date,
    default: null
  },
  processedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null
  },
  notes: {
    type: String,
    maxlength: [500, 'Notes cannot exceed 500 characters']
  }
}, {
  timestamps: true
});

const walletSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User ID is required'],
    unique: true
  },
  balance: {
    type: Number,
    default: 0,
    min: [0, 'Balance cannot be negative']
  },
  totalEarned: {
    type: Number,
    default: 0,
    min: [0, 'Total earned cannot be negative']
  },
  totalSpent: {
    type: Number,
    default: 0,
    min: [0, 'Total spent cannot be negative']
  },
  totalWithdrawn: {
    type: Number,
    default: 0,
    min: [0, 'Total withdrawn cannot be negative']
  },
  goals: {
    weeklyTarget: {
      type: Number,
      default: 0,
      min: [0, 'Weekly target cannot be negative']
    },
    monthlyTarget: {
      type: Number,
      default: 0,
      min: [0, 'Monthly target cannot be negative']
    },
    progress: {
      type: Number,
      default: 0,
      min: [0, 'Progress cannot be negative']
    }
  },
  withdrawals: [withdrawalSchema],
  isActive: {
    type: Boolean,
    default: true
  },
  lastUpdated: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for available balance (balance - pending withdrawals)
walletSchema.virtual('availableBalance').get(function() {
  const pendingWithdrawals = this.withdrawals
    .filter(w => w.status === 'pending')
    .reduce((sum, w) => sum + w.amount, 0);
  return Math.max(0, this.balance - pendingWithdrawals);
});

// Virtual for pending withdrawals count
walletSchema.virtual('pendingWithdrawalsCount').get(function() {
  return this.withdrawals.filter(w => w.status === 'pending').length;
});

// Virtual for total pending amount
walletSchema.virtual('pendingAmount').get(function() {
  return this.withdrawals
    .filter(w => w.status === 'pending')
    .reduce((sum, w) => sum + w.amount, 0);
});

// Index for better query performance
// Note: Indexes are already defined in the schema fields

// Pre-save middleware to update lastUpdated
walletSchema.pre('save', function(next) {
  this.lastUpdated = new Date();
  next();
});

// Instance method to add coins
walletSchema.methods.addCoins = function(amount) {
  if (amount <= 0) throw new Error('Amount must be positive');
  this.balance += amount;
  this.totalEarned += amount;
  return this.save();
};

// Instance method to spend coins
walletSchema.methods.spendCoins = function(amount) {
  if (amount <= 0) throw new Error('Amount must be positive');
  if (this.balance < amount) throw new Error('Insufficient balance');
  this.balance -= amount;
  this.totalSpent += amount;
  return this.save();
};

// Instance method to request withdrawal
walletSchema.methods.requestWithdrawal = function(amount, method, accountDetails) {
  if (amount <= 0) throw new Error('Amount must be positive');
  if (this.balance < amount) throw new Error('Insufficient balance');
  
  const withdrawal = {
    amount,
    method,
    accountDetails,
    status: 'pending'
  };
  
  this.withdrawals.push(withdrawal);
  this.balance -= amount;
  this.totalWithdrawn += amount;
  
  return this.save();
};

// Instance method to update withdrawal status
walletSchema.methods.updateWithdrawalStatus = function(withdrawalId, status, processedBy = null, notes = '') {
  const withdrawal = this.withdrawals.id(withdrawalId);
  if (!withdrawal) throw new Error('Withdrawal not found');
  
  withdrawal.status = status;
  withdrawal.processedAt = new Date();
  withdrawal.processedBy = processedBy;
  if (notes) withdrawal.notes = notes;
  
  return this.save();
};

// Instance method to update goals
walletSchema.methods.updateGoals = function(weeklyTarget, monthlyTarget) {
  this.goals.weeklyTarget = weeklyTarget || this.goals.weeklyTarget;
  this.goals.monthlyTarget = monthlyTarget || this.goals.monthlyTarget;
  return this.save();
};

// Instance method to update progress
walletSchema.methods.updateProgress = function(progress) {
  this.goals.progress = Math.max(0, Math.min(100, progress));
  return this.save();
};

// Static method to find wallet by user ID
walletSchema.statics.findByUserId = function(userId) {
  return this.findOne({ userId }).populate('userId', 'name email');
};

// Static method to get wallet summary
walletSchema.statics.getWalletSummary = function(userId) {
  return this.findOne({ userId }).select('balance totalEarned totalSpent totalWithdrawn goals');
};

module.exports = mongoose.model('Wallet', walletSchema); 