# Quick Deployment Guide

## 🚀 Fastest Way to Deploy

### Backend (5 minutes - Railway)

1. **Sign up** at [railway.app](https://railway.app) (free tier available)

2. **Deploy from GitHub**:
   - Click "New Project" → "Deploy from GitHub repo"
   - Select your repository
   - Railway auto-detects Node.js

3. **Add MongoDB**:
   - Click "New" → "Database" → "MongoDB"
   - Copy the connection string

4. **Set Environment Variables**:
   - Go to your service → Variables tab
   - Add these variables:
     ```
     MONGODB_URI=<paste-your-mongodb-connection-string>
     JWT_SECRET=<generate-a-random-32-char-string>
     RAZORPAY_KEY_ID=<your-razorpay-key>
     RAZORPAY_KEY_SECRET=<your-razorpay-secret>
     CLOUDINARY_CLOUD_NAME=<your-cloudinary-name>
     CLOUDINARY_API_KEY=<your-cloudinary-key>
     CLOUDINARY_API_SECRET=<your-cloudinary-secret>
     EMAIL_HOST=smtp.gmail.com
     EMAIL_PORT=587
     EMAIL_USER=<your-email>
     EMAIL_PASS=<your-app-password>
     NODE_ENV=production
     FRONTEND_URL=https://your-frontend-url.com
     ```

5. **Get your API URL**:
   - Railway provides a URL like: `https://your-app.railway.app`
   - Copy this URL

### Flutter Web (5 minutes - Firebase Hosting)

1. **Install Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   ```

2. **Login**:
   ```bash
   firebase login
   ```

3. **Initialize Firebase** (in ecommerce directory):
   ```bash
   cd ecommerce
   firebase init hosting
   # Select: Use an existing project or create new
   # Public directory: build/web
   # Single-page app: Yes
   # Overwrite index.html: No
   ```

4. **Update API URL**:
   - Edit `ecommerce/lib/utils/api.dart`
   - Change: `const String API_BASE = 'https://your-backend-url.railway.app/api/v1';`

5. **Build and Deploy**:
   ```bash
   flutter build web --release
   firebase deploy --only hosting
   ```

6. **Your app is live!** 🎉
   - Firebase provides a URL like: `https://your-app.web.app`

---

## 📱 Mobile App Deployment

### Android (Google Play Store)

1. **Generate Keystore**:
   ```bash
   cd ecommerce/android
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Configure `android/key.properties`**:
   ```properties
   storePassword=<your-keystore-password>
   keyPassword=<your-key-password>
   keyAlias=upload
   storeFile=<path-to-keystore>
   ```

3. **Update `android/app/build.gradle.kts`** to use keystore

4. **Build App Bundle**:
   ```bash
   flutter build appbundle --release
   ```

5. **Upload to Play Store**:
   - Go to [Google Play Console](https://play.google.com/console)
   - Create app
   - Upload `build/app/outputs/bundle/release/app-release.aab`

### iOS (App Store)

1. **Open in Xcode**:
   ```bash
   cd ecommerce/ios
   open Runner.xcworkspace
   ```

2. **Configure**:
   - Select your Apple Developer team
   - Set bundle identifier
   - Configure signing

3. **Build and Archive**:
   - In Xcode: Product → Archive
   - Upload to App Store Connect

---

## 🔧 Environment Setup

### MongoDB Atlas (Free)

1. Sign up at [mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas)
2. Create free cluster
3. Create database user
4. Whitelist IP: `0.0.0.0/0` (allow all for now)
5. Get connection string: `mongodb+srv://username:password@cluster.mongodb.net/dbname`

### Razorpay

1. Sign up at [razorpay.com](https://razorpay.com)
2. Get API keys from Dashboard → Settings → API Keys

### Cloudinary

1. Sign up at [cloudinary.com](https://cloudinary.com)
2. Get credentials from Dashboard

### Gmail App Password

1. Go to Google Account → Security
2. Enable 2-Step Verification
3. Generate App Password for "Mail"
4. Use this password in `EMAIL_PASS`

---

## ✅ Post-Deployment Checklist

- [ ] Backend API accessible
- [ ] MongoDB connected
- [ ] Flutter app connects to backend
- [ ] Payment gateway working
- [ ] Email service configured
- [ ] CORS configured correctly
- [ ] Environment variables set
- [ ] SSL/HTTPS enabled (automatic on Railway/Firebase)

---

## 🆘 Common Issues

**CORS Error:**
- Update `FRONTEND_URL` in backend environment variables
- Include your Flutter web URL

**API Connection Failed:**
- Check API base URL in Flutter code
- Verify backend is running
- Check CORS settings

**Build Fails:**
- Run `flutter clean && flutter pub get`
- Check for missing dependencies
- Verify environment variables

---

## 📞 Need Help?

- Check full deployment guide: `DEPLOYMENT.md`
- Railway docs: https://docs.railway.app
- Firebase docs: https://firebase.google.com/docs
- Flutter docs: https://flutter.dev/docs/deployment

