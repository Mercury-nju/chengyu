# Building Lumea (US Version) - Quick Guide

## 🎯 Overview

This guide shows you how to build and test the US version of the app (Lumea) with English localization.

## 🔧 Build Configuration

### Xcode Scheme: `锚点-US`

The US version uses a separate build scheme with the `US_VERSION` compiler flag enabled.

### Key Differences from CN Version

| Feature | CN Version (澄域) | US Version (Lumea) |
|---------|------------------|-------------------|
| App Name | 澄域 | Lumea |
| Bundle ID | com.mercury.serenity.cn | com.mercury.serenity.us |
| Language | Chinese | English |
| Compiler Flag | (none) | US_VERSION |
| Sign-in | Apple + WeChat | Apple + Google |

## 🚀 Building the US Version

### Option 1: Xcode GUI

1. Open `锚点.xcodeproj` in Xcode
2. Select scheme: **锚点-US** (top toolbar)
3. Select target device: iPhone 15 Pro Max (or any iPhone)
4. Press **⌘R** to build and run

### Option 2: Command Line

```bash
# Build for simulator
xcodebuild -project 锚点.xcodeproj \
  -scheme 锚点-US \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro Max' \
  build

# Run on simulator
open -a Simulator
xcrun simctl install booted <path-to-app>
xcrun simctl launch booted com.mercury.serenity.us
```

### Option 3: Archive for App Store

```bash
# Archive
xcodebuild -project 锚点.xcodeproj \
  -scheme 锚点-US \
  -configuration Release \
  -archivePath ./build/Lumea.xcarchive \
  archive

# Export IPA
xcodebuild -exportArchive \
  -archivePath ./build/Lumea.xcarchive \
  -exportPath ./build \
  -exportOptionsPlist ExportOptions.plist
```

## ✅ Testing Checklist

### 1. Launch & Onboarding
- [ ] App name shows "Lumea" on home screen
- [ ] Splash screen displays correctly
- [ ] Onboarding text is in English
- [ ] All 4 onboarding scenes display properly
- [ ] "Grant Access" button works
- [ ] "Let's Begin!" button completes onboarding

### 2. Main Interface
- [ ] Tab bar labels: Calm, Status, Rehab, Profile
- [ ] Sphere displays with correct material
- [ ] Stability score shows
- [ ] Cognitive Load Index displays

### 3. Serenity Guide
- [ ] All 5 guide steps show English text
- [ ] "Tap to continue" / "Tap to begin" hints work
- [ ] Guide dismisses properly

### 4. Practice Sessions

**Touch Anchor:**
- [ ] Instructions in English
- [ ] Session completes successfully

**Flow Forging (Particle Fusion):**
- [ ] "Hold screen and move to attract particles" instruction
- [ ] "Stability Crystal · Forged" completion message
- [ ] "Tap crystal to merge with calm" hint

**Deep Reading:**
- [ ] English Stoic philosophy sample text
- [ ] "Hold and slide to read line by line" instruction
- [ ] Reading completion works

**Emotion Photolysis:**
- [ ] "Tap below to release emotions" instruction
- [ ] "Name this shadow core" prompt
- [ ] "Start Photolysis" button
- [ ] "Return to Calm" completion

### 5. Settings & Profile
- [ ] All settings labels in English
- [ ] Help & Feedback page
- [ ] Subscription page shows "Lumea Premium"
- [ ] Material picker shows English names

### 6. Sign-In
- [ ] "Sign in with Apple" button
- [ ] "Sign in with Google" button (not WeChat)
- [ ] Login flow works

## 🐛 Common Issues

### Issue: App still shows Chinese text

**Solution**: Make sure you're running the `锚点-US` scheme, not `锚点-CN` or `锚点`.

Check in Xcode:
1. Product → Scheme → Manage Schemes
2. Verify `锚点-US` has `US_VERSION` in Build Settings → Swift Compiler Flags

### Issue: Build fails with "GoogleSignIn not found"

**Solution**: Install Google Sign-In SDK:

```bash
# Using CocoaPods
pod install

# Or using Swift Package Manager (already configured)
# Just clean and rebuild
```

### Issue: Simulator shows wrong language

**Solution**: 
1. Open Settings app in Simulator
2. General → Language & Region
3. Set to "English (United States)"
4. Restart app

## 📸 Taking Screenshots for App Store

### Required Sizes

1. **iPhone 6.7" (iPhone 15 Pro Max)**: 1290 x 2796 px
2. **iPhone 6.5" (iPhone 14 Plus)**: 1284 x 2778 px

### Recommended Screens to Capture

1. **Main Sphere View** - Show the fluid sphere with high stability
2. **Practice Cards** - Display all 4 practice options
3. **Flow Forging** - Particle fusion in action
4. **Deep Reading** - Spotlight reading mode
5. **Stats/Insights** - Show progress charts
6. **Subscription** - Premium features list

### How to Capture

```bash
# Method 1: Simulator (⌘S)
1. Run app on iPhone 15 Pro Max simulator
2. Navigate to desired screen
3. Press ⌘S to save screenshot to Desktop

# Method 2: xcrun
xcrun simctl io booted screenshot screenshot.png

# Method 3: Real device
1. Connect iPhone
2. Use Xcode → Window → Devices and Simulators
3. Select device → Take Screenshot
```

## 🌐 Website Deployment (Vercel)

### Prerequisites
- GitHub account
- Vercel account (free)
- Domain `chengyu.space` configured

### Steps

1. **Push website to GitHub**
   ```bash
   cd website
   git init
   git add .
   git commit -m "Initial website"
   git remote add origin <your-repo-url>
   git push -u origin main
   ```

2. **Deploy to Vercel**
   - Go to vercel.com
   - Click "New Project"
   - Import your GitHub repo
   - Set root directory to `website`
   - Deploy

3. **Configure Domain**
   - In Vercel project settings
   - Domains → Add `chengyu.space`
   - Update DNS records as instructed

4. **Verify URLs**
   - https://chengyu.space
   - https://chengyu.space/privacy.html
   - https://chengyu.space/terms.html

## 📦 App Store Submission

### 1. Prepare Build

```bash
# Archive in Xcode
Product → Archive

# Or command line
xcodebuild -scheme 锚点-US -archivePath ./Lumea.xcarchive archive
```

### 2. Upload to App Store Connect

1. Open Xcode → Window → Organizer
2. Select your archive
3. Click "Distribute App"
4. Choose "App Store Connect"
5. Upload

### 3. Fill Metadata

- App Name: **Lumea**
- Subtitle: **Mindfulness & Mental Wellness**
- Description: (see `US_APP_STORE_CHECKLIST.md`)
- Keywords: meditation, mindfulness, mental health, calm, focus
- Privacy URL: https://chengyu.space/privacy.html
- Support URL: https://chengyu.space

### 4. Submit for Review

- Select your uploaded build
- Answer App Privacy questions
- Submit

## 🎉 Success Criteria

Your US version is ready when:

- ✅ All text displays in English
- ✅ App name is "Lumea"
- ✅ Google Sign-In works (not WeChat)
- ✅ All 4 practices complete successfully
- ✅ No Chinese text visible anywhere
- ✅ Website is live at chengyu.space
- ✅ Build uploads to App Store Connect
- ✅ Screenshots captured and ready

## 📞 Need Help?

If you encounter issues:

1. Check `LUMEA_LOCALIZATION_STATUS.md` for localization details
2. Review `US_APP_STORE_CHECKLIST.md` for submission requirements
3. Verify compiler flags in Build Settings
4. Clean build folder (⌘⇧K) and rebuild

---

**Good luck with your US launch! 🚀**
