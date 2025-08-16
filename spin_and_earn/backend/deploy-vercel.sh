#!/bin/bash

echo "🚀 Deploying Spin & Earn Backend to Vercel..."

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo "❌ Vercel CLI not found. Installing..."
    npm install -g vercel
fi

# Check if we're in the backend directory
if [ ! -f "package.json" ] || [ ! -f "server.js" ]; then
    echo "❌ Please run this script from the backend directory"
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Deploy to Vercel
echo "🌐 Deploying to Vercel..."
vercel --prod

echo "✅ Deployment complete!"
echo "🔗 Check your Vercel dashboard for the deployment URL"
echo "📝 Don't forget to set environment variables in Vercel dashboard:"
echo "   - MONGO_URI"
echo "   - JWT_SECRET"
echo "   - NODE_ENV=production"
echo "   - CORS_ORIGIN"
