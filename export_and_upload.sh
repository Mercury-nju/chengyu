#!/bin/bash

echo "📦 导出IPA并上传到App Store Connect..."
echo ""

# 1. 导出IPA（不自动上传）
echo "1️⃣ 导出IPA..."

# 创建ExportOptions.plist（export-only）
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
    <key>destination</key>
    <string>export</string>
</dict>
</plist>
EOF

EXPORT_PATH="./build/export"
rm -rf "$EXPORT_PATH"
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
    echo "让我们尝试在Xcode中手动操作："
    echo "1. 打开Xcode"
    echo "2. Window → Organizer"
    echo "3. 选择Archive"
    echo "4. 点击 'Distribute App'"
    echo "5. 选择 'App Store Connect' → 'Upload'"
    exit 1
fi

echo "   ✅ IPA导出成功"
echo ""

# 查找IPA文件
IPA_FILE=$(find "$EXPORT_PATH" -name "*.ipa" | head -n 1)

if [ -z "$IPA_FILE" ]; then
    echo "❌ 未找到IPA文件"
    exit 1
fi

echo "📱 IPA文件: $IPA_FILE"
echo ""

# 2. 上传IPA
echo "2️⃣ 上传到App Store Connect..."
echo ""
echo "⚠️  需要Apple ID和App-Specific Password"
echo ""

read -p "请输入你的Apple ID邮箱: " APPLE_ID
echo ""
read -sp "请输入App-Specific Password: " APP_PASSWORD
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
    echo "📱 下一步："
    echo "1. 访问 https://appstoreconnect.apple.com"
    echo "2. 进入 '我的App' → 'Lumea'"
    echo "3. 等待构建版本处理完成（5-10分钟）"
    echo "4. 在 'TestFlight' 或 '准备提交' 中选择构建版本"
    echo "5. 提交审核"
else
    echo ""
    echo "❌ 上传失败"
    echo ""
    echo "请检查："
    echo "1. Apple ID是否正确"
    echo "2. App-Specific Password是否正确"
    echo "3. 网络连接是否正常"
fi
