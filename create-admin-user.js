const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
const serviceAccount = require('./serviceAccountKey.json'); // You'll need to download this from Firebase Console

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://fiveinone-earning-system-default-rtdb.firebaseio.com"
});

async function createAdminUser(email, password, displayName = 'System Administrator') {
  try {
    // Create user in Authentication
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      displayName: displayName,
      emailVerified: true
    });

    console.log('✅ User created successfully:', userRecord.uid);

    // Create user document in Firestore
    const userDoc = {
      profile: {
        name: displayName,
        email: email
      },
      balance: {
        coins: 0
      },
      roles: {
        admin: true
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    };

    await admin.firestore().collection('users').doc(userRecord.uid).set(userDoc);
    console.log('✅ Admin role assigned successfully');

    console.log('\n🎉 Admin user created successfully!');
    console.log('📧 Email:', email);
    console.log('🆔 UID:', userRecord.uid);
    console.log('🔑 Password:', password);
    console.log('🌐 Login at: https://fiveinone-earning-system.web.app');

  } catch (error) {
    console.error('❌ Error creating admin user:', error.message);
  }
}

// Example usage
const email = process.argv[2] || 'admin@fiveinone.com';
const password = process.argv[3] || 'Admin123!';
const displayName = process.argv[4] || 'System Administrator';

console.log('🚀 Creating admin user...');
console.log('📧 Email:', email);
console.log('👤 Display Name:', displayName);

createAdminUser(email, password, displayName); 