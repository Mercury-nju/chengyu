# Xcode手动签名配置指南

## 问题根源
Archive使用Development证书签名，但App Store需要Distribution证书。

## 解决方案：在Xcode中配置手动签名

### 步骤1：打开项目签名设置

1. **打开Xcode**
   - 打开 `锚点.xcodeproj`

2. **选择项目和Target**
   - 在左侧项目导航器中，点击最顶部的项目 "锚点"
   - 在中间的TARGETS列表中，选择 **"锚点 US"**

3. **进入Signing & Capabilities**
   - 点击顶部的 **"Signing & Capabilities"** 标签

### 步骤2：切换到手动签名

1. **取消自动签名**
   - 找到 **"Automatically manage signing"** 复选框
   - **取消勾选**这个选项
   - 会弹出警告，点击 **"Continue"**

### 步骤3：配置Release签名（重要！）

1. **切换到Release配置**
   - 在 "Signing & Capabilities" 标签下
   - 找到顶部的配置下拉菜单（可能显示 "Debug" 或 "All"）
   - 选择 **"Release"**

2. **选择Distribution证书**
   - 在 **"Signing Certificate"** 下拉菜单中
   - 选择：
     ```
     Apple Distribution: Daniel Lee (FX2M56Q5GV)
     ```
   - 如果看不到，选择 "Other..." 然后从列表中选择

3. **选择App Store Provisioning Profile**
   - 在 **"Provisioning Profile"** 下拉菜单中
   - 选择：
     ```
     iOS Team Store Provisioning Profile: com.mercury.serenity.us
     ```
   - 如果看不到，点击下拉菜单中的 "Download Profile"

### 步骤4：保存并验证

1. **保存项目**
   - 按 ⌘S 保存

2. **验证配置**
   - 确认 "Signing Certificate" 显示 "Apple Distribution"
   - 确认 "Provisioning Profile" 显示包含 "Store" 的Profile
   - 确认没有黄色或红色警告

### 步骤5：Clean并重新Archive

1. **Clean Build Folder**
   - 菜单栏：Product → Clean Build Folder
   - 或快捷键：⇧⌘K

2. **Archive**
   - 菜单栏：Product → Archive
   - 或快捷键：⌃⌘A
   - 等待Archive完成（可能需要几分钟）

3. **验证Archive**
   - Archive完成后会自动打开Organizer
   - 选择刚创建的Archive
   - 在右侧应该看到正确的签名信息

### 步骤6：上传到App Store

1. **在Organizer中**
   - 选择刚创建的Archive
   - 点击 **"Distribute App"** 按钮

2. **选择分发方式**
   - 选择 **"App Store Connect"**
   - 点击 **"Next"**

3. **选择上传**
   - 选择 **"Upload"**
   - 点击 **"Next"**

4. **确认签名**
   - Xcode会显示将使用的证书和Profile
   - 应该显示 "Apple Distribution: Daniel Lee"
   - 点击 **"Upload"**

5. **等待上传**
   - 上传可能需要几分钟
   - 完成后会显示成功消息

## 常见问题

### Q: 看不到 "Apple Distribution" 证书？
A: 
1. 检查证书是否安装：
   ```bash
   security find-identity -v -p codesigning | grep Distribution
   ```
2. 如果没有，需要在 https://developer.apple.com 创建并下载

### Q: 看不到 "iOS Team Store Provisioning Profile"？
A: 
1. 在Provisioning Profile下拉菜单中点击 "Download Profile"
2. 或在 Xcode → Preferences → Accounts → Download Manual Profiles

### Q: 还是显示 "Profile doesn't include the selected signing certificate"？
A: 
1. 确认选择的是 **Release** 配置（不是Debug）
2. 确认Profile名称包含 "Store" 或 "Distribution"
3. 尝试删除并重新下载Profile

### Q: Archive成功但上传时还是报错？
A: 
1. 在Organizer中右键点击Archive
2. 选择 "Show in Finder"
3. 右键点击 .xcarchive 文件
4. 选择 "Show Package Contents"
5. 检查 Products/Applications/AnchorUS.app/embedded.mobileprovision
6. 确认它是Distribution Profile

## 验证命令

检查Archive的签名：
```bash
codesign -dvv ./build/Lumea.xcarchive/Products/Applications/AnchorUS.app 2>&1 | grep "Authority"
```

应该看到：
```
Authority=Apple Distribution: Daniel Lee (FX2M56Q5GV)
```

## 成功标志

配置正确时，你应该看到：
- ✅ Signing Certificate: Apple Distribution: Daniel Lee (FX2M56Q5GV)
- ✅ Provisioning Profile: iOS Team Store Provisioning Profile: com.mercury.serenity.us
- ✅ 没有黄色或红色警告
- ✅ Archive成功
- ✅ 上传成功

## 如果还是不行

最后的办法：
1. 在 https://developer.apple.com/account 手动创建新的App Store Provisioning Profile
2. 确保选择 "App Store" 类型
3. 选择正确的App ID (com.mercury.serenity.us)
4. 选择 Distribution 证书
5. 下载并双击安装
6. 在Xcode中选择这个新Profile
7. 重新Archive
