# ✅ RENDER DEPLOYMENT CHECKLIST

## 🚀 **QUICK DEPLOYMENT (5 Minutes)**

### **1. Open Render Dashboard**
```
https://dashboard.render.com
```

### **2. Create Web Service**
- [ ] Click "New +" → "Web Service"
- [ ] Connect GitHub repo: `quiz-and-learn`
- [ ] Branch: `main`

### **3. Configure Service**
- [ ] **Name**: `spin-and-earn-backend`
- [ ] **Environment**: `Node`
- [ ] **Build Command**: `npm install`
- [ ] **Start Command**: `npm start`
- [ ] **Plan**: `Free`

### **4. Set Environment Variables**
- [ ] **MONGO_URI**: `mongodb+srv://dawinibra:r8yeG3kOb57XgEsC@spinandearn.nftuswu.mongodb.net/?retryWrites=true&w=majority&appName=spinandearn`
- [ ] **JWT_SECRET**: `SuperSecretKey123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ`
- [ ] **JWT_EXPIRES_IN**: `7d`
- [ ] **NODE_ENV**: `production`
- [ ] **CORS_ORIGIN**: `*`
- [ ] **RATE_LIMIT_WINDOW_MS**: `900000`
- [ ] **RATE_LIMIT_MAX_REQUESTS**: `100`
- [ ] **REFERRAL_BONUS_AMOUNT**: `25`
- [ ] **REFERRAL_BONUS_REFERRER**: `10`
- [ ] **REFERRAL_CODE_LENGTH**: `8`

### **5. Deploy**
- [ ] Click "Create Web Service"
- [ ] Wait for build (5-10 minutes)

## 🌐 **Your Backend URL**
```
https://spin-and-earn-backend.onrender.com
```

## 🧪 **Test After Deployment**
```bash
curl https://spin-and-earn-backend.onrender.com/health
```

## 📱 **Update Flutter App**
```dart
const String apiBaseUrl = 'https://spin-and-earn-backend.onrender.com';
```

---

**🎯 COMPLETE THIS CHECKLIST AND YOUR APP WILL BE WORKING! 🎯**
