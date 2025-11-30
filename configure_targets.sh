#!/bin/bash

# Xcode 项目配置脚本
# 用于配置双 Target 的 Bundle ID、Swift Flags 和文件路径

PROJECT_FILE="/Users/mercury/Desktop/锚点/锚点.xcodeproj/project.pbxproj"

echo "🔧 开始配置 Xcode 项目..."

# 备份原文件
cp "$PROJECT_FILE" "$PROJECT_FILE.backup"
echo "✅ 已备份项目文件"

# 注意：由于 project.pbxproj 是二进制格式的 plist，我们需要手动在 Xcode 中完成以下配置
# 这个脚本仅用于记录需要修改的内容

echo ""
echo "⚠️  请在 Xcode 中手动完成以下配置："
echo ""
echo "📱 锚点 CN Target:"
echo "  1. Bundle Identifier: com.mercury.chengyu.cn"
echo "  2. Info.plist File: 锚点-CN/Info.plist"
echo "  3. Code Sign Entitlements: 锚点-CN/锚点-CN.entitlements"
echo "  4. Other Swift Flags: -D CN_VERSION"
echo ""
echo "📱 锚点 US Target:"
echo "  1. Bundle Identifier: com.mercury.serenity.us"
echo "  2. Info.plist File: 锚点-US/Info.plist"
echo "  3. Code Sign Entitlements: 锚点-US/锚点-US.entitlements"
echo "  4. Other Swift Flags: -D US_VERSION"
echo ""
echo "🔧 配置步骤："
echo "  1. 在 Xcode 中选择项目文件"
echo "  2. 选择对应的 Target"
echo "  3. 在 Build Settings 中搜索对应的设置项"
echo "  4. 修改为上述值"
echo ""
echo "💡 提示：Other Swift Flags 在 Build Settings → Swift Compiler - Custom Flags 中"
echo ""
