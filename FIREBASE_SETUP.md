# Firebase Setup Guide for 5-in-1 Earning System

## 🚀 Step 1: Firebase Project Setup

### 1.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: `5in1-earning-system`
4. Enable Google Analytics (recommended)
5. Click "Create project"

### 1.2 Enable Required Services

#### Enable Blaze Plan (Required for Cloud Functions)
1. In Firebase Console, go to **Billing** (⚡ icon in sidebar)
2. Click "Upgrade" to Blaze plan
3. Add payment method (required for Cloud Functions)

#### Enable Authentication
1. Go to **Authentication** → **Sign-in method**
2. Enable **Email/Password**
3. Optionally enable **Google**

#### Enable Firestore Database
1. Go to **Firestore Database**
2. Click "Create database"
3. Choose **Production mode**
4. Select a location close to your users

#### Enable Cloud Functions
1. Go to **Functions** in the sidebar
2. Click "Get started"
3. Choose Node.js runtime

#### Enable Hosting (for Admin Panel)
1. Go to **Hosting**
2. Click "Get started"

## 🔧 Step 2: Register Applications

### 2.1 Register Flutter Apps

#### Wallet Hub App
1. In Firebase Console, go to **Project Settings**
2. Click "Add app" → **Android**
3. Android package name: `com.example.wallet_hub`
4. Download `google-services.json` to `wallet_hub/android/app/`

#### Spin & Earn App
1. Click "Add app" → **Android**
2. Android package name: `com.example.spin_and_earn`
3. Download `google-services.json` to `spin_and_earn/android/app/`

### 2.2 Register Web App (Admin Panel)
1. Click "Add app" → **Web**
2. App nickname: "Admin Panel"
3. Copy the Firebase config object

## 📱 Step 3: Configure Apps

### 3.1 Flutter Apps
1. Navigate to each Flutter app directory
2. Run: `flutterfire configure`
3. Select your Firebase project

### 3.2 React Admin Panel
1. Update `admin_panel/src/firebase.ts` with your config
2. Replace placeholder values with actual Firebase config

## 🗄️ Step 4: Firestore Setup

### 4.1 Create Collections
- `users/` - User profiles and balances
- `transactions/` - All system transactions
- `withdrawals/` - Withdrawal requests

### 4.2 Create Admin User
Create a document in `users/{yourUid}`:
```json
{
  "name": "Your Name",
  "email": "your-email@example.com",
  "balance": 0,
  "roles": {
    "admin": true
  },
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

## 🔒 Step 5: Security Rules

Deploy the security rules from `firebase.rules` in Firebase Console.

## ⚡ Step 6: Cloud Functions

1. Navigate to `functions/`
2. Run: `npm install`
3. Deploy: `firebase deploy --only functions`

## 🚀 Step 7: Deploy Admin Panel

1. Navigate to `admin_panel/`
2. Run: `npm run build`
3. Deploy: `firebase deploy --only hosting`

## 🎯 Testing

1. Test authentication in Wallet Hub
2. Test admin panel login
3. Test Cloud Functions with Spin & Earn
4. Verify data syncs between apps

Your Firebase setup is now complete! 🎉 