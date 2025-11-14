# 🚀 Deployment Guide

Complete guide to deploy your ECommerce application.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Backend Deployment](#backend-deployment)
3. [Flutter Web Deployment](#flutter-web-deployment)
4. [Mobile App Deployment](#mobile-app-deployment)
5. [Environment Configuration](#environment-configuration)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Accounts
- [ ] GitHub account (for code hosting)
- [ ] MongoDB Atlas account (free tier available)
- [ ] Railway/Render/Heroku account (for backend)
- [ ] Firebase account (for Flutter web hosting)
- [ ] Razorpay account (for payments)
- [ ] Cloudinary account (for image storage)
- [ ] Gmail account (for email service)

### Required Tools
- Node.js and npm
- Flutter SDK
- Git
- Firebase CLI: `npm install -g firebase-tools`

---

## Backend Deployment

### Option 1: Railway (Recommended - Easiest)

**Why Railway?**
- ✅ Free tier available
- ✅ Auto-deploys from GitHub
- ✅ Built-in MongoDB option
- ✅ Automatic HTTPS
- ✅ Easy environment variable management

**Steps:**

1. **Sign up** at [railway.app](https://railway.app)

2. **Create Project**:
   ```
   New Project → Deploy from GitHub repo
   → Select your repository
   ```

3. **Add MongoDB**:
   ```
   New → Database → MongoDB
   → Copy connection string
   ```

4. **Configure Environment Variables**:
   Go to your service → Variables tab and add:
   ```env
   MONGODB_URI=mongodb+srv://...
   JWT_SECRET=your-32-char-secret
   RAZORPAY_KEY_ID=rzp_...
   RAZORPAY_KEY_SECRET=...
   CLOUDINARY_CLOUD_NAME=...
   CLOUDINARY_API_KEY=...
   CLOUDINARY_API_SECRET=...
   EMAIL_HOST=smtp.gmail.com
   EMAIL_PORT=587
   EMAIL_USER=your-email@gmail.com
   EMAIL_PASS=your-app-password
   NODE_ENV=production
   FRONTEND_URL=https://your-frontend-url.com
   ```

5. **Deploy**:
   - Railway automatically deploys on git push
   - Get your URL: `https://your-app.railway.app`

### Option 2: Render

1. Go to [render.com](https://render.com)
2. New → Web Service
3. Connect GitHub repository
4. Settings:
   - Build Command: `npm install`
   - Start Command: `npm start`
5. Add MongoDB: New → MongoDB
6. Set environment variables
7. Deploy

### Option 3: Heroku

```bash
# Install Heroku CLI
npm install -g heroku

# Login
heroku login

# Create app
heroku create your-app-name

# Set environment variables
heroku config:set MONGODB_URI=...
heroku config:set JWT_SECRET=...
# ... add all variables

# Deploy
git push heroku main
```

---

## Flutter Web Deployment

### Step 1: Update API URL

Edit `ecommerce/lib/utils/api.dart`:

```dart
// Change from:
const String API_BASE = 'http://localhost:5000/api/v1';

// To:
const String API_BASE = 'https://your-backend-url.railway.app/api/v1';
```

### Step 2: Build Web App

```bash
cd ecommerce
flutter clean
flutter pub get
flutter build web --release
```

### Step 3: Deploy to Firebase Hosting

1. **Initialize Firebase** (first time only):
   ```bash
   firebase login
   firebase init hosting
   # Select: Use existing project or create new
   # Public directory: build/web
   # Single-page app: Yes
   # Overwrite index.html: No
   ```

2. **Deploy**:
   ```bash
   flutter build web --release
   firebase deploy --only hosting
   ```

3. **Your app is live!** 🎉
   - URL: `https://your-project.web.app`

### Alternative: Netlify

1. Build: `flutter build web --release`
2. Go to [netlify.com](https://netlify.com)
3. Drag and drop `build/web` folder
4. Done!

### Alternative: Vercel

```bash
cd ecommerce/build/web
npm install -g vercel
vercel --prod
```

---

## Mobile App Deployment

### Android (Google Play Store)

#### 1. Generate Keystore

```bash
cd ecommerce/android
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Save the passwords!** You'll need them.

#### 2. Configure Signing

Create `android/key.properties`:

```properties
storePassword=your-keystore-password
keyPassword=your-key-password
keyAlias=upload
storeFile=/Users/yourname/upload-keystore.jks
```

#### 3. Update build.gradle.kts

See `ecommerce/android/app/build.gradle.kts.release` for configuration.

#### 4. Build App Bundle

```bash
cd ecommerce
flutter build appbundle --release
```

#### 5. Upload to Play Store

1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app
3. Upload `build/app/outputs/bundle/release/app-release.aab`
4. Complete store listing
5. Submit for review

### iOS (App Store)

#### 1. Configure in Xcode

```bash
cd ecommerce/ios
open Runner.xcworkspace
```

#### 2. Set Up Signing

- Select your Apple Developer team
- Set unique bundle identifier
- Configure signing certificates

#### 3. Build and Archive

- In Xcode: Product → Archive
- Upload to App Store Connect
- Submit for review

---

## Environment Configuration

### MongoDB Atlas Setup

1. **Create Account**: [mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas)

2. **Create Cluster**:
   - Choose free tier (M0)
   - Select region closest to your backend

3. **Database Access**:
   - Create database user
   - Save username and password

4. **Network Access**:
   - Add IP: `0.0.0.0/0` (allow all for now)
   - Or add specific IPs for security

5. **Get Connection String**:
   ```
   mongodb+srv://username:password@cluster.mongodb.net/ecommerce_db?retryWrites=true&w=majority
   ```

### Razorpay Setup

1. Sign up at [razorpay.com](https://razorpay.com)
2. Go to Dashboard → Settings → API Keys
3. Generate Test Keys (for testing)
4. Generate Live Keys (for production)
5. Add to environment variables

### Cloudinary Setup

1. Sign up at [cloudinary.com](https://cloudinary.com)
2. Get credentials from Dashboard:
   - Cloud Name
   - API Key
   - API Secret
3. Add to environment variables

### Gmail App Password

1. Go to [Google Account](https://myaccount.google.com)
2. Security → 2-Step Verification (enable if not)
3. App Passwords → Generate
4. Select "Mail" and device
5. Copy the 16-character password
6. Use in `EMAIL_PASS` variable

---

## Post-Deployment Checklist

### Backend ✅
- [ ] API accessible via HTTPS
- [ ] MongoDB connected
- [ ] All environment variables set
- [ ] CORS configured for frontend domain
- [ ] Payment gateway working
- [ ] Email service configured
- [ ] Image upload working

### Flutter Web ✅
- [ ] API base URL updated
- [ ] App builds without errors
- [ ] All features working
- [ ] HTTPS enabled
- [ ] Performance optimized

### Mobile Apps ✅
- [ ] App signed correctly
- [ ] API URL points to production
- [ ] All features tested
- [ ] App store listings complete
- [ ] Privacy policy added (if required)

---

## Troubleshooting

### Backend Issues

**CORS Errors:**
```javascript
// In server.js, ensure FRONTEND_URL is set:
FRONTEND_URL=https://your-frontend-url.com
```

**Database Connection Fails:**
- Check MongoDB connection string
- Verify IP whitelist includes deployment platform
- Check username/password

**Port Issues:**
- Use `process.env.PORT` (platforms set this automatically)
- Don't hardcode port numbers

### Flutter Issues

**API Calls Fail:**
- Verify API base URL
- Check CORS settings on backend
- Ensure HTTPS is used in production

**Build Fails:**
```bash
flutter clean
flutter pub get
flutter build web --release
```

**Android Signing Issues:**
- Verify `key.properties` file exists
- Check keystore file path
- Ensure passwords are correct

---

## Quick Reference

### Update API URL Script

```bash
# From project root
node backend/scripts/update-api-url.js https://your-backend-url.com
```

### Deployment Commands

```bash
# Backend (Railway - auto on git push)
git push origin main

# Flutter Web
cd ecommerce
flutter build web --release
firebase deploy --only hosting

# Android
flutter build appbundle --release

# iOS
flutter build ios --release
# Then archive in Xcode
```

---

## Support

- Full guide: See `DEPLOYMENT.md`
- Quick start: See `DEPLOY_QUICK_START.md`
- Railway docs: https://docs.railway.app
- Firebase docs: https://firebase.google.com/docs
- Flutter docs: https://flutter.dev/docs/deployment

---

## Security Notes

⚠️ **Important:**
- Never commit `.env` files
- Use strong JWT secrets (32+ characters)
- Enable HTTPS everywhere
- Restrict CORS to your domains in production
- Use environment variables for all secrets
- Keep dependencies updated

---

**Happy Deploying! 🚀**

