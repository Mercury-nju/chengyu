#!/bin/bash

echo "🔧 修复GoogleUtilities权限并Archive..."
echo ""

# GoogleUtilities包的路径
GOOGLE_UTILS_PATH="$HOME/Library/Developer/Xcode/DerivedData/锚点-cympwpqvhglgcickzfmvfzausole/SourcePackages/checkouts/GoogleUtilities"

# 修复权限
echo "1️⃣ 修复文件权限..."
if [ -d "$GOOGLE_UTILS_PATH" ]; then
    chmod -R u+w "$GOOGLE_UTILS_PATH/GoogleUtilities/UserDefaults/Resources/" 2>/dev/null
    chmod -R u+w "$GOOGLE_UTILS_PATH/GoogleUtilities/Logger/Resources/" 2>/dev/null
    chmod -R u+w "$GOOGLE_UTILS_PATH/GoogleUtilities/Environment/Resources/" 2>/dev/null
    echo "   ✅ 权限已修复"
else
    echo "   ⚠️  GoogleUtilities路径不存在"
fi
echo ""

# 清理
echo "2️⃣ 清理Build文件..."
rm -rf ~/Library/Developer/Xcode/DerivedData/锚点-cympwpqvhglgcickzfmvfzausole/Build
xcodebuild clean -project 锚点.xcodeproj -scheme "锚点 US" -configuration Release
echo "   ✅ 完成"
echo ""

# Archive
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
