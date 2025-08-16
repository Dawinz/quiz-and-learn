# 🚀 Quiz & Learn Backend Deployment Guide

This guide will help you deploy the Quiz & Learn backend to various hosting platforms.

## 🎯 Quick Start (Recommended: Render)

**Render** is the easiest and most reliable option for free deployment:

1. **Sign up** at [render.com](https://render.com)
2. **Run the deployment script:**
   ```bash
   ./deploy.sh
   ```
3. **Choose option 1 (Render)**
4. **Follow the prompts** to connect your account
5. **Get your backend URL** from the Render dashboard

## 🌐 Available Deployment Options

### 1. **Render** (Recommended - Free, Easy)
- ✅ Free tier available
- ✅ Automatic deployments from GitHub
- ✅ Easy setup
- ✅ Reliable hosting

### 2. **Railway** (Good Alternative)
- ✅ Free tier available
- ✅ Fast deployments
- ✅ Good for development

### 3. **Fly.io** (Performance)
- ✅ Free tier available
- ✅ Global edge deployment
- ✅ Good performance

### 4. **Heroku** (Classic)
- ✅ Free tier available
- ✅ Well-established platform
- ✅ Good documentation

### 5. **DigitalOcean App Platform**
- ✅ Free tier available
- ✅ Good performance
- ✅ Professional hosting

## 🔧 Manual Deployment Steps

### For Render:

1. Go to [render.com](https://render.com) and sign up
2. Click "New +" → "Web Service"
3. Connect your GitHub repository
4. Configure the service:
   - **Name**: `quiz-and-learn-backend`
   - **Build Command**: `cd quiz_and_learn/backend && npm install && npm run build`
   - **Start Command**: `cd quiz_and_learn/backend && npm start`
   - **Plan**: Free

5. Add environment variables:
   ```
   NODE_ENV=production
   PORT=10000
   MONGO_URI=your_mongodb_atlas_connection_string
   JWT_SECRET=your_secret_key
   CORS_ORIGIN=*
   ```

6. Click "Create Web Service"

### For Railway:

1. Go to [railway.app](https://railway.app) and sign up
2. Click "New Project" → "Deploy from GitHub repo"
3. Select your repository
4. Railway will automatically detect the Node.js app
5. Add environment variables in the Variables tab
6. Deploy!

### For Fly.io:

1. Install Fly CLI: `curl -L https://fly.io/install.sh | sh`
2. Sign up at [fly.io](https://fly.io)
3. Run: `flyctl auth login`
4. Navigate to backend: `cd quiz_and_learn/backend`
5. Run: `flyctl launch`
6. Follow the prompts and deploy

## 🔑 Environment Variables

Set these environment variables in your hosting platform:

```bash
NODE_ENV=production
PORT=10000
MONGO_URI=mongodb+srv://dawinibra:nP4Xf7NJ11I7db94@cluster0.yi6y2jk.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0
JWT_SECRET=your_super_secret_jwt_key_here
JWT_EXPIRES_IN=7d
CORS_ORIGIN=*
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

## 📱 Update Flutter App

After deployment, update your Flutter app's API service:

```dart
// In quiz_and_learn/lib/services/api_service.dart
void _initializeBaseUrl() {
  baseUrl = "https://your-backend-url.onrender.com/api"; // Update this
}
```

## 🚀 GitHub Actions Deployment

For automatic deployments:

1. **Push to GitHub:**
   ```bash
   git add .
   git commit -m "Setup deployment"
   git push origin main
   ```

2. **Set up secrets** in your GitHub repository:
   - Go to Settings → Secrets and variables → Actions
   - Add the required secrets (RAILWAY_TOKEN, RENDER_API_KEY, etc.)

3. **The workflow will automatically deploy** on every push to main branch

## 🧪 Test Your Deployment

After deployment, test these endpoints:

```bash
# Health check
curl https://your-backend-url.onrender.com/health

# Test API
curl https://your-backend-url.onrender.com/api/test

# Test auth (should return mock data)
curl -X POST https://your-backend-url.onrender.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test123"}'
```

## 🔍 Troubleshooting

### Common Issues:

1. **Build fails**: Check if all dependencies are in package.json
2. **Port issues**: Make sure PORT environment variable is set
3. **MongoDB connection**: Verify your MONGO_URI is correct
4. **CORS errors**: Check CORS_ORIGIN setting

### Debug Commands:

```bash
# Check backend logs
cd quiz_and_learn/backend
npm start

# Test locally
curl http://localhost:3001/health

# Check environment
echo $MONGO_URI
echo $NODE_ENV
```

## 📞 Support

If you encounter issues:

1. Check the hosting platform's logs
2. Verify environment variables
3. Test locally first
4. Check the hosting platform's documentation

## 🎉 Success!

Once deployed, your backend will be accessible at:
`https://your-backend-url.onrender.com`

Update your Flutter app with this URL and test the login/register functionality!
