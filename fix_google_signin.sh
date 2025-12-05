#!/bin/bash

echo "🔧 修复 Google Sign-In 包问题..."
echo ""

# 1. 关闭 Xcode（如果正在运行）
echo "1️⃣ 检查 Xcode 是否运行..."
if pgrep -x "Xcode" > /dev/null; then
    echo "⚠️  请先关闭 Xcode，然后重新运行此脚本"
    exit 1
fi

# 2. 清理所有缓存
echo "2️⃣ 清理所有缓存..."
rm -rf ~/Library/Caches/org.swift.swiftpm/
rm -rf ~/Library/Developer/Xcode/DerivedData/锚点-*
rm -rf .build/
echo "   ✅ 缓存已清理"

# 3. 删除 Package.resolved（如果存在）
echo "3️⃣ 清理 Package 解析文件..."
if [ -f "锚点.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved" ]; then
    rm "锚点.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
    echo "   ✅ Package.resolved 已删除"
else
    echo "   ℹ️  Package.resolved 不存在"
fi

echo ""
echo "✅ 清理完成！"
echo ""
echo "📝 接下来请执行："
echo "1. 打开 Xcode"
echo "2. File → Packages → Reset Package Caches"
echo "3. File → Packages → Resolve Package Versions"
echo "4. Product → Clean Build Folder (Cmd+Shift+K)"
echo "5. Product → Build (Cmd+B)"
echo ""
echo "如果还有问题，请尝试："
echo "- File → Packages → Update to Latest Package Versions"
