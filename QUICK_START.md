# 🚀 Quick Start Guide

## ⚡ Get Your Backend Running in 5 Minutes

### 1. 🗂️ Create GitHub Repository
```bash
# Go to GitHub.com and create: quiz-and-learn-backend
# Make it PUBLIC for free hosting
```

### 2. 📤 Push to GitHub
```bash
git init
git remote add origin https://github.com/YOUR_USERNAME/quiz-and-learn-backend.git
git add .
git commit -m "Initial commit: Secure Quiz and Learn Backend"
git push -u origin main
```

### 3. 🌐 Deploy to Vercel
```bash
# Install Vercel CLI
npm install -g @vercel/cli

# Login and deploy
vercel login
vercel --prod
```

### 4. 🔧 Set Environment Variables
In Vercel dashboard, add:
- `MONGO_URL`: Your MongoDB connection string
- `JWT_SECRET`: Any long random string
- `ADMOB_SSV_SECRET`: Your AdMob secret
- `APP_SIGNATURE_HASHES`: hash1,hash2
- `PLAY_INTEGRITY_KEYS`: key1,key2
- `APP_ATTEST_KEYS`: key1,key2

### 5. 📱 Update Mobile App
```bash
# Build with new API URL
flutter build apk --dart-define=API_BASE_URL=https://your-app.vercel.app
```

## 🎯 What You Get

✅ **Hosted Backend** on Vercel  
✅ **Anti-Fraud Security** with device attestation  
✅ **MongoDB Database** for data storage  
✅ **AdMob SSV** for secure rewards  
✅ **Automatic Deployments** on every push  
✅ **Mobile App Integration** ready  

## 🔗 Your API Endpoints

- **Health**: `https://your-app.vercel.app/health`
- **Config**: `https://your-app.vercel.app/v1/config`
- **Attestation**: `https://your-app.vercel.app/v1/attest/*`
- **AdMob SSV**: `https://your-app.vercel.app/v1/ads/ssv/*`

## 🧪 Test It

```bash
# Test your live API
curl https://your-app.vercel.app/health
curl https://your-app.vercel.app/v1/config
```

## 🚨 Need Help?

1. Check Vercel deployment logs
2. Verify environment variables
3. Test endpoints manually
4. Review the detailed guides in this repo

**Your backend is now live and secure! 🎉**
