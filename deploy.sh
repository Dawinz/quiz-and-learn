#!/bin/bash

echo "🚀 Quiz & Learn Backend Deployment Script"
echo "=========================================="

# Check if we're in the right directory
if [ ! -f "quiz_and_learn/backend/package.json" ]; then
    echo "❌ Please run this script from the project root directory"
    exit 1
fi

# Function to deploy to Render
deploy_to_render() {
    echo "📦 Deploying to Render..."
    
    # Check if render CLI is installed
    if ! command -v render &> /dev/null; then
        echo "📥 Installing Render CLI..."
        curl -sL https://render.com/download.sh | sh
    fi
    
    # Deploy to Render
    cd quiz_and_learn/backend
    render deploy --service quiz-and-learn-backend
    
    echo "✅ Render deployment initiated!"
    echo "🔗 Check your Render dashboard for the deployment status"
}

# Function to deploy to Railway
deploy_to_railway() {
    echo "🚂 Deploying to Railway..."
    
    # Check if Railway CLI is installed
    if ! command -v railway &> /dev/null; then
        echo "📥 Installing Railway CLI..."
        npm install -g @railway/cli
    fi
    
    # Deploy to Railway
    cd quiz_and_learn/backend
    railway up
    
    echo "✅ Railway deployment initiated!"
    echo "🔗 Check your Railway dashboard for the deployment status"
}

# Function to deploy to Fly.io
deploy_to_fly() {
    echo "🦅 Deploying to Fly.io..."
    
    # Check if Fly CLI is installed
    if ! command -v flyctl &> /dev/null; then
        echo "📥 Installing Fly CLI..."
        curl -L https://fly.io/install.sh | sh
    fi
    
    # Deploy to Fly.io
    cd quiz_and_learn/backend
    flyctl deploy
    
    echo "✅ Fly.io deployment initiated!"
    echo "🔗 Check your Fly.io dashboard for the deployment status"
}

# Function to deploy to Heroku
deploy_to_heroku() {
    echo "🦸 Deploying to Heroku..."
    
    # Check if Heroku CLI is installed
    if ! command -v heroku &> /dev/null; then
        echo "📥 Installing Heroku CLI..."
        curl https://cli-assets.heroku.com/install.sh | sh
    fi
    
    # Deploy to Heroku
    cd quiz_and_learn/backend
    heroku create quiz-and-learn-backend-$(date +%s)
    git add .
    git commit -m "Deploy to Heroku"
    git push heroku main
    
    echo "✅ Heroku deployment initiated!"
    echo "🔗 Check your Heroku dashboard for the deployment status"
}

# Function to deploy to DigitalOcean App Platform
deploy_to_digitalocean() {
    echo "🐙 Deploying to DigitalOcean App Platform..."
    
    # Check if doctl is installed
    if ! command -v doctl &> /dev/null; then
        echo "📥 Installing DigitalOcean CLI..."
        snap install doctl
    fi
    
    echo "📋 Please deploy manually to DigitalOcean App Platform:"
    echo "1. Go to https://cloud.digitalocean.com/apps"
    echo "2. Click 'Create App'"
    echo "3. Connect your GitHub repository"
    echo "4. Set build command: cd quiz_and_learn/backend && npm install && npm run build"
    echo "5. Set run command: cd quiz_and_learn/backend && npm start"
    echo "6. Add environment variables (MONGO_URI, JWT_SECRET, etc.)"
}

# Main menu
echo ""
echo "Choose your deployment option:"
echo "1) Render (Free, Easy)"
echo "2) Railway (Free tier available)"
echo "3) Fly.io (Free tier available)"
echo "4) Heroku (Free tier available)"
echo "5) DigitalOcean App Platform (Free tier available)"
echo "6) Deploy to all (GitHub Actions)"
echo ""

read -p "Enter your choice (1-6): " choice

case $choice in
    1)
        deploy_to_render
        ;;
    2)
        deploy_to_railway
        ;;
    3)
        deploy_to_fly
        ;;
    4)
        deploy_to_heroku
        ;;
    5)
        deploy_to_digitalocean
        ;;
    6)
        echo "🚀 Setting up GitHub Actions deployment..."
        echo "📋 Please:"
        echo "1. Push this repository to GitHub"
        echo "2. Set up the required secrets in your GitHub repository"
        echo "3. The GitHub Actions workflow will automatically deploy on push"
        ;;
    *)
        echo "❌ Invalid choice. Please run the script again."
        exit 1
        ;;
esac

echo ""
echo "🎉 Deployment process completed!"
echo "📱 Don't forget to update your Flutter app with the new backend URL"
