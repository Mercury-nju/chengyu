#!/bin/bash

echo "📦 准备上传到App Store Connect..."
echo ""

# 检查Archive是否存在
ARCHIVE_PATH="./build/Lumea.xcarchive"
if [ ! -d "$ARCHIVE_PATH" ]; then
    echo "❌ Archive不存在: $ARCHIVE_PATH"
    exit 1
fi

echo "✅ 找到Archive: $ARCHIVE_PATH"
echo ""

# 导出IPA
echo "1️⃣ 导出IPA..."
EXPORT_PATH="./build/export"
mkdir -p "$EXPORT_PATH"

# 创建ExportOptions.plist
cat > ./build/ExportOptions.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
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

echo "   创建ExportOptions.plist..."
echo ""

# 导出Archive
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist ./build/ExportOptions.plist \
  -allowProvisioningUpdates

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ IPA导出成功！"
    echo "📦 IPA位置: $EXPORT_PATH"
    echo ""
    
    # 查找IPA文件
    IPA_FILE=$(find "$EXPORT_PATH" -name "*.ipa" | head -n 1)
    
    if [ -n "$IPA_FILE" ]; then
        echo "📱 IPA文件: $IPA_FILE"
        echo ""
        echo "🚀 上传已完成！"
        echo ""
        echo "注意："
        echo "- 使用 -exportArchive 的 destination=upload 选项会自动上传到App Store Connect"
        echo "- 你可以在 https://appstoreconnect.apple.com 查看上传状态"
        echo "- 处理可能需要几分钟时间"
        echo ""
        echo "下一步："
        echo "1. 访问 App Store Connect"
        echo "2. 进入 '我的App' → 'Lumea'"
        echo "3. 等待构建版本出现在 'TestFlight' 或 '准备提交' 中"
        echo "4. 选择构建版本并提交审核"
    else
        echo "⚠️  未找到IPA文件"
    fi
else
    echo ""
    echo "❌ 导出失败"
    echo ""
    echo "可能的原因："
    echo "1. 证书或Provisioning Profile问题"
    echo "2. 需要在Xcode中登录Apple ID"
    echo ""
    echo "建议："
    echo "1. 打开Xcode → Preferences → Accounts"
    echo "2. 确认已登录Apple ID"
    echo "3. 重新运行此脚本"
fi
