# Referral System Documentation

## 🎯 Overview

The referral system is a comprehensive feature that allows users to invite friends and earn rewards. It includes referral code generation, bonus calculations, relationship tracking, and analytics.

## ✨ Features

### 🔑 Referral Code Generation
- **Automatic Generation**: Unique 8-character codes generated automatically
- **Format**: Alphanumeric (A-Z, 0-9) for easy sharing
- **Uniqueness**: Guaranteed unique across all users
- **Validation**: Built-in format validation

### 💰 Reward System
- **Referrer Bonus**: 25 coins for each successful referral
- **Referred User Bonus**: 25 coins sign-up bonus
- **Tiered Rewards**: Higher bonuses for users with more referrals
- **Transaction Tracking**: Complete audit trail of all referral rewards

### 🔗 Referral Management
- **Relationship Tracking**: Who referred whom
- **Statistics**: Total referrals, earnings, and history
- **Prevention**: Self-referral and duplicate referral protection
- **Status Tracking**: Active vs. inactive referrals

### 📊 Analytics & Reporting
- **User Dashboard**: Personal referral statistics
- **Admin Analytics**: Overall referral performance
- **Trend Analysis**: Referral growth over time
- **Performance Metrics**: Conversion rates and effectiveness

## 🚀 API Endpoints

### 1. Add Referral
```http
POST /api/referrals/add
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "referralCode": "ABC12345"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "referrer": {
      "name": "John Smith",
      "referralCode": "ABC12345"
    },
    "rewards": {
      "referrer": 25,
      "referred": 25
    }
  },
  "message": "Referral added successfully"
}
```

### 2. Get Referral Statistics
```http
GET /api/referrals/stats
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "referralCode": "ABC12345",
    "referredBy": {
      "name": "Jane Doe",
      "email": "jane@example.com"
    },
    "referralCount": 3,
    "referralEarnings": 75,
    "totalReferralEarnings": 75,
    "referredUsers": [
      {
        "name": "Mike Davis",
        "email": "mike@example.com",
        "joinedAt": "2024-01-15T10:30:00Z"
      }
    ],
    "appData": {
      "totalReferrals": 3,
      "totalCoinsFromReferrals": 75,
      "referralHistory": []
    }
  },
  "message": "Referral statistics retrieved successfully"
}
```

### 3. Get Referral Link
```http
GET /api/referrals/link
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "referralCode": "ABC12345",
    "referralLink": "https://yourapp.com/register?ref=ABC12345",
    "shareText": "Join me on the 5-in-1 Earning System and earn coins together! Use my referral code: ABC12345 🎉💰"
  },
  "message": "Referral link generated successfully"
}
```

### 4. Get Referral History
```http
GET /api/referrals/history?page=1&limit=20
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "referrals": [
      {
        "type": "referral",
        "amount": 25,
        "source": "referral",
        "description": "Referral bonus for referring Mike Davis",
        "createdAt": "2024-01-15T10:30:00Z",
        "metadata": {
          "referredUserId": "user_id_here",
          "referralCode": "ABC12345"
        }
      }
    ],
    "total": 3,
    "page": 1,
    "limit": 20,
    "totalPages": 1
  },
  "message": "Referral history retrieved successfully"
}
```

### 5. Validate Referral Code
```http
POST /api/referrals/validate
Content-Type: application/json

{
  "referralCode": "ABC12345"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "valid": true,
    "referrer": {
      "name": "John Smith",
      "referralCode": "ABC12345"
    }
  },
  "message": "Referral code is valid"
}
```

## 🔧 Configuration

### Environment Variables
```env
# Referral System
REFERRAL_BONUS_AMOUNT=25
REFERRAL_BONUS_REFERRER=10
REFERRAL_CODE_LENGTH=8
```

### Reward Configuration
```javascript
const REFERRAL_REWARDS = {
  referrer: 25,    // Coins for referrer
  referred: 25     // Bonus coins for referred user
};
```

## 📊 Database Schema

### User Model Updates
```javascript
{
  referralCode: String,        // Unique referral code
  referredBy: ObjectId,        // Who referred this user
  referralCount: Number,       // How many users referred
  referralEarnings: Number     // Total earnings from referrals
}
```

### AppData Model - Referral Data
```javascript
{
  referralData: {
    totalReferrals: Number,
    totalCoinsFromReferrals: Number,
    referralHistory: [{
      referredUserId: ObjectId,
      bonusAmount: Number,
      timestamp: Date
    }]
  }
}
```

### Transaction Model - Referral Transactions
```javascript
{
  type: 'referral',
  source: 'referral',
  metadata: {
    referredUserId: ObjectId,
    referralCode: String
  }
}
```

## 🎮 Usage Examples

### Frontend Integration

#### 1. Registration with Referral Code
```javascript
// During user registration
const registerWithReferral = async (userData, referralCode) => {
  try {
    // First register the user
    const response = await fetch('/api/auth/register', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(userData)
    });
    
    const { data: { token } } = await response.json();
    
    // Then add referral if code provided
    if (referralCode) {
      await fetch('/api/referrals/add', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ referralCode })
      });
    }
    
    return { success: true, token };
  } catch (error) {
    console.error('Registration error:', error);
    return { success: false, error: error.message };
  }
};
```

#### 2. Display Referral Statistics
```javascript
const getReferralStats = async () => {
  try {
    const response = await fetch('/api/referrals/stats', {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    
    const { data } = await response.json();
    
    // Update UI with referral data
    updateReferralUI(data);
  } catch (error) {
    console.error('Error fetching referral stats:', error);
  }
};
```

#### 3. Share Referral Link
```javascript
const shareReferral = async () => {
  try {
    const response = await fetch('/api/referrals/link', {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    
    const { data } = await response.json();
    
    // Share on social media
    if (navigator.share) {
      await navigator.share({
        title: 'Join me on 5-in-1 Earning System!',
        text: data.shareText,
        url: data.referralLink
      });
    } else {
      // Fallback: copy to clipboard
      await navigator.clipboard.writeText(data.referralLink);
      showToast('Referral link copied to clipboard!');
    }
  } catch (error) {
    console.error('Error sharing referral:', error);
  }
};
```

## 🛡️ Security Features

### Validation Rules
- **Referral Code Format**: 6-10 alphanumeric characters
- **Self-Referral Prevention**: Users cannot refer themselves
- **Duplicate Prevention**: Users can only have one referrer
- **Authentication Required**: All referral operations require valid JWT

### Rate Limiting
- **API Protection**: All referral endpoints are rate-limited
- **Spam Prevention**: Prevents abuse of referral system
- **Fair Usage**: Ensures equal opportunity for all users

## 📈 Analytics & Insights

### User Metrics
- **Referral Conversion Rate**: How many referrals become active users
- **Referral Velocity**: How quickly users refer others
- **Referral Value**: Average coins earned per referral
- **Network Effect**: How referrals grow over time

### Business Metrics
- **User Acquisition Cost**: Cost per user through referrals
- **Referral ROI**: Return on investment from referral bonuses
- **Viral Coefficient**: How viral the referral system is
- **Retention Impact**: How referrals affect user retention

## 🚨 Error Handling

### Common Error Scenarios
```javascript
// Invalid referral code
{
  "success": false,
  "error": "Invalid referral code",
  "message": "The referral code you entered is not valid"
}

// User already has referrer
{
  "success": false,
  "error": "User already has a referrer",
  "message": "You have already been referred by another user"
}

// Self-referral attempt
{
  "success": false,
  "error": "Cannot refer yourself",
  "message": "You cannot use your own referral code"
}
```

## 🔄 Future Enhancements

### Planned Features
1. **Multi-level Referrals**: Referral chains with tiered rewards
2. **Referral Challenges**: Time-limited referral competitions
3. **Social Integration**: Direct sharing to social media platforms
4. **Referral Analytics Dashboard**: Advanced reporting and insights
5. **Automated Rewards**: Instant bonus distribution
6. **Referral Gamification**: Badges, levels, and achievements

### Customization Options
1. **Configurable Rewards**: Different bonus amounts for different user tiers
2. **Referral Limits**: Maximum referrals per user
3. **Time-based Bonuses**: Special rewards for seasonal campaigns
4. **Geographic Targeting**: Location-based referral bonuses

## 📚 Additional Resources

- **API Documentation**: See `API_DOCUMENTATION.md`
- **Database Schema**: See individual model files
- **Testing**: Use the provided Postman collection
- **Sample Data**: Run `npm run seed` to populate database
