#!/bin/bash

echo "🔧 使用手动签名重新Archive..."
echo ""

# 1. 清理
echo "1️⃣ 清理..."
rm -rf ./build
xcodebuild clean -project 锚点.xcodeproj -scheme "锚点 US" -configuration Release
echo "   ✅ 完成"
echo ""

# 2. 先让Xcode生成Provisioning Profile
echo "2️⃣ 生成Provisioning Profile..."
echo "   正在构建以触发Profile生成..."

xcodebuild build \
  -project 锚点.xcodeproj \
  -scheme "锚点 US" \
  -configuration Release \
  -sdk iphoneos \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM=FX2M56Q5GV \
  -allowProvisioningUpdates \
  -allowProvisioningDeviceRegistration

echo ""
echo "3️⃣ 检查生成的Provisioning Profiles..."
ls -la ~/Library/MobileDevice/Provisioning\ Profiles/ | tail -5

echo ""
echo "4️⃣ 现在尝试Archive..."

# 使用自动签名，但明确指定要Distribution
xcodebuild archive \
  -project 锚点.xcodeproj \
  -scheme "锚点 US" \
  -configuration Release \
  -archivePath "./build/Lumea.xcarchive" \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM=FX2M56Q5GV \
  -allowProvisioningUpdates \
  -allowProvisioningDeviceRegistration

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Archive成功！"
    echo ""
    echo "现在在Xcode中："
    echo "1. Window → Organizer"
    echo "2. 选择新的Archive"
    echo "3. 点击 'Distribute App'"
    echo "4. 选择 'App Store Connect'"
    echo "5. 选择 'Upload'"
    echo ""
    echo "这次应该会自动生成正确的Distribution Profile"
else
    echo ""
    echo "❌ Archive失败"
fi
