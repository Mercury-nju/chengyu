# 快速配置检查清单

## 当前状态
- ✅ 已创建两个 Target（锚点 CN 和 锚点 US）
- ✅ 已创建配置文件（Info.plist 和 Entitlements）
- ⚠️ 需要完成 Build Settings 配置

## 需要在 Xcode 中完成的配置

### 1. 锚点 CN Target

**General 标签页：**
- Display Name: `澄域`
- Bundle Identifier: `com.mercury.chengyu.cn` ✅

**Build Settings 标签页：**
搜索并配置以下项：

| 设置项 | 当前值 | 目标值 | 状态 |
|--------|--------|--------|------|
| Info.plist File | 自动生成 | `锚点-CN/Info.plist` | ⚠️ 需修改 |
| Code Sign Entitlements | `锚点/锚点.entitlements` | `锚点-CN/锚点-CN.entitlements` | ⚠️ 需修改 |
| Other Swift Flags | 空 | `-D CN_VERSION` | ⚠️ 需添加 |

**Signing & Capabilities 标签页：**
- ✅ Family Controls capability
- ✅ App Groups: `group.com.mercury.chengyu.cn`

---

### 2. 锚点 US Target

**General 标签页：**
- Display Name: `Serenity Anchor`
- Bundle Identifier: `com.mercury.serenity.us` ⚠️ 当前是 `com.mercury.chengyu`

**Build Settings 标签页：**

| 设置项 | 当前值 | 目标值 | 状态 |
|--------|--------|--------|------|
| Info.plist File | 自动生成 | `锚点-US/Info.plist` | ⚠️ 需修改 |
| Code Sign Entitlements | `锚点/锚点.entitlements` | `锚点-US/锚点-US.entitlements` | ⚠️ 需修改 |
| Other Swift Flags | 空 | `-D US_VERSION` | ⚠️ 需添加 |

**Signing & Capabilities 标签页：**
- ⚠️ Family Controls capability（需添加）
- ⚠️ App Groups: `group.com.mercury.serenity.us`（需添加）

---

## 详细配置步骤

### 步骤 1: 配置 Bundle Identifier

1. 选择 **锚点 US** target
2. 在 **General** 标签页
3. 将 **Bundle Identifier** 改为: `com.mercury.serenity.us`

### 步骤 2: 配置 Info.plist 路径

1. 选择 target（CN 或 US）
2. 切换到 **Build Settings** 标签页
3. 在搜索框输入: `Info.plist`
4. 找到 **Packaging** → **Info.plist File**
5. 双击值，修改为：
   - CN: `锚点-CN/Info.plist`
   - US: `锚点-US/Info.plist`

### 步骤 3: 配置 Entitlements 路径

1. 在 **Build Settings** 中搜索: `entitlements`
2. 找到 **Signing** → **Code Signing Entitlements**
3. 双击值，修改为：
   - CN: `锚点-CN/锚点-CN.entitlements`
   - US: `锚点-US/锚点-US.entitlements`

### 步骤 4: 添加 Swift 编译标志

1. 在 **Build Settings** 中搜索: `Other Swift Flags`
2. 找到 **Swift Compiler - Custom Flags** → **Other Swift Flags**
3. 双击值，点击 **+** 添加新行
4. 输入：
   - CN target: `-D CN_VERSION`
   - US target: `-D US_VERSION`

### 步骤 5: 配置 Capabilities（仅 US Target）

1. 选择 **锚点 US** target
2. 切换到 **Signing & Capabilities** 标签页
3. 点击 **+ Capability** 按钮
4. 添加 **Family Controls**
5. 添加 **App Groups**
   - 点击 App Groups 下的 **+**
   - 输入: `group.com.mercury.serenity.us`

---

## 验证配置

完成上述步骤后，请验证：

### 编译测试
```bash
# 测试 CN 版本
xcodebuild -scheme "锚点 CN" -configuration Debug build

# 测试 US 版本
xcodebuild -scheme "锚点 US" -configuration Debug build
```

### 检查清单
- [ ] 两个 Target 都能成功编译
- [ ] Bundle ID 正确（CN: .cn, US: .us）
- [ ] Info.plist 路径正确
- [ ] Entitlements 路径正确
- [ ] Swift Flags 已添加
- [ ] App Groups 配置正确

---

## 常见问题

### Q: "No profiles for 'com.mercury.chengyu.cn' were found"
**A:** 这是正常的，您需要在 Apple Developer 网站创建对应的 App ID 和 Provisioning Profile。

### Q: 如何测试条件编译是否生效？
**A:** 在代码中添加测试：
```swift
#if CN_VERSION
print("This is CN version")
#elseif US_VERSION
print("This is US version")
#endif
```

### Q: 两个版本可以同时安装吗？
**A:** 可以！因为它们有不同的 Bundle ID。

---

## 下一步

配置完成后，您可以：
1. 选择不同的 Scheme 进行构建
2. 测试条件编译功能
3. 准备提交到 App Store
