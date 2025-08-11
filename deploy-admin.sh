#!/bin/bash

# Admin Panel Deployment Script
# This script builds and deploys the admin panel to Firebase Hosting

echo "🚀 Starting Admin Panel Deployment..."

# Navigate to admin panel directory
cd admin_panel

echo "📦 Installing dependencies..."
npm install --legacy-peer-deps

echo "🔧 Ensuring proper PostCSS configuration..."
# Ensure PostCSS config uses regular tailwindcss plugin
if grep -q "@tailwindcss/postcss7-compat" postcss.config.js; then
    echo "⚠️  Updating PostCSS configuration..."
    sed -i '' 's/@tailwindcss\/postcss7-compat/tailwindcss/g' postcss.config.js
fi

echo "🔨 Building the application..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    # Navigate back to project root
    cd ..
    
    echo "🚀 Deploying to Firebase Hosting..."
    firebase deploy --only hosting
    
    if [ $? -eq 0 ]; then
        echo "✅ Deployment successful!"
        echo "🌐 Admin Panel is now live at: https://fiveinone-earning-system.web.app"
        echo "📊 Firebase Console: https://console.firebase.google.com/project/fiveinone-earning-system/hosting"
        echo "🎨 Styling: TailwindCSS styles are now properly compiled and deployed"
        echo "👤 Registration: Admin account creation is now available"
    else
        echo "❌ Deployment failed!"
        exit 1
    fi
else
    echo "❌ Build failed!"
    exit 1
fi 