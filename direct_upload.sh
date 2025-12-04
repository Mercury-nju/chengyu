#!/bin/bash

echo "🚀 直接上传Archive到App Store Connect..."
echo ""

# 检查是否有Apple ID凭证
echo "⚠️  此方法需要App-Specific Password"
echo ""
echo "如果你还没有创建App-Specific Password："
echo "1. 访问 https://appleid.apple.com"
echo "2. 登录你的Apple ID"
echo "3. 在 '安全' 部分生成 'App专用密码'"
echo ""

read -p "请输入你的Apple ID邮箱: " APPLE_ID
read -sp "请输入App-Specific Password: " APP_PASSWORD
echo ""
echo ""

# 验证Archive
echo "1️⃣ 验证Archive..."
xcrun altool --validate-app \
  -f ./build/Lumea.xcarchive \
  -t ios \
  -u "$APPLE_ID" \
  -p "$APP_PASSWORD"

if [ $? -eq 0 ]; then
    echo "   ✅ 验证成功"
    echo ""
    
    # 上传
    echo "2️⃣ 上传到App Store Connect..."
    xcrun altool --upload-app \
      -f ./build/Lumea.xcarchive \
      -t ios \
      -u "$APPLE_ID" \
      -p "$APP_PASSWORD"
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ 上传成功！"
        echo ""
        echo "下一步："
        echo "1. 访问 https://appstoreconnect.apple.com"
        echo "2. 等待构建版本处理完成（5-10分钟）"
        echo "3. 提交审核"
    else
        echo ""
        echo "❌ 上传失败"
    fi
else
    echo ""
    echo "❌ 验证失败"
    echo ""
    echo "Archive可能需要先导出为IPA"
fi
