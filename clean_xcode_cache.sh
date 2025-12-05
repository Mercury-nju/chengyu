#!/bin/bash

echo "🧹 清理 Xcode 缓存..."

# 1. 清理 Derived Data
echo "📁 清理 Derived Data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/锚点-*

# 2. 清理项目的 build 文件夹
echo "📁 清理项目 build 文件夹..."
rm -rf build/

# 3. 清理 Module Cache
echo "📁 清理 Module Cache..."
rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex/

# 4. 清理 Swift Package 缓存
echo "📦 清理 Swift Package 缓存..."
rm -rf ~/Library/Caches/org.swift.swiftpm/
rm -rf ~/Library/Developer/Xcode/DerivedData/*/SourcePackages/

echo "✅ 清理完成！"
echo ""
echo "📝 接下来请执行："
echo "1. 重启 Xcode"
echo "2. 打开项目"
echo "3. Product → Clean Build Folder (Cmd+Shift+K)"
echo "4. Product → Build (Cmd+B)"
