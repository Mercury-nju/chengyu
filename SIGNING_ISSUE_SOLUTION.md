# Provisioning Profile签名问题解决方案

## 问题
在Xcode Organizer中尝试上传时出现错误：
```
Provisioning profile failed qualification
Profile doesn't include the selected signing certificate.
```

## 根本原因
Xcode自动生成的Provisioning Profile包含的是**Development证书**，但上传到App Store需要**Distribution证书**。

## 解决方案

### 🎯 推荐方案：在Xcode中切换到手动签名

#### 步骤1：修改项目签名设置

1. **打开Xcode项目**
   - 打开 `锚点.xcodeproj`

2. **选择Target**
   - 在左侧项目导航器中选择项目 "锚点"
   - 在TARGETS列表中选择 "锚点 US"

3. **进入Signing & Capabilities**
   - 点击顶部的 "Signing & Capabilities" 标签

4. **切换到手动签名**
   - **取消勾选** "Automatically manage signing"
   - 会出现警告，点击 "Continue"

5. **配置Release签名**
   - 确保选择了 "Release" 配置（在顶部下拉菜单）
   - 在 "Signing Certificate" 下拉菜单中选择：
     ```
     Apple Distribution: Daniel Lee (FX2M56Q5GV)
     ```
   - 在 "Provisioning Profile" 下拉菜单中：
     - 如果看到 "iOS Team Store Provisioning Profile: com.mercury.serenity.us"，选择它
     - 如果没有，选择 "Download Profile" 或 "Import Profile"

6. **保存更改**
   - ⌘S 保存项目

#### 步骤2：重新Archive

1. **Clean Build Folder**
   - Product → Clean Build Folder (⇧⌘K)

2. **Archive**
   - Product → Archive
   - 等待Archive完成

3. **在Organizer中分发**
   - Archive完成后会自动打开Organizer
   - 选择刚创建的Archive
   - 点击 "Distribute App"
   - 选择 "App Store Connect"
   - 选择 "Upload"
   - 这次应该可以成功！

---

### 🔄 备选方案：在Apple Developer网站重新生成Profile

如果上面的方法不行，需要手动创建Provisioning Profile：

#### 步骤1：访问Apple Developer

1. 打开浏览器，访问：
   ```
   https://developer.apple.com/account/resources/profiles/list
   ```

2. 登录你的Apple ID

#### 步骤2：删除旧的Profile

1. 找到所有与 `com.mercury.serenity.us` 相关的Profile
2. 点击每个Profile，然后点击 "Delete"
3. 确认删除

#### 步骤3：创建新的App Store Profile

1. 点击 "+" 按钮创建新Profile

2. **选择类型**
   - 选择 "App Store" (在Distribution下)
   - 点击 "Continue"

3. **选择App ID**
   - 在下拉菜单中找到并选择：
     ```
     com.mercury.serenity.us
     ```
   - 如果没有，需要先创建App ID
   - 点击 "Continue"

4. **选择证书**
   - 勾选：
     ```
     Apple Distribution: Daniel Lee
     ```
   - 点击 "Continue"

5. **命名Profile**
   - Profile Name: `Lumea App Store Profile`
   - 点击 "Generate"

6. **下载Profile**
   - 点击 "Download"
   - 保存到本地

#### 步骤4：安装Profile

1. 找到下载的 `.mobileprovision` 文件
2. 双击文件安装
3. 或者拖到Xcode图标上

#### 步骤5：在Xcode中使用新Profile

1. 回到Xcode
2. 在 "Signing & Capabilities" 中
3. 在 "Provisioning Profile" 下拉菜单中选择刚创建的Profile
4. 重新Archive并上传

---

### 🛠️ 方案3：使用命令行（高级）

如果你熟悉命令行，可以运行：

```bash
chmod +x manual_signing_archive.sh
./manual_signing_archive.sh
```

这个脚本会：
1. 清理旧的构建文件
2. 触发Xcode生成新的Provisioning Profile
3. 使用正确的签名重新Archive

---

## 常见问题

### Q: 为什么会出现这个问题？
A: Xcode的自动签名在Archive时默认使用Development证书，但上传到App Store需要Distribution证书。

### Q: 我需要付费的Apple Developer账号吗？
A: 是的，上传到App Store需要付费的Apple Developer Program会员资格（$99/年）。

### Q: 如果还是不行怎么办？
A: 尝试以下步骤：
1. Xcode → Preferences → Accounts
2. 选择你的Apple ID
3. 点击 "Download Manual Profiles"
4. 重新尝试Archive和上传

### Q: 可以跳过这个问题直接上传吗？
A: 不可以，必须使用正确的Distribution证书和Provisioning Profile才能上传到App Store。

---

## 验证签名配置

运行以下命令检查你的证书：

```bash
# 查看所有签名证书
security find-identity -v -p codesigning

# 应该看到：
# Apple Development: Daniel Lee (C7UC872T48)
# Apple Distribution: Daniel Lee (FX2M56Q5GV)  ← 需要这个
```

---

## 需要帮助？

如果以上方法都不行，可能需要：

1. **重新登录Apple ID**
   - Xcode → Preferences → Accounts
   - 移除Apple ID
   - 重新添加

2. **撤销并重新创建证书**
   - 访问 https://developer.apple.com/account/resources/certificates/list
   - 撤销旧的Distribution证书
   - 创建新的Distribution证书

3. **联系Apple Developer Support**
   - https://developer.apple.com/support/

---

## 成功标志

当配置正确时，你应该看到：
- ✅ Signing Certificate: Apple Distribution: Daniel Lee
- ✅ Provisioning Profile: iOS Team Store Provisioning Profile
- ✅ 可以成功Archive
- ✅ 可以在Organizer中成功Upload
