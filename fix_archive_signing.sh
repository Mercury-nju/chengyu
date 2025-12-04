#!/bin/bash

echo "🔧 修复Archive签名问题..."
echo ""

# 1. 清理旧的Provisioning Profiles
echo "1️⃣ 清理旧的Provisioning Profiles..."
rm -rf ~/Library/MobileDevice/Provisioning\ Profiles/*
echo "   ✅ 已清理"
echo ""

# 2. 清理Xcode缓存
echo "2️⃣ 清理Xcode缓存..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*
echo "   ✅ 已清理"
echo ""

# 3. 清理项目Build文件
echo "3️⃣ 清理项目Build文件..."
xcodebuild clean -project 锚点.xcodeproj -scheme "锚点 US" -configuration Release
echo "   ✅ 已清理"
echo ""

# 4. 检查证书
echo "4️⃣ 检查可用的签名证书..."
security find-identity -v -p codesigning | grep "Apple Distribution"
echo ""

# 5. 尝试Archive
echo "5️⃣ 开始Archive..."
echo "   使用自动签名..."
xcodebuild archive \
  -project 锚点.xcodeproj \
  -scheme "锚点 US" \
  -configuration Release \
  -archivePath "./build/Lumea.xcarchive" \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM=FX2M56Q5GV \
  -allowProvisioningUpdates

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Archive成功！"
    echo "📦 Archive位置: ./build/Lumea.xcarchive"
    echo ""
    echo "下一步："
    echo "1. 在Xcode中打开 Window → Organizer"
    echo "2. 选择刚创建的Archive"
    echo "3. 点击 'Distribute App'"
    echo "4. 选择 'App Store Connect'"
else
    echo ""
    echo "❌ Archive失败"
    echo ""
    echo "请尝试以下方法："
    echo "1. 在Xcode中打开项目"
    echo "2. 选择 锚点 US target"
    echo "3. 进入 Signing & Capabilities"
    echo "4. 取消勾选 'Automatically manage signing'"
    echo "5. 重新勾选 'Automatically manage signing'"
    echo "6. 确保Team选择正确"
    echo "7. 再次运行此脚本"
fi
