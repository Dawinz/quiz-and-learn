#!/bin/bash

echo "🚀 Deploying Spin & Earn Backend to Render..."

# Check if render CLI is installed
if ! command -v render &> /dev/null; then
    echo "📦 Installing Render CLI..."
    curl -sL https://render.com/download-cli/linux | bash
    export PATH="$HOME/.local/bin:$PATH"
fi

# Login to Render (if not already logged in)
echo "🔐 Logging into Render..."
render login

# Deploy the service
echo "🚀 Deploying service..."
render deploy

echo "✅ Deployment initiated! Check your Render dashboard for status."
echo "🌐 Your backend will be available at: https://spin-and-earn-backend.onrender.com"
