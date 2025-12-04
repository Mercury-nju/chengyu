# 创建正确的App Store Provisioning Profile

## 问题
现有的Profile缺少必要的功能或包含不需要的功能（MIDI）。

## 解决方案：手动创建正确的Profile

### 步骤1：访问Apple Developer

1. 打开浏览器，访问：
   ```
   https://developer.apple.com/account/resources/profiles/list
   ```

2. 登录你的Apple ID

### 步骤2：删除旧的Profile

1. 找到 **"Lumea Distribution Profile"**
2. 点击它
3. 点击 **"Delete Profile"**
4. 确认删除

### 步骤3：检查App ID配置

1. 访问：
   ```
   https://developer.apple.com/account/resources/identifiers/list
   ```

2. 找到并点击 **"com.mercury.serenity.us"**

3. 确认已启用的Capabilities：
   - ✅ App Groups
   - ✅ Sign in with Apple
   - ❌ DriverKit (如果有，取消勾选)

4. 如果修改了，点击 **"Save"**

### 步骤4：创建新的App Store Profile

1. 回到Profiles页面：
   ```
   https://developer.apple.com/account/resources/profiles/list
   ```

2. 点击 **"+"** 按钮

3. **选择Profile类型**
   - 选择 **"App Store"** (在Distribution下)
   - 点击 **"Continue"**

4. **选择App ID**
   - 在下拉菜单中选择：**"com.mercury.serenity.us"**
   - 点击 **"Continue"**

5. **选择证书**
   - 勾选：**"Apple Distribution: Daniel Lee (FX2M56Q5GV)"**
   - 点击 **"Continue"**

6. **命名Profile**
   - Profile Name: **"Lumea App Store Profile"**
   - 点击 **"Generate"**

7. **下载Profile**
   - 点击 **"Download"**
   - 保存到本地

### 步骤5：安装Profile

1. 找到下载的 `.mobileprovision` 文件
2. **双击文件**安装
3. 或者拖到Xcode图标上

### 步骤6：在Xcode中使用新Profile

1. **回到Xcode**

2. **确认还是手动签名**
   - 在 "Signing & Capabilities" 中
   - 确认 "Automatically manage signing" 是**未勾选**的

3. **选择新Profile**
   - 在 "Provisioning Profile" 下拉菜单中
   - 选择刚创建的 **"Lumea App Store Profile"**

4. **验证**
   - 确认没有红色❌错误
   - Signing Certificate 应该显示 "Apple Distribution"

5. **保存**
   - ⌘S 保存项目

### 步骤7：Clean并Archive

1. **Clean Build Folder**
   - Product → Clean Build Folder (⇧⌘K)

2. **Archive**
   - Product → Archive
   - 等待完成

3. **上传**
   - 在Organizer中选择Archive
   - Distribute App → App Store Connect → Upload

## 成功标志

- ✅ Profile包含 App Groups
- ✅ Profile包含 Sign in with Apple
- ✅ Profile不包含 DriverKit MIDI
- ✅ Profile使用 Distribution 证书
- ✅ 没有签名错误
- ✅ Archive成功
- ✅ 上传成功

## 如果还是不行

最后的办法：
1. 删除所有相关的Profiles
2. 在Xcode中重新勾选 "Automatically manage signing"
3. 让Xcode完全自动处理
4. 如果Xcode自动签名失败，可能需要联系Apple Developer Support
