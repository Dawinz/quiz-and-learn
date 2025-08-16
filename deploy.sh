#!/bin/bash

# Quiz and Learn Backend Deployment Script
# This script helps deploy the backend to various platforms

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_requirements() {
    print_status "Checking requirements..."
    
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed. Please install Node.js 18+ first."
        exit 1
    fi
    
    if ! command -v npm &> /dev/null; then
        print_error "npm is not installed. Please install npm first."
        exit 1
    fi
    
    print_success "Requirements check passed"
}

# Build the project
build_project() {
    print_status "Building project..."
    
    # Clean previous build
    if [ -d "dist" ]; then
        rm -rf dist
    fi
    
    # Install dependencies
    npm ci
    
    # Build the project
    npm run build
    
    print_success "Project built successfully"
}

# Deploy to Heroku
deploy_heroku() {
    print_status "Deploying to Heroku..."
    
    if ! command -v heroku &> /dev/null; then
        print_error "Heroku CLI is not installed. Please install it first: https://devcenter.heroku.com/articles/heroku-cli"
        exit 1
    fi
    
    # Check if Heroku app exists
    if ! heroku apps:info &> /dev/null; then
        print_warning "No Heroku app configured. Please create one first:"
        echo "  heroku create your-app-name"
        echo "  heroku git:remote -a your-app-name"
        exit 1
    fi
    
    # Deploy
    git add .
    git commit -m "Deploy to Heroku - $(date)"
    git push heroku main
    
    print_success "Deployed to Heroku successfully"
}

# Deploy to Railway
deploy_railway() {
    print_status "Deploying to Railway..."
    
    if ! command -v railway &> /dev/null; then
        print_error "Railway CLI is not installed. Please install it first: npm i -g @railway/cli"
        exit 1
    fi
    
    # Deploy
    railway up
    
    print_success "Deployed to Railway successfully"
}

# Deploy to Vercel
deploy_vercel() {
    print_status "Deploying to Vercel..."
    
    if ! command -v vercel &> /dev/null; then
        print_error "Vercel CLI is not installed. Please install it first: npm i -g vercel"
        exit 1
    fi
    
    # Deploy
    vercel --prod
    
    print_success "Deployed to Vercel successfully"
}

# Deploy using Docker
deploy_docker() {
    print_status "Building and running Docker container..."
    
    # Build image
    docker build -t quiz-and-learn-backend .
    
    # Stop existing container if running
    docker stop quiz-and-learn-backend 2>/dev/null || true
    docker rm quiz-and-learn-backend 2>/dev/null || true
    
    # Run new container
    docker run -d \
        --name quiz-and-learn-backend \
        -p 3000:3000 \
        --env-file .env \
        quiz-and-learn-backend
    
    print_success "Docker container deployed successfully"
    print_status "Container running on http://localhost:3000"
}

# Run locally with Docker Compose
run_local() {
    print_status "Starting local development environment with Docker Compose..."
    
    # Check if .env file exists
    if [ ! -f ".env" ]; then
        print_warning ".env file not found. Creating from example..."
        cp env.example .env
        print_warning "Please update .env file with your configuration before continuing"
        exit 1
    fi
    
    # Start services
    docker-compose up -d
    
    print_success "Local environment started successfully"
    print_status "API running on http://localhost:3000"
    print_status "MongoDB running on localhost:27017"
    print_status "Mongo Express running on http://localhost:8081"
}

# Show usage
show_usage() {
    echo "Quiz and Learn Backend Deployment Script"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  build       Build the project"
    echo "  heroku      Deploy to Heroku"
    echo "  railway     Deploy to Railway"
    echo "  vercel      Deploy to Vercel"
    echo "  docker      Deploy using Docker"
    echo "  local       Run locally with Docker Compose"
    echo "  all         Build and deploy to all platforms"
    echo "  help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build"
    echo "  $0 heroku"
    echo "  $0 local"
}

# Main script
main() {
    case "${1:-help}" in
        "build")
            check_requirements
            build_project
            ;;
        "heroku")
            check_requirements
            build_project
            deploy_heroku
            ;;
        "railway")
            check_requirements
            build_project
            deploy_railway
            ;;
        "vercel")
            check_requirements
            build_project
            deploy_vercel
            ;;
        "docker")
            check_requirements
            build_project
            deploy_docker
            ;;
        "local")
            run_local
            ;;
        "all")
            check_requirements
            build_project
            deploy_heroku
            deploy_railway
            deploy_vercel
            deploy_docker
            ;;
        "help"|*)
            show_usage
            ;;
    esac
}

# Run main function
main "$@"
