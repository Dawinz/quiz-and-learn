# 🚀 Render Deployment Guide

## Quick Deploy to Render (No SSO Issues!)

### Option 1: Manual Deployment (Recommended)

1. **Go to Render Dashboard**: https://dashboard.render.com
2. **Click "New +" → "Web Service"**
3. **Connect your GitHub repository**
4. **Configure the service:**
   - **Name**: `spin-and-earn-backend`
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Plan**: `Free`

5. **Set Environment Variables:**
   ```
   MONGO_URI=mongodb+srv://dawinibra:r8yeG3kOb57XgEsC@spinandearn.nftuswu.mongodb.net/?retryWrites=true&w=majority&appName=spinandearn
   JWT_SECRET=SuperSecretKey123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ
   JWT_EXPIRES_IN=7d
   NODE_ENV=production
   CORS_ORIGIN=*
   RATE_LIMIT_WINDOW_MS=900000
   RATE_LIMIT_MAX_REQUESTS=100
   REFERRAL_BONUS_AMOUNT=25
   REFERRAL_BONUS_REFERRER=10
   REFERRAL_CODE_LENGTH=8
   ```

6. **Click "Create Web Service"**

### Option 2: CLI Deployment

```bash
# Install Render CLI
curl -sL https://render.com/download-cli/linux | bash

# Login to Render
render login

# Deploy
render deploy
```

## ✅ Benefits of Render

- **No SSO Authentication Required** 🎉
- **Free Tier Available** 💰
- **Automatic Deployments** 🚀
- **Global CDN** 🌍
- **SSL Certificates** 🔒
- **Custom Domains** 🌐

## 🔗 Your Backend URL

Once deployed, your backend will be available at:
```
https://spin-and-earn-backend.onrender.com
```

## 🧪 Test Your Backend

```bash
# Health check
curl https://spin-and-earn-backend.onrender.com/health

# Should return: {"status":"success","message":"Spin & Earn Backend is running"}
```

## 📱 Update Flutter App

Update your Flutter app's API base URL to:
```dart
const String apiBaseUrl = 'https://spin-and-earn-backend.onrender.com';
```

## 🎯 Next Steps

1. ✅ Deploy to Render
2. ✅ Test MongoDB connection
3. ✅ Update Flutter app
4. ✅ Test complete integration
5. ✅ Submit to Play Store

## 🆘 Need Help?

- **Render Docs**: https://render.com/docs
- **Render Support**: https://render.com/support
- **Community**: https://community.render.com
