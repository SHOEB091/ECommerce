# 📱 APK Build Guide - Complete Summary

## 🎯 Your Goal

**Deploy backend → Build APK → Install on phone**

---

## 📖 Which Guide to Use?

| Guide | When to Use | Time |
|-------|-------------|------|
| **`START_HERE.md`** | First time, need overview | 2 min read |
| **`QUICK_APK_BUILD.md`** | You know what you're doing | 5 min |
| **`STEP_BY_STEP_APK.md`** | First time, need detailed steps | 30 min |
| **`COMPLETE_APK_GUIDE.md`** | Need troubleshooting help | Full reference |

---

## ⚡ Super Quick Version

### 1. Deploy Backend
- Railway.app → New Project → GitHub repo
- Add MongoDB
- Set: `MONGODB_URI`, `JWT_SECRET`, `NODE_ENV=production`
- Get URL: `https://your-app.railway.app`

### 2. Update Flutter
```dart
// ecommerce/lib/utils/api.dart
const String API_BASE = 'https://your-app.railway.app/api/v1';
```

### 3. Build APK
```bash
cd ecommerce
flutter build apk --release
```

### 4. Install
- Find APK: `build/app/outputs/flutter-apk/app-release.apk`
- Transfer to phone → Install → Done!

---

## 📋 Complete Checklist

### ✅ Backend (Railway)
- [ ] Account created
- [ ] Project deployed from GitHub
- [ ] MongoDB added
- [ ] Variables set:
  - [ ] MONGODB_URI
  - [ ] JWT_SECRET (32+ chars)
  - [ ] NODE_ENV=production
- [ ] Domain generated
- [ ] Backend URL saved
- [ ] Backend tested (opens in browser)

### ✅ Flutter
- [ ] API URL updated (`api.dart`)
- [ ] Cart service updated (`main.dart`)
- [ ] Changes saved

### ✅ Build
- [ ] `flutter clean` run
- [ ] `flutter pub get` run
- [ ] `flutter build apk --release` successful
- [ ] APK file exists

### ✅ Install
- [ ] APK transferred to phone
- [ ] Unknown sources enabled
- [ ] APK installed
- [ ] App tested

---

## 🔧 Helper Scripts

### Update API URL Automatically

**Windows:**
```bash
update-api-url.bat https://your-app.railway.app
```

**Mac/Linux:**
```bash
chmod +x update-api-url.sh
./update-api-url.sh https://your-app.railway.app
```

---

## 🆘 Troubleshooting

### Backend Issues

**Not deploying:**
- Check Railway logs
- Verify all environment variables
- Check MongoDB connection string

**Can't access:**
- Verify domain is generated
- Check if service is running
- Test in browser first

### Flutter Issues

**Build fails:**
```bash
flutter clean
flutter pub get
flutter doctor
flutter build apk --release
```

**Can't find APK:**
- Check: `ecommerce/build/app/outputs/flutter-apk/app-release.apk`
- Make sure build completed successfully

### Connection Issues

**App can't connect:**
1. Verify API URL is correct
2. Check backend is running (test in browser)
3. Make sure using HTTPS (not HTTP)
4. Check CORS settings in backend

---

## 📱 APK Locations

**Release APK:**
```
ecommerce/build/app/outputs/flutter-apk/app-release.apk
```

**Debug APK:**
```
ecommerce/build/app/outputs/flutter-apk/app-debug.apk
```

**App Bundle (for Play Store):**
```
ecommerce/build/app/outputs/bundle/release/app-release.aab
```

---

## 🎓 Learning Path

1. **Beginner?** Start with `STEP_BY_STEP_APK.md`
2. **Experienced?** Use `QUICK_APK_BUILD.md`
3. **Stuck?** Check `COMPLETE_APK_GUIDE.md` troubleshooting

---

## ✅ Success Indicators

- ✅ Backend URL works in browser
- ✅ APK builds without errors
- ✅ APK installs on phone
- ✅ App connects to backend
- ✅ Can sign up/login
- ✅ Can browse products
- ✅ Can add to cart

---

## 📞 Quick Commands Reference

```bash
# Check Flutter setup
flutter doctor

# Clean and rebuild
flutter clean && flutter pub get

# Build APK
flutter build apk --release

# Build debug APK (faster, larger)
flutter build apk --debug

# Build for Play Store
flutter build appbundle --release
```

---

## 🎉 You're Ready!

**Start with:** `STEP_BY_STEP_APK.md`

**Good luck! 🚀**

