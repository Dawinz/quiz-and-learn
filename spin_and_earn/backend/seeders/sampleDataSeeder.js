const mongoose = require('mongoose');
const User = require('../models/User');
const Wallet = require('../models/Wallet');
const UserProgress = require('../models/UserProgress');
const AppData = require('../models/AppData');
const Transaction = require('../models/Transaction');
require('dotenv').config();

// Sample user data
const sampleUsers = [
  {
    name: 'John Smith',
    email: 'john.smith@example.com',
    password: 'password123',
    phone: '+1234567890',
    totalCoins: 1500,
    roles: ['user'],
    isActive: true
  },
  {
    name: 'Sarah Johnson',
    email: 'sarah.johnson@example.com',
    password: 'password123',
    phone: '+1234567891',
    totalCoins: 2300,
    roles: ['user'],
    isActive: true
  },
  {
    name: 'Mike Davis',
    email: 'mike.davis@example.com',
    password: 'password123',
    phone: '+1234567892',
    totalCoins: 800,
    roles: ['user'],
    isActive: true
  },
  {
    name: 'Emily Wilson',
    email: 'emily.wilson@example.com',
    password: 'password123',
    phone: '+1234567893',
    totalCoins: 3200,
    roles: ['user'],
    isActive: true
  },
  {
    name: 'David Brown',
    email: 'david.brown@example.com',
    password: 'password123',
    phone: '+1234567894',
    totalCoins: 950,
    roles: ['user'],
    isActive: true
  },
  {
    name: 'Lisa Garcia',
    email: 'lisa.garcia@example.com',
    password: 'password123',
    phone: '+1234567895',
    totalCoins: 1800,
    roles: ['user'],
    isActive: true
  },
  {
    name: 'Admin User',
    email: 'admin@spinandearn.com',
    password: 'admin123',
    phone: '+1234567899',
    totalCoins: 5000,
    roles: ['admin'],
    isActive: true
  }
];

// Sample referral relationships
const referralRelationships = [
  { referrer: 'john.smith@example.com', referred: 'sarah.johnson@example.com' },
  { referrer: 'john.smith@example.com', referred: 'mike.davis@example.com' },
  { referrer: 'sarah.johnson@example.com', referred: 'emily.wilson@example.com' },
  { referrer: 'emily.wilson@example.com', referred: 'david.brown@example.com' },
  { referrer: 'david.brown@example.com', referred: 'lisa.garcia@example.com' }
];

// Sample spin data
const sampleSpinData = [
  { result: '50 coins', coins: 50, timestamp: new Date(Date.now() - 24 * 60 * 60 * 1000) },
  { result: '25 coins', coins: 25, timestamp: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000) },
  { result: '100 coins', coins: 100, timestamp: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000) },
  { result: '10 coins', coins: 10, timestamp: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000) },
  { result: '200 coins', coins: 200, timestamp: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000) }
];

// Sample achievements
const sampleAchievements = [
  { id: 'first_spin', name: 'First Spin', description: 'Complete your first spin', icon: '🎰' },
  { id: 'daily_player', name: 'Daily Player', description: 'Spin for 7 consecutive days', icon: '📅' },
  { id: 'lucky_winner', name: 'Lucky Winner', description: 'Win 200+ coins in a single spin', icon: '🍀' },
  { id: 'referral_master', name: 'Referral Master', description: 'Refer 5 users', icon: '👥' },
  { id: 'coin_collector', name: 'Coin Collector', description: 'Earn 1000+ total coins', icon: '💰' }
];

/**
 * Seed sample users
 */
const seedUsers = async () => {
  console.log('🌱 Seeding users...');
  
  const createdUsers = [];
  
  for (const userData of sampleUsers) {
    try {
      // Check if user already exists
      let user = await User.findByEmail(userData.email);
      
      if (!user) {
        user = await User.create(userData);
        console.log(`✅ Created user: ${user.name} (${user.email})`);
      } else {
        console.log(`ℹ️  User already exists: ${user.name} (${user.email})`);
      }
      
      createdUsers.push(user);
    } catch (error) {
      console.error(`❌ Error creating user ${userData.email}:`, error.message);
    }
  }
  
  return createdUsers;
};

/**
 * Seed wallets for users
 */
const seedWallets = async (users) => {
  console.log('💰 Seeding wallets...');
  
  for (const user of users) {
    try {
      let wallet = await Wallet.findByUserId(user._id);
      
      if (!wallet) {
        wallet = await Wallet.create({
          userId: user._id,
          balance: user.totalCoins,
          totalEarned: user.totalCoins + 500, // Add some earned amount
          totalSpent: 0
        });
        console.log(`✅ Created wallet for ${user.name}`);
      } else {
        console.log(`ℹ️  Wallet already exists for ${user.name}`);
      }
    } catch (error) {
      console.error(`❌ Error creating wallet for ${user.name}:`, error.message);
    }
  }
};

/**
 * Seed referral relationships
 */
const seedReferrals = async (users) => {
  console.log('🔗 Seeding referral relationships...');
  
  const userMap = {};
  users.forEach(user => {
    userMap[user.email] = user;
  });
  
  for (const relationship of referralRelationships) {
    try {
      const referrer = userMap[relationship.referrer];
      const referred = userMap[relationship.referred];
      
      if (referrer && referred) {
        // Update referred user
        await User.findByIdAndUpdate(referred._id, {
          referredBy: referrer._id
        });
        
        // Update referrer stats
        await User.findByIdAndUpdate(referrer._id, {
          $inc: { referralCount: 1, referralEarnings: 25 }
        });
        
        // Add referral bonus to referrer wallet
        const referrerWallet = await Wallet.findByUserId(referrer._id);
        if (referrerWallet) {
          await referrerWallet.addCoins(25);
          
          // Create referral transaction
          await Transaction.create({
            userId: referrer._id,
            type: 'referral',
            amount: 25,
            source: 'referral',
            description: `Referral bonus for referring ${referred.name}`,
            balanceBefore: referrerWallet.balance - 25,
            balanceAfter: referrerWallet.balance,
            metadata: {
              referredUserId: referred._id,
              referralCode: referrer.referralCode
            }
          });
        }
        
        console.log(`✅ Created referral: ${referrer.name} → ${referred.name}`);
      }
    } catch (error) {
      console.error(`❌ Error creating referral:`, error.message);
    }
  }
};

/**
 * Seed user progress data
 */
const seedUserProgress = async (users) => {
  console.log('📊 Seeding user progress...');
  
  for (const user of users) {
    try {
      // Create spin progress
      let spinProgress = await UserProgress.getUserProgress(user._id, 'spin');
      if (!spinProgress) {
        spinProgress = await UserProgress.create({
          userId: user._id,
          app: 'spin',
          spinProgress: {
            totalSpins: Math.floor(Math.random() * 20) + 5,
            dailySpins: Math.floor(Math.random() * 3) + 1,
            lastSpinDate: new Date(),
            streak: Math.floor(Math.random() * 10) + 1,
            totalEarnings: Math.floor(Math.random() * 500) + 100
          },
          achievements: sampleAchievements.slice(0, Math.floor(Math.random() * 3) + 1),
          lastActivity: new Date()
        });
        console.log(`✅ Created spin progress for ${user.name}`);
      }
      
      // Create task progress
      let taskProgress = await UserProgress.getUserProgress(user._id, 'task');
      if (!taskProgress) {
        taskProgress = await UserProgress.create({
          userId: user._id,
          app: 'task',
          taskProgress: {
            completedTasks: [],
            dailyCompletions: Math.floor(Math.random() * 5),
            lastResetDate: new Date(),
            streak: Math.floor(Math.random() * 7) + 1,
            totalEarnings: Math.floor(Math.random() * 300) + 50
          },
          lastActivity: new Date()
        });
        console.log(`✅ Created task progress for ${user.name}`);
      }
      
    } catch (error) {
      console.error(`❌ Error creating progress for ${user.name}:`, error.message);
    }
  }
};

/**
 * Seed app data
 */
const seedAppData = async (users) => {
  console.log('📱 Seeding app data...');
  
  for (const user of users) {
    try {
      // Create spin app data
      let spinAppData = await AppData.findByUserAndApp(user._id, 'spin_and_earn');
      if (!spinAppData) {
        spinAppData = await AppData.create({
          userId: user._id,
          appName: 'spinand_earn',
          spinData: {
            dailySpinsUsed: Math.floor(Math.random() * 3),
            dailySpinsLimit: 3,
            totalSpins: Math.floor(Math.random() * 20) + 5,
            totalCoinsFromSpins: Math.floor(Math.random() * 500) + 100,
            lastSpinDate: new Date(),
            spinHistory: sampleSpinData.slice(0, Math.floor(Math.random() * 3) + 1),
            achievements: sampleAchievements.slice(0, Math.floor(Math.random() * 3) + 1)
          }
        });
        console.log(`✅ Created spin app data for ${user.name}`);
      }
      
      // Create referral app data
      let referralAppData = await AppData.findByUserAndApp(user._id, 'refer_earn');
      if (!referralAppData) {
        referralAppData = await AppData.create({
          userId: user._id,
          appName: 'refer_earn',
          referralData: {
            totalReferrals: user.referralCount || 0,
            totalCoinsFromReferrals: (user.referralCount || 0) * 25,
            referralHistory: []
          }
        });
        console.log(`✅ Created referral app data for ${user.name}`);
      }
      
    } catch (error) {
      console.error(`❌ Error creating app data for ${user.name}:`, error.message);
    }
  }
};

/**
 * Main seeding function
 */
const seedDatabase = async () => {
  try {
    console.log('🚀 Starting database seeding...');
    
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ Connected to MongoDB');
    
    // Clear existing data (optional - comment out if you want to keep existing data)
    // await clearDatabase();
    
    // Seed data
    const users = await seedUsers();
    await seedWallets(users);
    await seedReferrals(users);
    await seedUserProgress(users);
    await seedAppData(users);
    
    console.log('🎉 Database seeding completed successfully!');
    console.log(`📊 Created ${users.length} users with sample data`);
    
  } catch (error) {
    console.error('❌ Error seeding database:', error);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Disconnected from MongoDB');
  }
};

/**
 * Clear all data (use with caution)
 */
const clearDatabase = async () => {
  console.log('🗑️  Clearing existing data...');
  
  await User.deleteMany({});
  await Wallet.deleteMany({});
  await UserProgress.deleteMany({});
  await AppData.deleteMany({});
  await Transaction.deleteMany({});
  
  console.log('✅ Database cleared');
};

// Run seeder if called directly
if (require.main === module) {
  seedDatabase();
}

module.exports = {
  seedDatabase,
  clearDatabase
};
