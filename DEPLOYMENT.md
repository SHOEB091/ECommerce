# Deployment Guide

This guide covers deploying both the backend API and Flutter frontend.

## Table of Contents
1. [Backend Deployment](#backend-deployment)
2. [Flutter App Deployment](#flutter-app-deployment)
3. [Environment Variables](#environment-variables)

---

## Backend Deployment

### Option 1: Railway (Recommended - Easy & Free Tier Available)

1. **Sign up** at [Railway.app](https://railway.app)

2. **Create a new project**:
   - Click "New Project"
   - Select "Deploy from GitHub repo" (connect your GitHub account)
   - Select your repository

3. **Add MongoDB**:
   - Click "New" → "Database" → "MongoDB"
   - Copy the connection string

4. **Configure Environment Variables**:
   - Go to your service → Variables
   - Add all variables from `.env.example` (see below)

5. **Deploy**:
   - Railway auto-detects Node.js and runs `npm start`
   - Your API will be available at `https://your-app.railway.app`

### Option 2: Render

1. **Sign up** at [Render.com](https://render.com)

2. **Create a Web Service**:
   - New → Web Service
   - Connect your GitHub repository
   - Build Command: `npm install`
   - Start Command: `npm start`

3. **Add MongoDB**:
   - New → MongoDB
   - Copy connection string

4. **Set Environment Variables** in Render dashboard

5. **Deploy** - Render will automatically deploy on git push

### Option 3: Heroku

1. **Install Heroku CLI**:
   ```bash
   npm install -g heroku
   ```

2. **Login and create app**:
   ```bash
   heroku login
   heroku create your-app-name
   ```

3. **Add MongoDB Atlas** (free tier available):
   - Sign up at [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
   - Create a free cluster
   - Get connection string

4. **Set environment variables**:
   ```bash
   heroku config:set JWT_SECRET=your-secret-key
   heroku config:set MONGODB_URI=your-mongodb-uri
   # ... add all other variables
   ```

5. **Deploy**:
   ```bash
   git push heroku main
   ```

### Option 4: DigitalOcean App Platform

1. **Sign up** at [DigitalOcean](https://www.digitalocean.com)

2. **Create App**:
   - Go to App Platform
   - Connect GitHub repository
   - Select Node.js
   - Configure build and run commands

3. **Add Database**:
   - Add MongoDB managed database
   - Use connection string in environment variables

4. **Deploy**

---

## Flutter App Deployment

### Web Deployment

#### Option 1: Firebase Hosting (Recommended)

1. **Install Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   ```

2. **Login**:
   ```bash
   firebase login
   ```

3. **Initialize Firebase**:
   ```bash
   cd ecommerce
   flutter build web
   firebase init hosting
   ```

4. **Deploy**:
   ```bash
   firebase deploy --only hosting
   ```

#### Option 2: Netlify

1. **Build web app**:
   ```bash
   cd ecommerce
   flutter build web --release
   ```

2. **Deploy**:
   - Go to [Netlify](https://www.netlify.com)
   - Drag and drop the `build/web` folder
   - Or connect GitHub for auto-deploy

#### Option 3: Vercel

1. **Build**:
   ```bash
   cd ecommerce
   flutter build web --release
   ```

2. **Deploy**:
   - Install Vercel CLI: `npm i -g vercel`
   - Run: `vercel --prod` in the `build/web` directory

### Android Deployment

1. **Generate Keystore**:
   ```bash
   cd ecommerce/android
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Configure signing** in `android/app/build.gradle.kts`

3. **Build APK**:
   ```bash
   flutter build apk --release
   ```

4. **Build App Bundle** (for Play Store):
   ```bash
   flutter build appbundle --release
   ```

5. **Upload to Google Play Console**:
   - Go to [Google Play Console](https://play.google.com/console)
   - Create app
   - Upload the `.aab` file from `build/app/outputs/bundle/release/`

### iOS Deployment

1. **Open Xcode**:
   ```bash
   cd ecommerce/ios
   open Runner.xcworkspace
   ```

2. **Configure signing**:
   - Select your team in Xcode
   - Configure bundle identifier

3. **Build**:
   ```bash
   flutter build ios --release
   ```

4. **Archive and upload**:
   - In Xcode: Product → Archive
   - Upload to App Store Connect

---

## Environment Variables

### Backend (.env)

Create a `.env` file in the `backend` directory:

```env
# Server
PORT=5000
NODE_ENV=production

# Database
MONGODB_URI=your-mongodb-connection-string

# JWT
JWT_SECRET=your-super-secret-jwt-key-min-32-characters

# Razorpay
RAZORPAY_KEY_ID=your-razorpay-key-id
RAZORPAY_KEY_SECRET=your-razorpay-key-secret

# Cloudinary
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret

# Email (Nodemailer)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password
```

### Flutter

Update `ecommerce/lib/utils/api.dart`:

```dart
// For production, use your deployed backend URL
const String API_BASE = 'https://your-backend-url.com/api/v1';
```

Or use environment variables with `flutter_dotenv`:

1. Create `.env` in `ecommerce`:
   ```env
   API_BASE=https://your-backend-url.com/api/v1
   ```

2. Load in code:
   ```dart
   await dotenv.load(fileName: ".env");
   final apiBase = dotenv.env['API_BASE'] ?? 'http://localhost:5000/api/v1';
   ```

---

## Post-Deployment Checklist

### Backend
- [ ] MongoDB connection working
- [ ] Environment variables set correctly
- [ ] CORS configured for frontend domain
- [ ] API endpoints accessible
- [ ] Payment gateway configured
- [ ] Email service working

### Flutter
- [ ] API base URL updated to production backend
- [ ] Web app builds successfully
- [ ] Android app signed and ready
- [ ] iOS app configured with proper certificates
- [ ] All features tested on deployed version

---

## Troubleshooting

### Backend Issues

**Port already in use:**
- Use `process.env.PORT` (platforms set this automatically)

**CORS errors:**
- Update CORS origin to your frontend domain
- In `server.js`, change `origin: "*"` to your frontend URL

**Database connection fails:**
- Check MongoDB connection string
- Ensure IP whitelist includes deployment platform IPs
- Verify credentials

### Flutter Issues

**API calls fail:**
- Check API base URL
- Verify CORS settings on backend
- Check network permissions in Android/iOS

**Build fails:**
- Run `flutter clean`
- Run `flutter pub get`
- Check for missing dependencies

---

## Quick Deploy Commands

### Backend (Railway)
```bash
# Just push to GitHub, Railway auto-deploys
git add .
git commit -m "Deploy to production"
git push origin main
```

### Flutter Web (Firebase)
```bash
cd ecommerce
flutter build web --release
firebase deploy --only hosting
```

### Flutter Android
```bash
cd ecommerce
flutter build appbundle --release
# Upload build/app/outputs/bundle/release/app-release.aab to Play Store
```

