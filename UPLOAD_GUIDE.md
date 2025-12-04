# App Store上传指南

## 当前状态
✅ Archive已成功创建：`./build/Lumea.xcarchive`

## 问题
命令行导出时遇到签名证书不匹配的问题：
- Archive使用的是Development证书
- 导出到App Store需要Distribution证书

## 解决方案

### 方案1：使用Xcode（推荐，最简单）

1. **打开Xcode**

2. **打开Organizer**
   - 菜单栏：Window → Organizer
   - 或快捷键：⌘⇧O

3. **选择Archive**
   - 在左侧选择 "Archives"
   - 找到 "Lumea" 或 "AnchorUS"
   - 选择最新的Archive（应该是今天的）

4. **分发App**
   - 点击右侧的 "Distribute App" 按钮
   - 选择 "App Store Connect"
   - 选择 "Upload"
   - 点击 "Next"

5. **签名**
   - Xcode会自动选择正确的Distribution证书
   - 确认设置后点击 "Upload"

6. **等待上传**
   - 上传可能需要几分钟
   - 完成后会显示成功消息

7. **在App Store Connect中查看**
   - 访问：https://appstoreconnect.apple.com
   - 进入 "我的App" → "Lumea"
   - 等待构建版本处理完成（5-10分钟）
   - 在 "TestFlight" 或 "准备提交" 中选择构建版本

### 方案2：命令行（需要额外配置）

如果必须使用命令行，需要：

1. **创建App-Specific Password**
   - 访问：https://appleid.apple.com
   - 登录你的Apple ID
   - 在 "安全" 部分生成 "App专用密码"
   - 保存这个密码

2. **运行脚本**
   ```bash
   ./archive_with_distribution.sh
   ```
   
3. **输入凭证**
   - 输入你的Apple ID邮箱
   - 输入刚创建的App-Specific Password

## 推荐
**强烈建议使用方案1（Xcode）**，因为：
- Xcode会自动处理所有签名问题
- 不需要手动输入密码
- 更可靠，错误更少
- 可以看到详细的上传进度

## 下一步（上传成功后）

1. **等待处理**
   - App Store Connect需要5-10分钟处理构建版本
   - 你会收到邮件通知

2. **配置构建版本**
   - 在App Store Connect中选择构建版本
   - 填写"新功能"说明
   - 选择发布方式

3. **提交审核**
   - 确认所有信息正确
   - 点击"提交审核"
   - 等待Apple审核（通常1-3天）

## 故障排除

如果Xcode中也遇到签名问题：

1. **检查证书**
   ```bash
   security find-identity -v -p codesigning
   ```
   应该看到 "Apple Distribution: Daniel Lee"

2. **重新登录Apple ID**
   - Xcode → Preferences → Accounts
   - 移除并重新添加Apple ID

3. **清理Provisioning Profiles**
   ```bash
   rm -rf ~/Library/MobileDevice/Provisioning\ Profiles/*
   ```
   然后在Xcode中重新尝试

4. **重新生成Archive**
   - 如果需要，可以重新运行：
   ```bash
   ./fix_permissions_and_archive.sh
   ```
