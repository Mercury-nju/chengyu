#!/bin/bash

echo "🔧 使用Distribution证书重新Archive..."
echo ""

# 1. 清理
echo "1️⃣ 清理..."
rm -rf ~/Library/MobileDevice/Provisioning\ Profiles/*
rm -rf ./build
xcodebuild clean -project 锚点.xcodeproj -scheme "锚点 US" -configuration Release
echo "   ✅ 完成"
echo ""

# 2. Archive（明确指定Distribution）
echo "2️⃣ Archive（使用Distribution证书）..."
xcodebuild archive \
  -project 锚点.xcodeproj \
  -scheme "锚点 US" \
  -configuration Release \
  -archivePath "./build/Lumea.xcarchive" \
  CODE_SIGN_STYLE=Automatic \
  CODE_SIGN_IDENTITY="Apple Distribution" \
  DEVELOPMENT_TEAM=FX2M56Q5GV \
  -allowProvisioningUpdates

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Archive失败"
    exit 1
fi

echo "   ✅ Archive成功"
echo ""

# 3. 导出IPA
echo "3️⃣ 导出IPA..."

cat > ./build/ExportOptions.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>teamID</key>
    <string>FX2M56Q5GV</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>signingCertificate</key>
    <string>Apple Distribution</string>
</dict>
</plist>
EOF

EXPORT_PATH="./build/export"
mkdir -p "$EXPORT_PATH"

xcodebuild -exportArchive \
  -archivePath "./build/Lumea.xcarchive" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist ./build/ExportOptions.plist \
  -allowProvisioningUpdates

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ 导出失败"
    echo ""
    echo "建议使用Xcode手动操作："
    echo "1. 打开Xcode"
    echo "2. Window → Organizer"
    echo "3. 选择刚创建的Archive"
    echo "4. 点击 'Distribute App'"
    echo "5. 选择 'App Store Connect' → 'Upload'"
    echo "6. Xcode会自动处理签名"
    exit 1
fi

echo "   ✅ 导出成功"
echo ""

# 查找IPA
IPA_FILE=$(find "$EXPORT_PATH" -name "*.ipa" | head -n 1)

if [ -z "$IPA_FILE" ]; then
    echo "❌ 未找到IPA文件"
    exit 1
fi

echo "📱 IPA文件: $IPA_FILE"
echo ""

# 4. 上传
echo "4️⃣ 上传到App Store Connect..."
echo ""
echo "需要你的Apple ID凭证"
echo ""

read -p "Apple ID邮箱: " APPLE_ID
echo ""
read -sp "App-Specific Password: " APP_PASSWORD
echo ""
echo ""

echo "正在上传..."
xcrun altool --upload-app \
  -f "$IPA_FILE" \
  -t ios \
  -u "$APPLE_ID" \
  -p "$APP_PASSWORD"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 上传成功！"
    echo ""
    echo "下一步："
    echo "1. 访问 https://appstoreconnect.apple.com"
    echo "2. 等待构建版本处理完成（5-10分钟）"
    echo "3. 提交审核"
else
    echo ""
    echo "❌ 上传失败"
fi
