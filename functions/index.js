const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin
admin.initializeApp();

const db = admin.firestore();

/**
 * Update user balance after a valid spin
 * This function is called from Spin & Earn app
 */
exports.updateBalanceAfterSpin = functions.https.onCall(async (data, context) => {
  // Check if user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { userId, amount, source } = data;

  // Validate input parameters
  if (!userId || !amount || !source) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required parameters');
  }

  // Validate that the authenticated user is updating their own balance
  if (context.auth.uid !== userId) {
    throw new functions.https.HttpsError('permission-denied', 'Can only update own balance');
  }

  // Validate amount
  if (typeof amount !== 'number' || amount <= 0 || amount > 1000) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid amount');
  }

  // Validate source
  if (!['Spin & Earn', 'Wallet Hub', 'Admin'].includes(source)) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid source');
  }

  try {
    const userRef = db.collection('users').doc(userId);
    
    // Use transaction to ensure data consistency
    const result = await db.runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef);
      
      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'User not found');
      }

      const userData = userDoc.data();
      const currentBalance = userData.balance?.coins || 0;
      const newBalance = currentBalance + amount;

      // Update user balance
      transaction.update(userRef, {
        'balance.coins': newBalance
      });

      // Create transaction record
      const transactionRef = db.collection('transactions').doc();
      transaction.set(transactionRef, {
        userId: userId,
        type: 'earning',
        amount: amount,
        source: source,
        date: admin.firestore.FieldValue.serverTimestamp(),
        description: `Earned ${amount} coins from ${source}`
      });

      return { success: true, newBalance, transactionId: transactionRef.id };
    });

    return result;
  } catch (error) {
    console.error('Error updating balance after spin:', error);
    throw new functions.https.HttpsError('internal', 'Failed to update balance');
  }
});

/**
 * Handle rewarded ad spin (extra spin from watching ad)
 * This function is called when user watches a rewarded ad
 */
exports.handleRewardedAdSpin = functions.https.onCall(async (data, context) => {
  // Check if user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { userId } = data;

  // Validate input parameters
  if (!userId) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required parameters');
  }

  // Validate that the authenticated user is updating their own data
  if (context.auth.uid !== userId) {
    throw new functions.https.HttpsError('permission-denied', 'Can only update own data');
  }

  try {
    const userRef = db.collection('users').doc(userId);
    
    // Use transaction to ensure data consistency
    const result = await db.runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef);
      
      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'User not found');
      }

      const userData = userDoc.data();
      const currentDailyUsed = userData.spins?.dailyUsed || 0;
      const dailyLimit = userData.spins?.dailyLimit || 5;

      // Check if user can get an extra spin (they should have used all their spins)
      if (currentDailyUsed < dailyLimit) {
        throw new functions.https.HttpsError('failed-precondition', 'User still has free spins available');
      }

      // Give extra spin by reducing daily used count
      const newDailyUsed = currentDailyUsed - 1;

      // Update user spin data
      transaction.update(userRef, {
        'spins.dailyUsed': newDailyUsed,
        'spins.lastSpinDate': admin.firestore.FieldValue.serverTimestamp()
      });

      // Create transaction record for the extra spin
      const transactionRef = db.collection('transactions').doc();
      transaction.set(transactionRef, {
        userId: userId,
        type: 'earning',
        amount: 0, // No coins earned, just extra spin
        source: 'Rewarded Ad',
        date: admin.firestore.FieldValue.serverTimestamp(),
        description: 'Earned extra spin from watching rewarded ad'
      });

      return { 
        success: true, 
        newDailyUsed, 
        extraSpinGranted: true,
        transactionId: transactionRef.id 
      };
    });

    return result;
  } catch (error) {
    console.error('Error handling rewarded ad spin:', error);
    throw new functions.https.HttpsError('internal', 'Failed to process rewarded ad spin');
  }
});

/**
 * Create a new withdrawal request
 * This function is called from Wallet Hub app
 */
exports.createWithdrawalRequest = functions.https.onCall(async (data, context) => {
  // Check if user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { userId, method, account, amount } = data;

  // Validate input parameters
  if (!userId || !method || !account || !amount) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required parameters');
  }

  // Validate that the authenticated user is creating their own withdrawal
  if (context.auth.uid !== userId) {
    throw new functions.https.HttpsError('permission-denied', 'Can only create own withdrawal');
  }

  // Validate withdrawal method
  const validMethods = ['mpesa', 'tigopesa', 'airtel', 'halopesa', 'usdt'];
  if (!validMethods.includes(method)) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid withdrawal method');
  }

  // Validate amount
  if (typeof amount !== 'number' || amount <= 0 || amount > 10000) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid amount (must be 1-10000)');
  }

  // Validate account details
  if (typeof account !== 'string' || account.trim().length === 0) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid account details');
  }

  try {
    const userRef = db.collection('users').doc(userId);
    
    // Use transaction to check balance and create withdrawal
    const result = await db.runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef);
      
      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'User not found');
      }

      const userData = userDoc.data();
      const currentBalance = userData.balance?.coins || 0;

      // Check if user has sufficient balance
      if (currentBalance < amount) {
        throw new functions.https.HttpsError('failed-precondition', 'Insufficient balance');
      }

      // Deduct amount from balance
      const newBalance = currentBalance - amount;
      transaction.update(userRef, {
        'balance.coins': newBalance
      });

      // Create withdrawal request
      const withdrawalRef = db.collection('withdrawals').doc();
      transaction.set(withdrawalRef, {
        userId: userId,
        method: method,
        account: account.trim(),
        amount: amount,
        status: 'pending',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        processedAt: null,
        notes: null
      });

      // Create transaction record for the withdrawal
      const transactionRef = db.collection('transactions').doc();
      transaction.set(transactionRef, {
        userId: userId,
        type: 'withdrawal',
        amount: -amount, // Negative amount for withdrawal
        source: 'Wallet Hub',
        date: admin.firestore.FieldValue.serverTimestamp(),
        description: `Withdrawal request via ${method}`
      });

      return { 
        success: true, 
        withdrawalId: withdrawalRef.id,
        newBalance,
        transactionId: transactionRef.id
      };
    });

    return result;
  } catch (error) {
    console.error('Error creating withdrawal request:', error);
    throw new functions.https.HttpsError('internal', 'Failed to create withdrawal request');
  }
});

/**
 * Admin function to update withdrawal status
 * Only admins can call this function
 */
exports.adminUpdateWithdrawalStatus = functions.https.onCall(async (data, context) => {
  // Check if user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { withdrawalId, status, notes } = data;

  // Validate input parameters
  if (!withdrawalId || !status) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required parameters');
  }

  // Validate status
  const validStatuses = ['pending', 'completed', 'declined'];
  if (!validStatuses.includes(status)) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid status');
  }

  try {
    // Check if user is admin
    const adminUserRef = db.collection('users').doc(context.auth.uid);
    const adminUserDoc = await adminUserRef.get();
    
    if (!adminUserDoc.exists) {
      throw new functions.https.HttpsError('permission-denied', 'User not found');
    }

    const adminUserData = adminUserDoc.data();
    if (!adminUserData.roles?.admin) {
      throw new functions.https.HttpsError('permission-denied', 'Admin access required');
    }

    // Get withdrawal request
    const withdrawalRef = db.collection('withdrawals').doc(withdrawalId);
    const withdrawalDoc = await withdrawalRef.get();
    
    if (!withdrawalDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Withdrawal request not found');
    }

    const withdrawalData = withdrawalDoc.data();
    const currentStatus = withdrawalData.status;

    // Don't allow updating already processed withdrawals
    if (currentStatus !== 'pending') {
      throw new functions.https.HttpsError('failed-precondition', 'Withdrawal already processed');
    }

    // Update withdrawal status
    const updateData = {
      status: status,
      processedAt: admin.firestore.FieldValue.serverTimestamp(),
      notes: notes || null
    };

    await withdrawalRef.update(updateData);

    // If declined, refund the user
    if (status === 'declined') {
      const userRef = db.collection('users').doc(withdrawalData.userId);
      
      await db.runTransaction(async (transaction) => {
        const userDoc = await transaction.get(userRef);
        const userData = userDoc.data();
        const currentBalance = userData.balance?.coins || 0;
        const refundAmount = withdrawalData.amount;
        
        transaction.update(userRef, {
          'balance.coins': currentBalance + refundAmount
        });

        // Create refund transaction record
        const transactionRef = db.collection('transactions').doc();
        transaction.set(transactionRef, {
          userId: withdrawalData.userId,
          type: 'earning',
          amount: refundAmount,
          source: 'Admin Refund',
          date: admin.firestore.FieldValue.serverTimestamp(),
          description: `Refund for declined withdrawal (${withdrawalData.method})`
        });
      });
    }

    return { 
      success: true, 
      withdrawalId: withdrawalId,
      status: status,
      processedAt: new Date()
    };
  } catch (error) {
    console.error('Error updating withdrawal status:', error);
    throw new functions.https.HttpsError('internal', 'Failed to update withdrawal status');
  }
});

/**
 * Admin function to manually add/remove coins from user balance
 * Only admins can call this function
 */
exports.adminUpdateUserBalance = functions.https.onCall(async (data, context) => {
  // Check if user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { targetUserId, amount, reason } = data;

  // Validate input parameters
  if (!targetUserId || typeof amount !== 'number' || !reason) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing required parameters');
  }

  // Validate amount (can be negative for deductions)
  if (amount === 0 || amount < -10000 || amount > 10000) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid amount');
  }

  try {
    // Check if user is admin
    const adminUserRef = db.collection('users').doc(context.auth.uid);
    const adminUserDoc = await adminUserRef.get();
    
    if (!adminUserDoc.exists) {
      throw new functions.https.HttpsError('permission-denied', 'User not found');
    }

    const adminUserData = adminUserDoc.data();
    if (!adminUserData.roles?.admin) {
      throw new functions.https.HttpsError('permission-denied', 'Admin access required');
    }

    // Update target user's balance
    const userRef = db.collection('users').doc(targetUserId);
    
    const result = await db.runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef);
      
      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Target user not found');
      }

      const userData = userDoc.data();
      const currentBalance = userData.balance?.coins || 0;
      const newBalance = currentBalance + amount;

      // Prevent negative balance
      if (newBalance < 0) {
        throw new functions.https.HttpsError('failed-precondition', 'Insufficient balance for deduction');
      }

      transaction.update(userRef, {
        'balance.coins': newBalance
      });

      // Create transaction record
      const transactionRef = db.collection('transactions').doc();
      transaction.set(transactionRef, {
        userId: targetUserId,
        type: amount > 0 ? 'earning' : 'spending',
        amount: amount,
        source: 'Admin',
        date: admin.firestore.FieldValue.serverTimestamp(),
        description: reason
      });

      return { 
        success: true, 
        newBalance,
        transactionId: transactionRef.id
      };
    });

    return result;
  } catch (error) {
    console.error('Error updating user balance:', error);
    throw new functions.https.HttpsError('internal', 'Failed to update user balance');
  }
});

/**
 * Function to reset daily spin limits at midnight
 * Runs on a schedule (every day at 00:00)
 */
exports.resetDailySpins = functions.scheduler.onSchedule('0 0 * * *', async (event) => {
  try {
    const usersRef = db.collection('users');
    const snapshot = await usersRef.get();
    
    const batch = db.batch();
    let updateCount = 0;

    snapshot.forEach((doc) => {
      const userData = doc.data();
      if (userData.spins?.dailyUsed > 0) {
        batch.update(doc.ref, {
          'spins.dailyUsed': 0,
          'spins.lastSpinDate': admin.firestore.FieldValue.serverTimestamp()
        });
        updateCount++;
      }
    });

    await batch.commit();
    console.log(`Reset daily spins for ${updateCount} users`);
    
    return { success: true, updatedUsers: updateCount };
  } catch (error) {
    console.error('Error resetting daily spins:', error);
    throw error;
  }
});

/**
 * Function to get system statistics (admin only)
 */
exports.getSystemStats = functions.https.onCall(async (data, context) => {
  // Check if user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  try {
    // Check if user is admin
    const adminUserRef = db.collection('users').doc(context.auth.uid);
    const adminUserDoc = await adminUserRef.get();
    
    if (!adminUserDoc.exists) {
      throw new functions.https.HttpsError('permission-denied', 'User not found');
    }

    const adminUserData = adminUserDoc.data();
    if (!adminUserData.roles?.admin) {
      throw new functions.https.HttpsError('permission-denied', 'Admin access required');
    }

    // Get statistics
    const usersSnapshot = await db.collection('users').get();
    const transactionsSnapshot = await db.collection('transactions').get();
    const withdrawalsSnapshot = await db.collection('withdrawals').get();

    let totalBalance = 0;
    let totalEarnings = 0;
    let totalWithdrawals = 0;
    let pendingWithdrawals = 0;

    usersSnapshot.forEach((doc) => {
      const userData = doc.data();
      totalBalance += userData.balance?.coins || 0;
    });

    transactionsSnapshot.forEach((doc) => {
      const transactionData = doc.data();
      if (transactionData.type === 'earning') {
        totalEarnings += transactionData.amount;
      } else if (transactionData.type === 'withdrawal') {
        totalWithdrawals += Math.abs(transactionData.amount);
      }
    });

    withdrawalsSnapshot.forEach((doc) => {
      const withdrawalData = doc.data();
      if (withdrawalData.status === 'pending') {
        pendingWithdrawals++;
      }
    });

    return {
      success: true,
      stats: {
        totalUsers: usersSnapshot.size,
        totalBalance: totalBalance,
        totalEarnings: totalEarnings,
        totalWithdrawals: totalWithdrawals,
        pendingWithdrawals: pendingWithdrawals,
        totalTransactions: transactionsSnapshot.size
      }
    };
  } catch (error) {
    console.error('Error getting system stats:', error);
    throw new functions.https.HttpsError('internal', 'Failed to get system statistics');
  }
}); 