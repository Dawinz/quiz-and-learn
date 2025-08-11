#!/bin/bash

echo "🚀 Starting deployment of 5-in-1 Earning System..."

# Build Admin Panel
echo "📦 Building Admin Panel..."
cd admin_panel
npm run build
cd ..

# Install Cloud Functions dependencies
echo "🔧 Installing Cloud Functions dependencies..."
cd functions
npm install
cd ..

# Deploy to Firebase
echo "🚀 Deploying to Firebase..."
firebase deploy

echo "✅ Deployment completed!" 