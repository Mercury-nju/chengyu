#!/bin/bash

# 修复 US 版本的编译标志
# 这个脚本会为 "锚点 US" target 添加 US_VERSION 编译标志

echo "🔧 修复 US 版本编译标志..."

# 备份项目文件
cp "锚点.xcodeproj/project.pbxproj" "锚点.xcodeproj/project.pbxproj.backup"

# 使用 sed 在 US target 的配置中添加 US_VERSION 标志
# 查找 "锚点 US" target 的 buildSettings 并添加 SWIFT_ACTIVE_COMPILATION_CONDITIONS

# 方法：在 project.pbxproj 中找到 "锚点 US" 的 buildSettings，添加编译标志
perl -i -pe 's/(SWIFT_ACTIVE_COMPILATION_CONDITIONS = )(DEBUG|RELEASE)( ;)?/$1$2 US_VERSION$3/g if /锚点 US/../^			};/' "锚点.xcodeproj/project.pbxproj"

echo "✅ 已添加 US_VERSION 编译标志"
echo ""
echo "请在 Xcode 中："
echo "1. 关闭项目"
echo "2. 重新打开 锚点.xcodeproj"
echo "3. 选择 scheme: 锚点 US"
echo "4. Clean Build Folder (⌘⇧K)"
echo "5. Build (⌘B)"
echo ""
echo "如果出现问题，可以恢复备份："
echo "cp 锚点.xcodeproj/project.pbxproj.backup 锚点.xcodeproj/project.pbxproj"
