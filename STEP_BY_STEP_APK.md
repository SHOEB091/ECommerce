# 📱 Step-by-Step: Deploy Backend + Build APK

Complete walkthrough from GitHub repo to working APK.

---

## 🎯 Goal

Deploy backend → Update Flutter → Build APK → Install & Test

---

## Part 1: Deploy Backend (15 minutes)

### Step 1: Sign Up for Railway

1. Open browser → Go to [railway.app](https://railway.app)
2. Click **"Login"** or **"Start a New Project"**
3. Click **"Login with GitHub"**
4. Authorize Railway to access your GitHub account
5. ✅ You're in Railway dashboard!

### Step 2: Create New Project

1. Click **"New Project"** (big button)
2. Select **"Deploy from GitHub repo"**
3. You'll see your GitHub repositories
4. **Find and click** your ECommerce repository
5. Railway will start deploying automatically

**Wait 2-3 minutes** for deployment to complete.

### Step 3: Add MongoDB Database

1. In your Railway project, you'll see your backend service
2. Click **"New"** button (top right)
3. Click **"Database"**
4. Select **"MongoDB"**
5. Railway creates MongoDB for you
6. **Copy the connection string** (click to copy)
   - It looks like: `mongodb://mongo:27017` or `mongodb://mongo:27017/railway`

### Step 4: Configure Environment Variables

1. Click on your **backend service** (the one that's not MongoDB)
2. Click **"Variables"** tab
3. Click **"New Variable"** button
4. Add these variables one by one:

**Variable 1:**
- Key: `MONGODB_URI`
- Value: `mongodb://mongo:27017/railway` (use the one Railway gave you)
- Click **"Add"**

**Variable 2:**
- Key: `JWT_SECRET`
- Value: `my-super-secret-jwt-key-12345678901234567890` (any 32+ character string)
- Click **"Add"**

**Variable 3:**
- Key: `NODE_ENV`
- Value: `production`
- Click **"Add"**

**Variable 4:**
- Key: `PORT`
- Value: `5000`
- Click **"Add"**

**Optional Variables** (add if you have them):
- `RAZORPAY_KEY_ID` = your Razorpay key
- `RAZORPAY_KEY_SECRET` = your Razorpay secret
- `CLOUDINARY_CLOUD_NAME` = your Cloudinary name
- `CLOUDINARY_API_KEY` = your Cloudinary key
- `CLOUDINARY_API_SECRET` = your Cloudinary secret

### Step 5: Get Your Backend URL

1. Click on your **backend service**
2. Click **"Settings"** tab
3. Scroll down to **"Domains"** section
4. Click **"Generate Domain"** button
5. Railway generates a URL like: `https://your-app-name.railway.app`
6. **Copy this URL** - you'll need it!

### Step 6: Test Your Backend

1. Open a new browser tab
2. Paste your Railway URL: `https://your-app-name.railway.app`
3. You should see: `{"message":"Route not found"}` ✅ (This is normal!)
4. Test an API endpoint: `https://your-app-name.railway.app/api/v1/auth/me`
5. Should return an error (normal - means API is working!)

✅ **Backend is live!**

---

## Part 2: Update Flutter App (5 minutes)

### Step 1: Open Your Project

```bash
# If you don't have it locally:
git clone https://github.com/your-username/your-repo-name.git
cd your-repo-name

# If you already have it:
cd your-repo-name
git pull origin main
```

### Step 2: Update API URL (Method 1 - Manual)

1. Open file: `ecommerce/lib/utils/api.dart`
2. Find this line (around line 6):
   ```dart
   const String API_BASE = 'http://localhost:5000/api/v1';
   ```
3. Replace with your Railway URL:
   ```dart
   const String API_BASE = 'https://your-app-name.railway.app/api/v1';
   ```
   *(Use the URL you copied from Railway)*
4. Save the file

### Step 2: Update API URL (Method 2 - Script)

**Windows:**
```bash
update-api-url.bat https://your-app-name.railway.app
```

**Mac/Linux:**
```bash
chmod +x update-api-url.sh
./update-api-url.sh https://your-app-name.railway.app
```

### Step 3: Update Cart Service

1. Open file: `ecommerce/lib/main.dart`
2. Find this section (around line 43):
   ```dart
   CartService.instance.configure(
     apiPrefix: '/api/v1',
     port: 5000,
     host: 'localhost',
   );
   ```
3. Replace with:
   ```dart
   CartService.instance.configure(
     apiPrefix: '/api/v1',
     port: 443,
     host: 'your-app-name.railway.app',  // Without https://
     useHttps: true,
   );
   ```
4. Save the file

### Step 4: Commit Changes

```bash
git add ecommerce/lib/utils/api.dart ecommerce/lib/main.dart
git commit -m "Update API URL for production backend"
git push origin main
```

---

## Part 3: Build APK (10 minutes)

### Step 1: Navigate to Flutter Project

```bash
cd ecommerce
```

### Step 2: Check Flutter Setup

```bash
flutter doctor
```

Make sure you see:
- ✅ Flutter (Channel stable)
- ✅ Android toolchain
- ✅ Android Studio (optional but recommended)

### Step 3: Clean and Get Dependencies

```bash
flutter clean
flutter pub get
```

### Step 4: Build Release APK

```bash
flutter build apk --release
```

**This will take 2-5 minutes.** Be patient!

### Step 5: Find Your APK

After build completes, your APK is at:
```
ecommerce/build/app/outputs/flutter-apk/app-release.apk
```

✅ **APK is ready!**

---

## Part 4: Install APK on Phone (5 minutes)

### Step 1: Transfer APK to Phone

**Option A: USB Cable**
1. Connect phone to computer via USB
2. Enable "File Transfer" mode on phone
3. Copy `app-release.apk` to phone's Download folder
4. Disconnect phone

**Option B: Email**
1. Email the APK file to yourself
2. Open email on phone
3. Download the APK attachment

**Option C: Cloud Storage**
1. Upload APK to Google Drive/Dropbox
2. Download on phone

### Step 2: Enable Unknown Sources

1. On your Android phone:
   - Go to **Settings**
   - Go to **Security** (or **Apps** → **Special access**)
   - Find **"Install unknown apps"** or **"Unknown sources"**
   - Enable it for your file manager/email app

### Step 3: Install APK

1. Open **File Manager** on phone
2. Navigate to **Downloads** folder
3. Tap on **app-release.apk**
4. Tap **"Install"**
5. Wait for installation
6. Tap **"Open"** when done

✅ **App is installed!**

---

## Part 5: Test the App

### Test Checklist

1. **Open the app** ✅
2. **Try to sign up** - Create a new account
3. **Try to login** - Use your credentials
4. **Browse products** - Check if products load
5. **Add to cart** - Add some items
6. **Checkout** - Try to make a purchase (if payment is configured)

### If Something Doesn't Work

**App won't connect to backend:**
- Check API URL is correct in `api.dart`
- Verify backend is running (check Railway)
- Make sure you're using HTTPS (not HTTP)

**Backend errors:**
- Check Railway logs: Service → Deployments → View Logs
- Verify environment variables are set
- Check MongoDB connection

**APK won't install:**
- Uninstall old version first
- Make sure "Unknown sources" is enabled
- Try building debug APK: `flutter build apk --debug`

---

## ✅ Success Checklist

- [ ] Backend deployed on Railway
- [ ] MongoDB connected
- [ ] Environment variables set
- [ ] Backend URL obtained
- [ ] Flutter API URL updated
- [ ] Cart service configured
- [ ] APK built successfully
- [ ] APK installed on phone
- [ ] App opens and connects
- [ ] Can sign up/login
- [ ] Can browse products
- [ ] Can add to cart

---

## 🎉 Congratulations!

You now have:
- ✅ Backend deployed and live
- ✅ APK built and installed
- ✅ App connected to production backend

---

## 📚 Next Steps

1. **Test thoroughly** - Try all features
2. **Build signed APK** - For Play Store (see `COMPLETE_APK_GUIDE.md`)
3. **Add analytics** - Track app usage
4. **Set up error tracking** - Catch bugs early
5. **Optimize** - Improve performance

---

## 🆘 Need Help?

**Backend Issues:**
- Railway logs: Service → Deployments → View Logs
- Check environment variables
- Test API in browser

**APK Issues:**
- Run `flutter doctor` to check setup
- Try `flutter clean && flutter pub get`
- Build debug APK first: `flutter build apk --debug`

**Connection Issues:**
- Verify API URL is correct
- Check backend is running
- Test API endpoint in browser

---

**You're all set! 🚀**

