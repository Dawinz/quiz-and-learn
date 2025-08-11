# Cloud Functions for 5-in-1 Earning Ecosystem

This directory contains Firebase Cloud Functions that provide secure backend operations for the 5-in-1 earning ecosystem (Wallet Hub and Spin & Earn apps).

## Functions Overview

### 🔐 **Authentication & Security Functions**

1. **`updateBalanceAfterSpin`** - Secure balance updates after spins
2. **`createWithdrawalRequest`** - Create withdrawal requests with balance validation
3. **`adminUpdateWithdrawalStatus`** - Admin-only withdrawal status updates
4. **`adminUpdateUserBalance`** - Admin manual balance adjustments
5. **`getSystemStats`** - Admin system statistics

### ⏰ **Scheduled Functions**

6. **`resetDailySpins`** - Daily spin limit reset (runs at midnight UTC)

## Security Features

- **Role-based access control** - Admin functions require admin role
- **Input validation** - All parameters are validated
- **Transaction safety** - Database operations use transactions
- **Balance protection** - Users cannot directly modify balances
- **Withdrawal limits** - Maximum withdrawal amount enforced
- **Refund handling** - Automatic refunds for declined withdrawals

## Setup Instructions

### Prerequisites

1. **Firebase CLI**: Install Firebase CLI globally
   ```bash
   npm install -g firebase-tools
   ```

2. **Node.js**: Ensure you have Node.js 18+ installed

3. **Firebase Project**: Make sure you have a Firebase project set up

### Installation

1. **Navigate to functions directory**
   ```bash
   cd functions
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Login to Firebase**
   ```bash
   firebase login
   ```

4. **Initialize Firebase Functions** (if not already done)
   ```bash
   firebase init functions
   ```

### Deployment

1. **Deploy all functions**
   ```bash
   firebase deploy --only functions
   ```

2. **Deploy specific function**
   ```bash
   firebase deploy --only functions:functionName
   ```

3. **Deploy with environment variables**
   ```bash
   firebase functions:config:set some.key="value"
   firebase deploy --only functions
   ```

## Function Details

### updateBalanceAfterSpin

**Purpose**: Securely add coins to user balance after a valid spin

**Parameters**:
- `userId` (string): User ID
- `amount` (number): Amount to add (1-1000)
- `source` (string): Source of earnings ('Spin & Earn', 'Wallet Hub', 'Admin')

**Returns**:
```json
{
  "success": true,
  "newBalance": 150,
  "transactionId": "transaction_id"
}
```

**Security**:
- User can only update their own balance
- Amount validation (1-1000 coins)
- Source validation
- Transaction-based updates

### createWithdrawalRequest

**Purpose**: Create a withdrawal request with balance validation

**Parameters**:
- `userId` (string): User ID
- `method` (string): Withdrawal method ('mpesa', 'tigopesa', 'airtel', 'halopesa', 'usdt')
- `account` (string): Account details (phone number or wallet address)
- `amount` (number): Withdrawal amount (1-10000)

**Returns**:
```json
{
  "success": true,
  "withdrawalId": "withdrawal_id",
  "newBalance": 50,
  "transactionId": "transaction_id"
}
```

**Security**:
- User can only create their own withdrawals
- Balance validation (sufficient funds)
- Amount limits (1-10000)
- Method validation
- Automatic balance deduction

### adminUpdateWithdrawalStatus

**Purpose**: Admin function to update withdrawal status

**Parameters**:
- `withdrawalId` (string): Withdrawal request ID
- `status` (string): New status ('pending', 'completed', 'declined')
- `notes` (string, optional): Admin notes

**Returns**:
```json
{
  "success": true,
  "withdrawalId": "withdrawal_id",
  "status": "completed",
  "processedAt": "2024-01-01T00:00:00.000Z"
}
```

**Security**:
- Admin role required
- Status validation
- Automatic refund for declined withdrawals
- Cannot update already processed withdrawals

### adminUpdateUserBalance

**Purpose**: Admin function to manually adjust user balance

**Parameters**:
- `targetUserId` (string): Target user ID
- `amount` (number): Amount to add/remove (-10000 to 10000)
- `reason` (string): Reason for adjustment

**Returns**:
```json
{
  "success": true,
  "newBalance": 200,
  "transactionId": "transaction_id"
}
```

**Security**:
- Admin role required
- Amount limits (-10000 to 10000)
- Prevents negative balance
- Creates transaction record

### resetDailySpins

**Purpose**: Reset daily spin limits for all users

**Schedule**: Runs daily at 00:00 UTC

**Returns**:
```json
{
  "success": true,
  "updatedUsers": 150
}
```

### getSystemStats

**Purpose**: Get system statistics (admin only)

**Returns**:
```json
{
  "success": true,
  "stats": {
    "totalUsers": 1000,
    "totalBalance": 50000,
    "totalEarnings": 100000,
    "totalWithdrawals": 30000,
    "pendingWithdrawals": 5,
    "totalTransactions": 5000
  }
}
```

## Admin Role Setup

To set up admin users, manually update the user document in Firestore:

```javascript
// In Firebase Console or via Admin SDK
{
  "profile": { "name": "Admin User", "email": "admin@example.com" },
  "balance": { "coins": 0 },
  "roles": { "admin": true },
  "goals": { "weeklyTarget": 0, "monthlyTarget": 0, "progress": 0 },
  "spins": { "dailyUsed": 0, "dailyLimit": 5, "lastSpinDate": null }
}
```

## Error Handling

All functions return structured errors:

```javascript
// Example error response
{
  "code": "permission-denied",
  "message": "Admin access required",
  "details": null
}
```

Common error codes:
- `unauthenticated`: User not logged in
- `permission-denied`: Insufficient permissions
- `invalid-argument`: Invalid parameters
- `failed-precondition`: Business rule violation
- `not-found`: Resource not found
- `internal`: Server error

## Testing

### Local Testing

1. **Start Firebase emulator**
   ```bash
   firebase emulators:start --only functions
   ```

2. **Test functions locally**
   ```bash
   firebase functions:shell
   ```

### Production Testing

Use Firebase Console or your app to test deployed functions.

## Monitoring

### View Logs
```bash
firebase functions:log
```

### Monitor Performance
- Use Firebase Console > Functions
- Set up alerts for errors
- Monitor execution times

## Security Best Practices

1. **Never expose admin functions to client apps**
2. **Always validate input parameters**
3. **Use transactions for critical operations**
4. **Implement proper error handling**
5. **Monitor function logs regularly**
6. **Set up alerts for suspicious activity**

## Troubleshooting

### Common Issues

1. **Function deployment fails**
   - Check Node.js version (18+)
   - Verify Firebase CLI installation
   - Check project permissions

2. **Authentication errors**
   - Verify user is logged in
   - Check Firebase Auth configuration
   - Ensure proper token validation

3. **Permission denied errors**
   - Verify admin role assignment
   - Check Firestore security rules
   - Ensure proper user authentication

4. **Transaction errors**
   - Check Firestore quotas
   - Verify data consistency
   - Monitor concurrent access

### Support

For issues with Cloud Functions:
1. Check Firebase Console logs
2. Review function execution details
3. Verify security rules configuration
4. Test with Firebase emulator

## Version History

### v1.0.0
- Initial release
- Core security functions
- Admin role system
- Scheduled spin reset
- Comprehensive error handling 