# 🚀 START HERE: Deploy Backend + Build APK

**Quick Navigation:**
- ⚡ **Fastest way?** → `QUICK_APK_BUILD.md` (5 minutes)
- 📖 **Detailed guide?** → `STEP_BY_STEP_APK.md` (complete walkthrough)
- 📱 **Full documentation?** → `COMPLETE_APK_GUIDE.md` (everything)

---

## 🎯 What You'll Do

```
GitHub Repo → Deploy Backend → Update Flutter → Build APK → Install & Test
```

---

## ⚡ Quick Start (Copy-Paste Commands)

### 1. Deploy Backend (Railway)
1. Go to [railway.app](https://railway.app) → Sign up with GitHub
2. New Project → Deploy from GitHub → Select your repo
3. Add MongoDB: New → Database → MongoDB
4. Set Variables:
   - `MONGODB_URI` = `mongodb://mongo:27017/railway`
   - `JWT_SECRET` = `any-32-character-secret-key`
   - `NODE_ENV` = `production`
5. Get URL: Settings → Generate Domain

### 2. Update Flutter
```bash
# Edit ecommerce/lib/utils/api.dart
# Change: const String API_BASE = 'https://your-app.railway.app/api/v1';
```

### 3. Build APK
```bash
cd ecommerce
flutter clean
flutter pub get
flutter build apk --release
```

### 4. Install
- APK location: `build/app/outputs/flutter-apk/app-release.apk`
- Transfer to phone → Install → Test!

---

## 📋 Step-by-Step Checklist

### Backend Deployment
- [ ] Railway account created
- [ ] Project created from GitHub
- [ ] MongoDB database added
- [ ] Environment variables set:
  - [ ] MONGODB_URI
  - [ ] JWT_SECRET
  - [ ] NODE_ENV=production
- [ ] Backend URL obtained
- [ ] Backend tested (opens in browser)

### Flutter Updates
- [ ] API URL updated in `api.dart`
- [ ] Cart service updated in `main.dart`
- [ ] Changes committed to git

### APK Build
- [ ] Flutter doctor passes
- [ ] Dependencies installed (`flutter pub get`)
- [ ] APK built successfully
- [ ] APK file found in `build/app/outputs/flutter-apk/`

### Installation & Testing
- [ ] APK transferred to phone
- [ ] Unknown sources enabled
- [ ] APK installed
- [ ] App opens
- [ ] App connects to backend
- [ ] Can sign up/login
- [ ] Can browse products

---

## 🆘 Common Issues & Fixes

| Problem | Solution |
|---------|----------|
| Backend won't deploy | Check Railway logs, verify environment variables |
| APK won't build | Run `flutter clean && flutter pub get` |
| App can't connect | Verify API URL, check backend is running |
| APK won't install | Enable "Unknown sources", uninstall old version |

---

## 📚 Documentation Files

- **`QUICK_APK_BUILD.md`** - Fastest way (5 min)
- **`STEP_BY_STEP_APK.md`** - Complete walkthrough
- **`COMPLETE_APK_GUIDE.md`** - Full documentation
- **`DEPLOYMENT.md`** - General deployment guide
- **`DEPLOY_QUICK_START.md`** - Quick deployment reference

---

## 🎯 Recommended Path

1. **First time?** → Read `STEP_BY_STEP_APK.md`
2. **Need quick reference?** → Use `QUICK_APK_BUILD.md`
3. **Having issues?** → Check `COMPLETE_APK_GUIDE.md` troubleshooting

---

## ✅ Success Looks Like

- ✅ Backend URL: `https://your-app.railway.app` (works in browser)
- ✅ APK built: `app-release.apk` (in build folder)
- ✅ App installed on phone
- ✅ App connects to backend
- ✅ Can use all features

---

**Ready? Start with `STEP_BY_STEP_APK.md`! 🚀**

