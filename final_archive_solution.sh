#!/bin/bash

echo "🎯 最终解决方案：使用Distribution证书Archive"
echo ""

echo "问题分析："
echo "- 现有的Archive使用Development证书签名"
echo "- 上传到App Store需要Distribution证书"
echo "- 必须重新Archive"
echo ""

echo "解决方案："
echo "1. 在Xcode项目中切换到手动签名"
echo "2. 明确指定Distribution证书"
echo "3. 重新Archive"
echo ""

read -p "是否继续？(y/n): " choice

if [ "$choice" != "y" ] && [ "$choice" != "Y" ]; then
    echo "已取消"
    exit 0
fi

echo ""
echo "步骤1：清理旧的Archive"
rm -rf ./build/Lumea.xcarchive
xcodebuild clean -project 锚点.xcodeproj -scheme "锚点 US" -configuration Release

echo ""
echo "步骤2：使用Distribution证书Archive"
echo "（这可能需要几分钟）"
echo ""

# 使用手动签名，明确指定Distribution证书
xcodebuild archive \
  -project 锚点.xcodeproj \
  -scheme "锚点 US" \
  -configuration Release \
  -archivePath "./build/Lumea.xcarchive" \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="Apple Distribution: Daniel Lee (FX2M56Q5GV)" \
  DEVELOPMENT_TEAM=FX2M56Q5GV \
  PROVISIONING_PROFILE_SPECIFIER="iOS Team Store Provisioning Profile: com.mercury.serenity.us" \
  -allowProvisioningUpdates

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Archive成功！"
    echo ""
    echo "验证Archive的签名："
    codesign -dvv ./build/Lumea.xcarchive/Products/Applications/AnchorUS.app 2>&1 | grep "Authority"
    echo ""
    echo "现在在Xcode Organizer中："
    echo "1. Window → Organizer"
    echo "2. 选择新的Archive"
    echo "3. Distribute App → App Store Connect → Upload"
    echo "4. 这次应该可以成功！"
else
    echo ""
    echo "❌ Archive失败"
    echo ""
    echo "请尝试手动方法："
    echo "1. 打开Xcode项目"
    echo "2. 选择Target '锚点 US'"
    echo "3. Signing & Capabilities"
    echo "4. 取消 'Automatically manage signing'"
    echo "5. Signing Certificate: Apple Distribution: Daniel Lee"
    echo "6. Provisioning Profile: iOS Team Store Provisioning Profile"
    echo "7. Product → Archive"
fi
