const mongoose = require('mongoose');
require('dotenv').config();

console.log('🔍 Testing MongoDB connection...');
console.log('📋 Environment:', process.env.NODE_ENV);
console.log('🔗 MongoDB URI:', process.env.MONGO_URI ? 'Set' : 'Not set');

const testConnection = async () => {
  try {
    console.log('🔄 Attempting to connect to MongoDB...');
    
    const conn = await mongoose.connect(process.env.MONGO_URI, {
      serverSelectionTimeoutMS: 30000, // 30 seconds timeout
      socketTimeoutMS: 45000, // 45 seconds timeout
    });
    
    console.log(`✅ MongoDB Connected: ${conn.connection.host}`);
    console.log(`📊 Database: ${conn.connection.name}`);
    console.log(`🔌 Port: ${conn.connection.port}`);
    
    // Test a simple operation
    const collections = await conn.connection.db.listCollections().toArray();
    console.log(`📚 Collections found: ${collections.length}`);
    
    if (collections.length > 0) {
      console.log('📋 Collections:', collections.map(c => c.name).join(', '));
    }
    
    await mongoose.disconnect();
    console.log('🔌 Disconnected from MongoDB');
    
  } catch (error) {
    console.error('❌ MongoDB connection error:', error.message);
    console.error('🔍 Error details:', error);
    
    if (error.name === 'MongoServerSelectionError') {
      console.log('💡 This usually means:');
      console.log('   - Network connectivity issues');
      console.log('   - MongoDB Atlas cluster is down');
      console.log('   - IP address not whitelisted');
      console.log('   - Incorrect connection string');
    }
  }
};

testConnection(); 