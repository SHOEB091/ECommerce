#!/bin/bash

# Deployment Helper Script
# Usage: ./deploy.sh [backend|flutter|all]

set -e

DEPLOY_TYPE=${1:-all}

echo "🚀 Starting deployment process..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

deploy_backend() {
    echo -e "${BLUE}📦 Deploying Backend...${NC}"
    cd backend
    
    echo "✅ Backend deployment instructions:"
    echo "   1. Push to GitHub (Railway/Render auto-deploys)"
    echo "   2. Or run: heroku git:remote -a your-app && git push heroku main"
    echo "   3. Set environment variables in your platform dashboard"
    
    cd ..
}

deploy_flutter_web() {
    echo -e "${BLUE}🌐 Building Flutter Web...${NC}"
    cd ecommerce
    
    # Check if API URL needs updating
    read -p "Update API base URL? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter backend API URL (e.g., https://your-app.railway.app): " API_URL
        if [ ! -z "$API_URL" ]; then
            # Update API base URL in api.dart
            sed -i.bak "s|const String API_BASE = .*|const String API_BASE = '$API_URL/api/v1';|g" lib/utils/api.dart
            echo -e "${GREEN}✅ Updated API base URL${NC}"
        fi
    fi
    
    echo "Building web app..."
    flutter clean
    flutter pub get
    flutter build web --release
    
    echo -e "${GREEN}✅ Web build complete!${NC}"
    echo "📁 Build output: build/web"
    echo ""
    echo "To deploy:"
    echo "  Firebase: firebase deploy --only hosting"
    echo "  Netlify:  Drag build/web folder to netlify.com"
    echo "  Vercel:   vercel --prod (in build/web directory)"
    
    cd ..
}

deploy_flutter_android() {
    echo -e "${BLUE}📱 Building Android App...${NC}"
    cd ecommerce
    
    # Check for keystore
    if [ ! -f "android/key.properties" ]; then
        echo -e "${YELLOW}⚠️  key.properties not found${NC}"
        echo "Creating from example..."
        cp android/key.properties.example android/key.properties
        echo -e "${YELLOW}⚠️  Please edit android/key.properties with your keystore details${NC}"
        read -p "Press enter after configuring key.properties..."
    fi
    
    flutter clean
    flutter pub get
    flutter build appbundle --release
    
    echo -e "${GREEN}✅ Android build complete!${NC}"
    echo "📁 App Bundle: build/app/outputs/bundle/release/app-release.aab"
    echo "📤 Upload to Google Play Console"
    
    cd ..
}

case $DEPLOY_TYPE in
    backend)
        deploy_backend
        ;;
    flutter|web)
        deploy_flutter_web
        ;;
    android)
        deploy_flutter_android
        ;;
    all)
        deploy_backend
        echo ""
        deploy_flutter_web
        ;;
    *)
        echo "Usage: ./deploy.sh [backend|flutter|android|all]"
        exit 1
        ;;
esac

echo -e "${GREEN}🎉 Deployment process complete!${NC}"

