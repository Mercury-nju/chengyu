#!/bin/bash

echo "🧹 清理 Xcode 缓存和构建文件..."

# 1. Clean build folder
echo "1️⃣ 清理构建文件夹..."
xcodebuild clean -project 锚点.xcodeproj -scheme "锚点 US" 2>/dev/null

# 2. 删除派生数据
echo "2️⃣ 删除派生数据..."
rm -rf ~/Library/Developer/Xcode/DerivedData/

# 3. 删除 Xcode 缓存
echo "3️⃣ 删除 Xcode 缓存..."
rm -rf ~/Library/Caches/com.apple.dt.Xcode/

# 4. 删除模块缓存
echo "4️⃣ 删除模块缓存..."
rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex/

echo ""
echo "✅ 清理完成！"
echo ""
echo "现在请："
echo "1. 在 Xcode 中按 ⌘⇧K (Product → Clean Build Folder)"
echo "2. 按 ⌘B (Product → Build)"
echo "3. 按 ⌘R (Product → Run)"
echo ""
echo "如果还有错误，请关闭 Xcode 后重新打开。"
