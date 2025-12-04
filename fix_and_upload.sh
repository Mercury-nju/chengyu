#!/bin/bash

echo "🔧 修复签名并上传到App Store..."
echo ""

# 1. 删除旧的Provisioning Profiles
echo "1️⃣ 清理旧的Provisioning Profiles..."
rm -rf ~/Library/MobileDevice/Provisioning\ Profiles/*
echo "   ✅ 完成"
echo ""

# 2. 重新Archive（这次会生成新的Profile）
echo "2️⃣ 重新Archive（生成新的Provisioning Profile）..."
rm -rf ./build/Lumea.xcarchive
xcodebuild clean -project 锚点.xcodeproj -scheme "锚点 US" -configuration Release

xcodebuild archive \
  -project 锚点.xcodeproj \
  -scheme "锚点 US" \
  -configuration Release \
  -archivePath "./build/Lumea.xcarchive" \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM=FX2M56Q5GV \
  -allowProvisioningUpdates

if [ $? -ne 0 ]; then
    echo "❌ Archive失败"
    exit 1
fi

echo "   ✅ Archive成功"
echo ""

# 3. 导出并上传
echo "3️⃣ 导出并上传到App Store Connect..."

# 创建ExportOptions.plist（使用app-store-connect）
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
    <key>destination</key>
    <string>upload</string>
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

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 上传成功！"
    echo ""
    echo "📱 下一步："
    echo "1. 访问 https://appstoreconnect.apple.com"
    echo "2. 进入 '我的App' → 'Lumea'"
    echo "3. 等待构建版本处理完成（通常5-10分钟）"
    echo "4. 在 'TestFlight' 或 '准备提交' 中选择构建版本"
    echo "5. 提交审核"
else
    echo ""
    echo "❌ 导出/上传失败"
    echo ""
    echo "请查看错误日志"
fi
