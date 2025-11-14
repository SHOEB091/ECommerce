# ⚡ Quick APK Build Guide

Fastest way to build APK with deployed backend.

## 🚀 5-Minute Version

### 1. Deploy Backend (Railway)

1. Go to [railway.app](https://railway.app) → Sign up with GitHub
2. New Project → Deploy from GitHub → Select your repo
3. Add MongoDB: New → Database → MongoDB
4. Set Variables:
   ```
   MONGODB_URI=mongodb://mongo:27017/railway
   JWT_SECRET=your-32-char-secret
   NODE_ENV=production
   ```
5. Get URL: Settings → Generate Domain → Copy URL

### 2. Update Flutter

Edit `ecommerce/lib/utils/api.dart`:
```dart
const String API_BASE = 'https://your-app.railway.app/api/v1';
```

### 3. Build APK

```bash
cd ecommerce
flutter clean
flutter pub get
flutter build apk --release
```

### 4. Install

APK location: `build/app/outputs/flutter-apk/app-release.apk`

Transfer to phone and install!

---

## 📝 Detailed Steps

See `COMPLETE_APK_GUIDE.md` for full instructions.

---

## 🔧 Common Commands

```bash
# Build debug APK (faster, larger)
flutter build apk --debug

# Build release APK (optimized, smaller)
flutter build apk --release

# Check Flutter setup
flutter doctor

# Clean build
flutter clean && flutter pub get
```

---

## ✅ Quick Checklist

- [ ] Backend URL: `https://your-app.railway.app`
- [ ] API URL updated in `api.dart`
- [ ] APK built: `app-release.apk`
- [ ] Installed on phone
- [ ] App connects to backend

---

**That's it! 🎉**

