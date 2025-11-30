#!/bin/bash

echo "🎵 验证会员音乐集成"
echo "===================="
echo ""

# 检查会员音乐文件夹
if [ -d "锚点/会员音乐" ]; then
    echo "✅ 会员音乐文件夹存在"
else
    echo "❌ 会员音乐文件夹不存在"
    exit 1
fi

# 检查音乐文件
echo ""
echo "📁 会员音乐文件列表："
music_files=(
    "氛围.mp3"
    "冷静.mp3"
    "宁静.mp3"
    "惬意.mp3"
    "森林.mp3"
    "山谷.mp3"
    "阳光.mp3"
    "治愈.mp3"
)

missing_files=0
for file in "${music_files[@]}"; do
    if [ -f "锚点/会员音乐/$file" ]; then
        size=$(ls -lh "锚点/会员音乐/$file" | awk '{print $5}')
        echo "   ✅ $file ($size)"
    else
        echo "   ❌ $file (缺失)"
        missing_files=$((missing_files + 1))
    fi
done

echo ""
if [ $missing_files -eq 0 ]; then
    echo "✅ 所有会员音乐文件完整 (${#music_files[@]} 个文件)"
else
    echo "❌ 缺失 $missing_files 个文件"
    exit 1
fi

# 检查 CalmView.swift 中的实现
echo ""
echo "📝 检查代码实现："

if grep -q "isPremium" "锚点/CalmView.swift"; then
    echo "   ✅ isPremium 属性已实现"
else
    echo "   ❌ isPremium 属性未找到"
fi

if grep -q "会员音乐/" "锚点/CalmView.swift"; then
    echo "   ✅ 会员音乐路径已配置"
else
    echo "   ❌ 会员音乐路径未配置"
fi

if grep -q "lock.fill" "锚点/CalmView.swift"; then
    echo "   ✅ 锁定图标已添加"
else
    echo "   ❌ 锁定图标未添加"
fi

if grep -q "MusicOptionView" "锚点/CalmView.swift"; then
    echo "   ✅ MusicOptionView 组件已创建"
else
    echo "   ❌ MusicOptionView 组件未找到"
fi

echo ""
echo "===================="
echo "✨ 验证完成！"
echo ""
echo "📋 下一步操作："
echo "1. 在 Xcode 中打开项目"
echo "2. 由于项目使用文件系统同步，会员音乐文件夹应该会自动被识别"
echo "3. 如果没有自动识别，请手动添加："
echo "   - 右键点击 '锚点' 文件夹"
echo "   - 选择 'Add Files to 锚点...'"
echo "   - 选择 '会员音乐' 文件夹"
echo "   - 确保勾选 'Create folder references' (蓝色文件夹)"
echo "   - 点击 'Add'"
echo "4. 运行应用并测试冥想音乐功能"
echo ""
