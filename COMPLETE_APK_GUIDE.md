# 📱 Complete Guide: Deploy Backend + Build APK

This guide will walk you through deploying your backend and building an APK that connects to it.

---

## 🎯 What We'll Do

1. ✅ Deploy backend to Railway (free)
2. ✅ Get backend URL
3. ✅ Update Flutter app with backend URL
4. ✅ Build APK
5. ✅ Test the APK

**Time Required:** ~30 minutes

---

## 📋 Prerequisites

- GitHub account (you already have this)
- Railway account (we'll create it)
- MongoDB Atlas account (we'll create it)
- Flutter SDK installed
- Android Studio or Android SDK installed

---

## Step 1: Deploy Backend to Railway (15 minutes)

### 1.1 Create Railway Account

1. Go to [railway.app](https://railway.app)
2. Click **"Start a New Project"**
3. Sign up with GitHub (recommended)
4. Authorize Railway to access your GitHub

### 1.2 Deploy Your Backend

1. In Railway dashboard, click **"New Project"**
2. Select **"Deploy from GitHub repo"**
3. Find and select your **ECommerce repository**
4. Railway will detect it's a Node.js project
5. Click **"Deploy"**

✅ Your backend is now deploying! Wait 2-3 minutes.

### 1.3 Add MongoDB Database

1. In your Railway project, click **"New"**
2. Select **"Database"**
3. Choose **"MongoDB"**
4. Railway will create a MongoDB instance
5. **Copy the connection string** (we'll need it)

**The connection string looks like:**
```
mongodb://mongo:27017
```
or
```
mongodb://mongo:27017/railway
```

### 1.4 Set Environment Variables

1. Click on your **backend service** (not the database)
2. Go to **"Variables"** tab
3. Click **"New Variable"** and add these one by one:

```env
MONGODB_URI=mongodb://mongo:27017/railway
```
*(Use the connection string Railway gave you)*

```env
JWT_SECRET=your-super-secret-jwt-key-minimum-32-characters-long
```
*(Generate a random 32+ character string)*

```env
NODE_ENV=production
```

```env
PORT=5000
```

**For Razorpay (if you have it):**
```env
RAZORPAY_KEY_ID=your-razorpay-key-id
RAZORPAY_KEY_SECRET=your-razorpay-secret
```

**For Cloudinary (if you have it):**
```env
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret
```

**For Email (optional for now):**
```env
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password
```

**For CORS (we'll set this after getting frontend URL):**
```env
FRONTEND_URL=https://your-frontend-url.com
```
*(Leave this for now, we'll update it later)*

### 1.5 Get Your Backend URL

1. In Railway, click on your **backend service**
2. Go to **"Settings"** tab
3. Scroll to **"Domains"**
4. Click **"Generate Domain"**
5. Copy the URL (e.g., `https://your-app.railway.app`)

✅ **Save this URL!** We'll use it in the next step.

### 1.6 Test Your Backend

1. Open the URL in browser: `https://your-app.railway.app`
2. You should see: `{"message":"Route not found"}` (this is normal)
3. Test an endpoint: `https://your-app.railway.app/api/v1/auth/me`
4. Should return an error (normal, means API is working)

✅ **Backend is deployed and working!**

---

## Step 2: Update Flutter App with Backend URL (5 minutes)

### 2.1 Clone/Update Your Repository

If you haven't already:
```bash
git clone https://github.com/your-username/your-repo-name.git
cd your-repo-name
```

Or if you already have it:
```bash
cd your-repo-name
git pull origin main
```

### 2.2 Update API Base URL

1. Open: `ecommerce/lib/utils/api.dart`
2. Find this line:
   ```dart
   const String API_BASE = 'http://localhost:5000/api/v1';
   ```
3. Replace with your Railway URL:
   ```dart
   const String API_BASE = 'https://your-app.railway.app/api/v1';
   ```
   *(Use the URL you got from Railway)*

4. Save the file

### 2.3 Update Cart Service (if needed)

1. Open: `ecommerce/lib/services/cart_service.dart`
2. Find the `configure` method or base URL
3. Update host to match your Railway domain:
   ```dart
   CartService.instance.configure(
     host: 'your-app.railway.app',  // Without https://
     port: 443,  // HTTPS port
     apiPrefix: '/api/v1',
   );
   ```

### 2.4 Commit Changes

```bash
git add ecommerce/lib/utils/api.dart
git commit -m "Update API URL for production"
git push origin main
```

---

## Step 3: Build APK (10 minutes)

### 3.1 Navigate to Flutter Project

```bash
cd ecommerce
```

### 3.2 Clean and Get Dependencies

```bash
flutter clean
flutter pub get
```

### 3.3 Build APK

**For testing (debug APK):**
```bash
flutter build apk --debug
```

**For release (production APK):**
```bash
flutter build apk --release
```

**Recommended: Build release APK**
```bash
flutter build apk --release
```

### 3.4 Find Your APK

After building, your APK will be at:
```
ecommerce/build/app/outputs/flutter-apk/app-release.apk
```

✅ **Your APK is ready!**

---

## Step 4: Install and Test APK

### 4.1 Transfer APK to Phone

**Option 1: USB**
- Connect phone via USB
- Enable USB debugging
- Copy `app-release.apk` to phone
- Install from phone's file manager

**Option 2: Email/Cloud**
- Email the APK to yourself
- Download on phone
- Install

**Option 3: ADB (if you have it set up)**
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 4.2 Install on Phone

1. On your Android phone:
   - Go to Settings → Security
   - Enable "Install from Unknown Sources"
   - Open the APK file
   - Tap "Install"

### 4.3 Test the App

1. Open the app
2. Try to:
   - Sign up / Login
   - Browse products
   - Add to cart
   - Make a payment (if configured)

✅ **If everything works, you're done!**

---

## Step 5: Update CORS (Important!)

### 5.1 Update Backend CORS Settings

1. Go back to Railway
2. Click on your backend service
3. Go to **"Variables"** tab
4. Add or update:
   ```env
   FRONTEND_URL=*
   ```
   *(This allows all origins - for mobile apps)*

5. Railway will automatically redeploy

---

## 🔧 Troubleshooting

### APK won't install

**Error: "App not installed"**
- Check if you have an older version installed (uninstall first)
- Make sure "Install from Unknown Sources" is enabled
- Try building debug APK instead

### App can't connect to backend

**Error: "Connection failed"**
1. Check API URL in `api.dart` is correct
2. Verify backend is running (check Railway logs)
3. Check CORS settings
4. Make sure you're using HTTPS (not HTTP)

**Check Railway logs:**
- Go to Railway → Your service → "Deployments"
- Click on latest deployment → "View Logs"
- Look for errors

### Backend not working

**Check Railway:**
1. Go to your service → "Deployments"
2. Check if deployment is successful (green checkmark)
3. View logs for errors
4. Check environment variables are set correctly

**Common issues:**
- MongoDB connection fails → Check MONGODB_URI
- Port errors → Railway sets PORT automatically, don't override
- Missing dependencies → Check package.json

### Build errors

**Error: "Gradle build failed"**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

**Error: "SDK not found"**
- Open Android Studio
- Go to SDK Manager
- Install Android SDK
- Set ANDROID_HOME environment variable

---

## 📱 Building Signed APK (For Play Store)

If you want to publish to Google Play Store:

### Generate Keystore

```bash
cd ecommerce/android
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Save the passwords!**

### Configure Signing

1. Create `android/key.properties`:
```properties
storePassword=your-keystore-password
keyPassword=your-key-password
keyAlias=upload
storeFile=/Users/yourname/upload-keystore.jks
```

2. Update `android/app/build.gradle.kts` (see `build.gradle.kts.release` file)

### Build App Bundle

```bash
flutter build appbundle --release
```

APK will be at: `build/app/outputs/bundle/release/app-release.aab`

---

## ✅ Checklist

- [ ] Backend deployed on Railway
- [ ] MongoDB connected
- [ ] Environment variables set
- [ ] Backend URL obtained
- [ ] Flutter API URL updated
- [ ] APK built successfully
- [ ] APK installed on phone
- [ ] App connects to backend
- [ ] Features tested

---

## 🎉 You're Done!

Your app is now:
- ✅ Backend deployed and live
- ✅ APK built and ready
- ✅ Connected to production backend

**Next Steps:**
- Test all features thoroughly
- Build signed APK for Play Store
- Consider adding analytics
- Set up error tracking

---

## 📞 Need Help?

**Backend Issues:**
- Check Railway logs
- Verify environment variables
- Test API endpoints in browser

**APK Issues:**
- Check Flutter doctor: `flutter doctor`
- Verify Android SDK installed
- Try building debug APK first

**Connection Issues:**
- Verify API URL is correct
- Check backend is running
- Test API in browser first

---

**Happy Building! 🚀**

