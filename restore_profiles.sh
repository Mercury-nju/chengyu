#!/bin/bash

echo "🔄 恢复Provisioning Profiles..."
echo ""

echo "方法1：让Xcode重新下载所有Profiles"
echo "======================================"
echo ""
echo "1. 打开Xcode"
echo "2. 菜单栏：Xcode → Preferences (或 Settings)"
echo "3. 选择 'Accounts' 标签"
echo "4. 选择你的Apple ID"
echo "5. 点击右下角的 'Download Manual Profiles' 按钮"
echo "6. 等待下载完成"
echo ""
echo "这会重新下载你账号下的所有Provisioning Profiles"
echo ""

read -p "是否继续方法2（命令行下载）？(y/n): " choice

if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    echo ""
    echo "方法2：使用命令行重新下载"
    echo "=============================="
    echo ""
    
    # 尝试触发Xcode重新下载
    echo "正在触发Xcode重新生成Profiles..."
    
    xcodebuild -project 锚点.xcodeproj \
      -scheme "锚点 US" \
      -configuration Release \
      -sdk iphoneos \
      CODE_SIGN_STYLE=Automatic \
      DEVELOPMENT_TEAM=FX2M56Q5GV \
      -allowProvisioningUpdates \
      -allowProvisioningDeviceRegistration \
      build
    
    echo ""
    echo "检查恢复的Profiles："
    ls -la ~/Library/MobileDevice/Provisioning\ Profiles/ 2>/dev/null | wc -l
    
    if [ $(ls ~/Library/MobileDevice/Provisioning\ Profiles/ 2>/dev/null | wc -l) -gt 0 ]; then
        echo "✅ 已恢复 $(ls ~/Library/MobileDevice/Provisioning\ Profiles/ 2>/dev/null | wc -l) 个Profiles"
    else
        echo "⚠️  未能自动恢复，请使用方法1手动下载"
    fi
fi

echo ""
echo "注意："
echo "- Provisioning Profiles可以随时重新下载"
echo "- 它们存储在Apple Developer账号中"
echo "- 删除本地文件不会影响云端的Profiles"
echo "- Xcode会在需要时自动重新下载"
