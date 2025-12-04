#!/bin/bash

echo "🔧 修复GoogleUtilities缺失的PrivacyInfo文件..."
echo ""

# GoogleUtilities包的路径
GOOGLE_UTILS_PATH="$HOME/Library/Developer/Xcode/DerivedData/锚点-cympwpqvhglgcickzfmvfzausole/SourcePackages/checkouts/GoogleUtilities"

# 创建缺失的PrivacyInfo.xcprivacy文件
create_privacy_file() {
    local dir=$1
    local file="$dir/PrivacyInfo.xcprivacy"
    
    if [ ! -f "$file" ]; then
        echo "创建: $file"
        mkdir -p "$dir"
        cat > "$file" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
</dict>
</plist>
EOF
    fi
}

# 检查GoogleUtilities是否存在
if [ ! -d "$GOOGLE_UTILS_PATH" ]; then
    echo "⚠️  GoogleUtilities包不存在，需要先构建一次"
    echo "正在执行初始构建..."
    xcodebuild build -project 锚点.xcodeproj -scheme "锚点 US" -configuration Release -sdk iphoneos
fi

# 创建缺失的PrivacyInfo文件
echo "1️⃣ 创建缺失的PrivacyInfo文件..."
create_privacy_file "$GOOGLE_UTILS_PATH/GoogleUtilities/UserDefaults/Resources"
create_privacy_file "$GOOGLE_UTILS_PATH/GoogleUtilities/Logger/Resources"
create_privacy_file "$GOOGLE_UTILS_PATH/GoogleUtilities/Environment/Resources"
echo "   ✅ 完成"
echo ""

# 清理并重新Archive
echo "2️⃣ 清理Build文件..."
xcodebuild clean -project 锚点.xcodeproj -scheme "锚点 US" -configuration Release
echo "   ✅ 完成"
echo ""

echo "3️⃣ 开始Archive..."
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
    echo "请查看上面的错误信息"
fi
