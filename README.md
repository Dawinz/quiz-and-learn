# 5-in-1 Earning Ecosystem

A comprehensive Flutter-based earning ecosystem with multiple mini-apps, secure Firebase backend, and real-time balance synchronization.

## 🏗️ **System Overview**

This ecosystem consists of multiple Flutter apps that share a common Firebase backend, allowing users to earn coins through various activities and manage their earnings securely.

### Current Apps
- **Wallet Hub** - Main wallet app for balance management and withdrawals
- **Spin & Earn** - Spin wheel game for earning coins
- **Future Apps** - Additional earning apps (planned)

### Backend Services
- **Firebase Authentication** - User authentication and management
- **Cloud Firestore** - Real-time database with security rules
- **Cloud Functions** - Secure backend operations
- **Firebase Security Rules** - Data access control

## 📱 **Apps**

### 🏦 Wallet Hub
**Location**: `/wallet_hub`

A comprehensive wallet app that serves as the central hub for the earning ecosystem.

**Features**:
- User authentication (email/password, Google Sign-In)
- Real-time balance display
- Withdrawal requests (M-Pesa, Tigo Pesa, Airtel Money, HaloPesa, USDT)
- Transaction history
- Earning goals and progress tracking
- Settings and profile management

**Tech Stack**:
- Flutter 3.8+
- Firebase Authentication
- Cloud Firestore
- Provider state management
- Material Design UI

### 🎰 Spin & Earn
**Location**: `/spin_and_earn`

An engaging spin wheel game where users can earn coins daily.

**Features**:
- Animated spin wheel with colorful segments
- Daily spin limits (5 free spins per day)
- Random reward generation (5-100 coins)
- Real-time balance synchronization with Wallet Hub
- Transaction history tracking
- AdMob integration (configured)

**Tech Stack**:
- Flutter 3.8+
- Firebase Authentication
- Cloud Firestore
- Cloud Functions
- Provider state management
- Custom animations

### 🖥️ Admin Panel
**Location**: `/admin_panel`

A React-based web application for managing the entire earning ecosystem.

**Features**:
- Secure admin authentication with role-based access
- Real-time dashboard with system statistics
- Withdrawal request management (approve/decline)
- User management and balance monitoring
- Transaction history and analytics
- Module overview and detailed management

**Tech Stack**:
- React 18 with TypeScript
- Firebase Authentication & Firestore
- TailwindCSS for styling
- React Router for navigation
- Headless UI components

**Live Deployment**:
- **URL**: https://fiveinone-earning-system.web.app
- **Access**: Admin users only (requires `roles.admin: true`)
- **Security**: Role-based access control with automatic redirects

## 🔒 **Security Architecture**

### Firebase Security Rules
**File**: `firebase.rules`

Comprehensive security rules that ensure:
- Users can only access their own data
- Balance modifications only through Cloud Functions
- Admin-only access for sensitive operations
- Withdrawal request validation
- Transaction integrity

### Cloud Functions
**Location**: `/functions`

Secure backend operations including:
- `updateBalanceAfterSpin` - Secure balance updates after spins
- `createWithdrawalRequest` - Withdrawal creation with balance validation
- `adminUpdateWithdrawalStatus` - Admin withdrawal status management
- `adminUpdateUserBalance` - Admin manual balance adjustments
- `resetDailySpins` - Scheduled daily spin limit reset
- `getSystemStats` - Admin system statistics

## 🚀 **Quick Start**

### Prerequisites
- Flutter SDK 3.8+
- Node.js 18+
- Firebase CLI
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd 5in1_earning_system
   ```

2. **Set up Firebase** (Required for all apps)
   - Follow the detailed guide in `FIREBASE_SETUP.md`
   - Enable Blaze plan for Cloud Functions
   - Configure Authentication, Firestore, and Hosting
   - Register all apps (Wallet Hub, Spin & Earn, Admin Panel)

3. **Configure each app**
   - **Wallet Hub**: Run `flutterfire configure` in `wallet_hub/`
   - **Spin & Earn**: Run `flutterfire configure` in `spin_and_earn/`
   - **Admin Panel**: Update `admin_panel/src/firebase.ts` with your config

4. **Deploy the system**
   ```bash
   ./deploy.sh
   ```

5. **Test the system**
   - Test authentication in Wallet Hub
   - Test admin panel login
   - Test Cloud Functions with Spin & Earn

2. **Set up Firebase**
   ```bash
   firebase login
   firebase init
   ```

3. **Deploy security rules**
   ```bash
   firebase deploy --only firestore:rules
   ```

4. **Deploy Cloud Functions**
   ```bash
   cd functions
   npm install
   firebase deploy --only functions
   ```

5. **Configure apps**
   - Copy Firebase config files to each app
   - Update Firebase service configurations
   - Build and test apps

### Detailed Setup

See [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) for comprehensive setup instructions.

## 📊 **Database Schema**

### Users Collection
```javascript
users/{userId}
├── profile: {
│   ├── name: string
│   ├── email: string
│   └── phone: string (optional)
├── balance: {
│   └── coins: number
├── goals: {
│   ├── weeklyTarget: number
│   ├── monthlyTarget: number
│   └── progress: number
├── spins: {
│   ├── dailyUsed: number
│   ├── dailyLimit: number
│   └── lastSpinDate: timestamp
└── roles: {
    └── admin: boolean (optional)
}
```

### Transactions Collection
```javascript
transactions/{transactionId}
├── userId: string
├── type: "earning" | "spending" | "withdrawal"
├── amount: number
├── source: string
├── date: timestamp
└── description: string
```

### Withdrawals Collection
```javascript
withdrawals/{withdrawalId}
├── userId: string
├── method: "mpesa" | "tigopesa" | "airtel" | "halopesa" | "usdt"
├── account: string
├── amount: number
├── status: "pending" | "completed" | "declined"
├── createdAt: timestamp
├── processedAt: timestamp (optional)
└── notes: string (optional)
```

## 🔐 **Security Features**

### Data Protection
- **Role-based access control** - Admin and user roles
- **Input validation** - All parameters validated
- **Transaction safety** - Database operations use transactions
- **Balance protection** - Users cannot directly modify balances
- **Withdrawal limits** - Maximum withdrawal amount enforced

### Authentication
- Email/password authentication
- Google Sign-In integration
- Secure token management
- Session persistence

### Admin Controls
- Admin role assignment
- Manual balance adjustments
- Withdrawal status management
- System statistics access

## 📈 **Performance & Scalability**

### Optimization Features
- **Offline persistence** - Works without internet
- **Real-time synchronization** - Instant balance updates
- **Efficient queries** - Optimized Firestore queries
- **Caching** - Local data caching
- **Pagination** - Large list handling

### Monitoring
- Firebase Console monitoring
- Function execution tracking
- Error rate monitoring
- Cost optimization

## 🚀 **Deployment**

### Quick Deployment
```bash
# Deploy everything (backend + admin panel)
./deploy.sh

# Deploy only admin panel
./deploy-admin.sh
```

### Admin Panel Deployment
The admin panel is automatically deployed to Firebase Hosting:
- **Live URL**: https://fiveinone-earning-system.web.app
- **Build Directory**: `admin_panel/build`
- **Firebase Project**: fiveinone-earning-system

### Manual Deployment Steps
1. **Build Admin Panel**:
   ```bash
   cd admin_panel
   npm install --legacy-peer-deps
   npm run build
   ```

2. **Deploy to Firebase**:
   ```bash
   cd ..
   firebase deploy --only hosting
   ```

### Custom Domain Setup
To add a custom domain (e.g., `admin.yourdomain.com`):
1. Go to [Firebase Console](https://console.firebase.google.com/project/fiveinone-earning-system/hosting)
2. Click "Add custom domain"
3. Follow DNS configuration instructions
4. Wait for SSL certificate (up to 24 hours)

## 🛠️ **Development**

### Project Structure
```
5in1_earning_system/
├── wallet_hub/           # Main wallet app
├── spin_and_earn/        # Spin wheel game
├── functions/            # Cloud Functions
├── firebase.rules        # Security rules
├── DEPLOYMENT_GUIDE.md   # Deployment instructions
└── README.md            # This file
```

### Adding New Apps
1. Create new Flutter app in project root
2. Copy Firebase configuration
3. Implement shared authentication
4. Add to deployment guide
5. Update security rules if needed

### Testing
```bash
# Test Wallet Hub
cd wallet_hub
flutter test

# Test Spin & Earn
cd spin_and_earn
flutter test

# Test Cloud Functions
cd functions
npm test
```

## 📞 **Support & Documentation**

### Documentation
- [Wallet Hub README](./wallet_hub/README.md)
- [Spin & Earn README](./spin_and_earn/README.md)
- [Cloud Functions README](./functions/README.md)
- [Deployment Guide](./DEPLOYMENT_GUIDE.md)

### Resources
- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Documentation](https://flutter.dev/docs)
- [Cloud Functions Guide](https://firebase.google.com/docs/functions)

## 🤝 **Contributing**

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 **License**

This project is licensed under the MIT License - see the LICENSE file for details.

## 🚀 **Roadmap**

### Planned Features
- [ ] Additional earning apps
- [ ] Push notifications
- [ ] Advanced analytics
- [ ] Multi-language support
- [ ] Advanced admin dashboard
- [ ] Payment gateway integration
- [ ] Social features
- [ ] Gamification elements

### Future Apps
- **Survey & Earn** - Complete surveys for coins
- **Watch & Earn** - Watch videos for rewards
- **Refer & Earn** - Invite friends for bonuses
- **Quiz & Earn** - Answer questions for coins

## 📊 **Statistics**

- **Apps**: 3 (Wallet Hub, Spin & Earn, Admin Panel)
- **Cloud Functions**: 6
- **Security Rules**: Comprehensive
- **Database Collections**: 3 (users, transactions, withdrawals)
- **Authentication Methods**: 2 (email/password, Google)
- **Web Apps**: 1 (React Admin Panel)

## 🎉 **Getting Started**

1. **Read the deployment guide**: [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)
2. **Set up Firebase project**: Follow the setup instructions
3. **Deploy backend**: Deploy security rules and Cloud Functions
4. **Configure apps**: Set up Wallet Hub and Spin & Earn
5. **Test everything**: Verify all functionality works
6. **Go live**: Deploy to production

---

**Built with ❤️ using Flutter and Firebase** 