#!/bin/bash

echo "🔧 修复Provisioning Profile问题..."
echo ""

echo "这个问题的原因是："
echo "- Xcode自动生成的Provisioning Profile使用了Development证书"
echo "- 但上传到App Store需要Distribution证书"
echo ""

echo "解决方案："
echo ""

echo "方法1：在Xcode中手动选择证书"
echo "================================"
echo "1. 在Xcode中，选择项目 '锚点'"
echo "2. 选择Target '锚点 US'"
echo "3. 进入 'Signing & Capabilities' 标签"
echo "4. 取消勾选 'Automatically manage signing'"
echo "5. 在 'Provisioning Profile' 下拉菜单中："
echo "   - 如果看到 'iOS Team Store Provisioning Profile'，选择它"
echo "   - 如果没有，点击 'Download Profile'"
echo "6. 确保 'Signing Certificate' 显示 'Apple Distribution'"
echo "7. 重新在Organizer中尝试 'Distribute App'"
echo ""

echo "方法2：在Apple Developer网站重新生成Profile"
echo "=============================================="
echo "1. 访问：https://developer.apple.com/account/resources/profiles/list"
echo "2. 找到 'com.mercury.serenity.us' 相关的Profile"
echo "3. 删除所有旧的Profile"
echo "4. 点击 '+' 创建新的Profile："
echo "   - 类型：App Store"
echo "   - App ID：com.mercury.serenity.us"
echo "   - 证书：选择 'Apple Distribution: Daniel Lee'"
echo "5. 下载新的Profile"
echo "6. 双击安装"
echo "7. 回到Xcode，在 'Signing & Capabilities' 中选择新的Profile"
echo ""

echo "方法3：使用命令行强制重新生成（需要Apple ID）"
echo "=============================================="
echo ""
read -p "是否尝试方法3？(y/n): " choice

if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    echo ""
    echo "清理旧的Provisioning Profiles..."
    rm -rf ~/Library/MobileDevice/Provisioning\ Profiles/*
    
    echo ""
    echo "重新Archive（强制使用Distribution证书）..."
    
    # 临时修改项目设置
    xcodebuild archive \
      -project 锚点.xcodeproj \
      -scheme "锚点 US" \
      -configuration Release \
      -archivePath "./build/Lumea-Distribution.xcarchive" \
      CODE_SIGN_STYLE=Manual \
      CODE_SIGN_IDENTITY="Apple Distribution: Daniel Lee (FX2M56Q5GV)" \
      PROVISIONING_PROFILE_SPECIFIER="" \
      DEVELOPMENT_TEAM=FX2M56Q5GV \
      -allowProvisioningUpdates
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Archive成功！"
        echo "现在在Xcode Organizer中应该可以看到新的Archive"
        echo "尝试用这个新的Archive上传"
    else
        echo ""
        echo "❌ 失败，请尝试方法1或方法2"
    fi
else
    echo ""
    echo "请手动尝试方法1或方法2"
fi

echo ""
echo "如果所有方法都失败，可能需要："
echo "1. 在Xcode Preferences → Accounts 中重新登录Apple ID"
echo "2. 确保你的Apple ID有权限访问Team 'FX2M56Q5GV'"
echo "3. 联系Apple Developer Support"
