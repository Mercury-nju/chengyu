# Xcode 手动配置步骤指南

本文档提供在 Xcode 中完成双 Target 配置的详细步骤。

## 步骤 1: 创建第二个 Target

1. 打开 Xcode 项目
2. 在项目导航器中，选择项目文件（最顶层的蓝色图标）
3. 在 TARGETS 列表中，选择现有的 "锚点" target
4. 右键点击 → **Duplicate**（或使用菜单 Editor → Add Target → Duplicate Target）
5. 系统会创建一个名为 "锚点 copy" 的新 target
6. 将新 target 重命名为 **"锚点-US"**
7. 将原 target 重命名为 **"锚点-CN"**

## 步骤 2: 配置中国版 Target (锚点-CN)

### 2.1 General 设置
1. 选择 **锚点-CN** target
2. 在 **General** 标签页：
   - **Display Name**: `澄域`
   - **Bundle Identifier**: `com.mercury.chengyu.cn`
   - **Version**: `1.0`
   - **Build**: `1`

### 2.2 Build Settings
1. 切换到 **Build Settings** 标签页
2. 搜索 "Info.plist"
3. 找到 **Info.plist File** 设置
4. 将值改为: `锚点-CN/Info.plist`
5. 搜索 "Other Swift Flags"
6. 找到 **Other Swift Flags** (在 Swift Compiler - Custom Flags 下)
7. 双击，添加新行: `-D CN_VERSION`

### 2.3 Signing & Capabilities
1. 切换到 **Signing & Capabilities** 标签页
2. 配置 **Team** (选择您的开发团队)
3. 确认 **Signing Certificate** 正确
4. 点击 **+ Capability** 按钮
5. 添加 **Family Controls** capability
6. 添加 **App Groups** capability
   - 点击 "+" 添加: `group.com.mercury.chengyu.cn`
7. 在 **Code Signing Entitlements** 中，确认路径为: `锚点-CN/锚点-CN.entitlements`

## 步骤 3: 配置美国版 Target (锚点-US)

### 3.1 General 设置
1. 选择 **锚点-US** target
2. 在 **General** 标签页：
   - **Display Name**: `Serenity Anchor`
   - **Bundle Identifier**: `com.mercury.serenity.us`
   - **Version**: `1.0`
   - **Build**: `1`

### 3.2 Build Settings
1. 切换到 **Build Settings** 标签页
2. 搜索 "Info.plist"
3. 找到 **Info.plist File** 设置
4. 将值改为: `锚点-US/Info.plist`
5. 搜索 "Other Swift Flags"
6. 找到 **Other Swift Flags**
7. 双击，添加新行: `-D US_VERSION`

### 3.3 Signing & Capabilities
1. 切换到 **Signing & Capabilities** 标签页
2. 配置 **Team** (选择您的开发团队)
3. 确认 **Signing Certificate** 正确
4. 点击 **+ Capability** 按钮
5. 添加 **Family Controls** capability
6. 添加 **App Groups** capability
   - 点击 "+" 添加: `group.com.mercury.serenity.us`
7. 在 **Code Signing Entitlements** 中，确认路径为: `锚点-US/锚点-US.entitlements`

## 步骤 4: 配置 Scheme

### 4.1 创建/编辑 Scheme
1. 点击 Xcode 顶部工具栏的 Scheme 选择器（项目名称旁边）
2. 选择 **Manage Schemes...**
3. 确保有两个 Scheme：
   - **锚点-CN** (对应 锚点-CN target)
   - **锚点-US** (对应 锚点-US target)
4. 如果没有，点击 "+" 创建新 Scheme
5. 为每个 Scheme 选择对应的 Target

### 4.2 验证 Scheme 配置
1. 选择 **锚点-CN** scheme
2. 点击 **Edit Scheme...**
3. 在左侧选择 **Run**
4. 确认 **Build Configuration** 为 **Debug**
5. 确认 **Executable** 为 **锚点-CN.app**
6. 对 **锚点-US** scheme 重复相同步骤

## 步骤 5: 在项目导航器中组织文件

### 5.1 添加配置文件到项目
1. 在项目导航器中，右键点击项目根目录
2. 选择 **Add Files to "锚点"...**
3. 导航到 `锚点-CN` 文件夹
4. 选择 `Info.plist` 和 `锚点-CN.entitlements`
5. **重要**: 在添加对话框中：
   - ✅ 勾选 "Copy items if needed"
   - ✅ 在 "Add to targets" 中，**只勾选** "锚点-CN"
6. 点击 **Add**
7. 对 `锚点-US` 文件夹重复相同步骤（只勾选 "锚点-US" target）

### 5.2 组织源代码文件
1. 在项目导航器中，选择所有 `.swift` 文件
2. 在右侧的 **File Inspector** 中，找到 **Target Membership**
3. 确保所有源代码文件同时勾选了 **锚点-CN** 和 **锚点-US**
4. 对 `Assets.xcassets` 和其他共享资源做同样的操作

## 步骤 6: 配置 Extension Target (如果需要)

如果您的项目有 Device Activity Report Extension：

1. 选择 **TotalActivityReport** target
2. 在 **Build Settings** 中添加条件编译标志（与主 app 相同）
3. 或者，为每个版本创建独立的 Extension target：
   - Duplicate Extension target
   - 重命名为 `TotalActivityReport-CN` 和 `TotalActivityReport-US`
   - 配置各自的 App Group

## 步骤 7: 验证配置

### 7.1 编译测试
1. 选择 **锚点-CN** scheme
2. 选择模拟器或真机
3. 点击 **Build** (⌘B)
4. 确认编译成功
5. 对 **锚点-US** scheme 重复测试

### 7.2 运行测试
1. 选择 **锚点-CN** scheme
2. 运行 app (⌘R)
3. 验证：
   - 应用名称显示为 "澄域"
   - 权限请求文案为中文
4. 选择 **锚点-US** scheme
5. 运行 app
6. 验证：
   - 应用名称显示为 "Serenity Anchor"
   - 权限请求文案为英文

### 7.3 同时安装测试
1. 先运行 **锚点-CN** 安装到设备
2. 不要卸载，直接切换到 **锚点-US** scheme
3. 再次运行
4. 确认设备上同时存在两个独立的 app

## 常见问题排查

### 问题 1: 编译错误 "Cannot find 'CN_VERSION' in scope"
**解决方案**: 检查 Build Settings → Other Swift Flags 是否正确添加了 `-D CN_VERSION`

### 问题 2: App Group 访问失败
**解决方案**: 
1. 检查 Entitlements 文件中的 App Group 标识符
2. 确认在 Apple Developer 网站创建了对应的 App Group
3. 确认 Signing & Capabilities 中正确添加了 App Group

### 问题 3: Info.plist 找不到
**解决方案**: 检查 Build Settings → Info.plist File 路径是否正确

### 问题 4: 两个版本无法同时安装
**解决方案**: 确认两个 target 的 Bundle Identifier 不同

## 完成！

配置完成后，您可以：
- 使用 **锚点-CN** scheme 构建中国版
- 使用 **锚点-US** scheme 构建美国版
- 两个版本可以独立打包上传到 App Store
- 代码中可以使用 `#if CN_VERSION` 和 `#if US_VERSION` 进行条件编译
