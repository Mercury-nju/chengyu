# 创建双 Extension Target 详细指南

## 目标
为 CN 和 US 版本各创建一个独立的 Extension target，使两个版本都能完整支持 Screen Time 功能。

---

## 步骤 1: 准备工作

### 1.1 创建 US Extension 文件夹和配置文件

在终端执行（已自动完成）：
```bash
mkdir -p TotalActivityReport-US
```

### 1.2 创建 US Extension 的 Entitlements 文件

文件路径：`TotalActivityReport-US/TotalActivityReport-US.entitlements`

内容：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.developer.family-controls</key>
	<true/>
	<key>com.apple.security.application-groups</key>
	<array>
		<string>group.com.mercury.serenity.us</string>
	</array>
</dict>
</plist>
```

### 1.3 创建 US Extension 的 Info.plist

文件路径：`TotalActivityReport-US/Info.plist`

内容：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSExtension</key>
	<dict>
		<key>NSExtensionPointIdentifier</key>
		<string>com.apple.DeviceActivity.report-extension</string>
	</dict>
</dict>
</plist>
```

---

## 步骤 2: 在 Xcode 中创建新 Extension Target

### 2.1 Duplicate 现有 Extension

1. 打开 Xcode 项目
2. 在项目导航器中，选择项目文件（最顶层的蓝色图标）
3. 在 TARGETS 列表中，找到 **TotalActivityReport**
4. 右键点击 → **Duplicate**
5. 系统会创建一个名为 "TotalActivityReport copy" 的新 target
6. 将其重命名为 **TotalActivityReport-US**

### 2.2 配置 TotalActivityReport-US Target

选择 **TotalActivityReport-US** target，进行以下配置：

#### General 标签页

| 设置项 | 值 |
|--------|-----|
| Display Name | TotalActivityReport-US |
| Bundle Identifier | `com.mercury.serenity.us.TotalActivityReport` |
| Version | 1.0 |
| Build | 1 |

#### Build Settings 标签页

搜索并配置以下项：

**Info.plist File:**
- 值：`TotalActivityReport-US/Info.plist`

**Code Signing Entitlements:**
- 值：`TotalActivityReport-US/TotalActivityReport-US.entitlements`

**Product Bundle Identifier:**
- Debug: `com.mercury.serenity.us.TotalActivityReport`
- Release: `com.mercury.serenity.us.TotalActivityReport`

#### Signing & Capabilities 标签页

1. 配置 **Team**（选择您的开发团队）
2. 确认 **Family Controls** capability 已添加
3. 确认 **App Groups** capability 已添加
   - App Group: `group.com.mercury.serenity.us`

---

## 步骤 3: 更新 CN Extension 配置

选择原有的 **TotalActivityReport** target：

### 3.1 重命名为 TotalActivityReport-CN

1. 在 TARGETS 列表中，选择 **TotalActivityReport**
2. 按 Enter 键或双击名称
3. 重命名为 **TotalActivityReport-CN**

### 3.2 更新配置

#### General 标签页

| 设置项 | 值 |
|--------|-----|
| Display Name | TotalActivityReport-CN |
| Bundle Identifier | `com.mercury.chengyu.cn.TotalActivityReport` |

#### Build Settings 标签页

**Product Bundle Identifier:**
- Debug: `com.mercury.chengyu.cn.TotalActivityReport`
- Release: `com.mercury.chengyu.cn.TotalActivityReport`

#### Signing & Capabilities 标签页

确认 App Group 为：`group.com.mercury.chengyu.cn`

---

## 步骤 4: 配置主应用的 Extension 依赖

### 4.1 锚点 CN Target

1. 选择 **锚点 CN** target
2. **General** 标签页 → **Frameworks, Libraries, and Embedded Content**
3. 确保只包含 **TotalActivityReport-CN.appex**
4. 如果有 TotalActivityReport-US，移除它
5. **Build Phases** → **Embed ExtensionKit Extensions**
6. 确保只包含 **TotalActivityReport-CN.appex**

### 4.2 锚点 US Target

1. 选择 **锚点 US** target
2. **General** 标签页 → **Frameworks, Libraries, and Embedded Content**
3. 点击 **+** 按钮
4. 选择 **TotalActivityReport-US.appex**
5. 确保 **Embed** 设置为 "Embed & Sign"
6. 移除任何对 TotalActivityReport-CN 的引用

---

## 步骤 5: 更新源代码文件的 Target Membership

### 5.1 TotalActivityReport.swift

1. 在项目导航器中找到 `TotalActivityReport/TotalActivityReport.swift`
2. 在右侧的 **File Inspector** 中，找到 **Target Membership**
3. 确保同时勾选：
   - ✅ TotalActivityReport-CN
   - ✅ TotalActivityReport-US

### 5.2 配置文件的 Target Membership

**TotalActivityReport/Info.plist:**
- ✅ TotalActivityReport-CN

**TotalActivityReport/TotalActivityReport.entitlements:**
- ✅ TotalActivityReport-CN

**TotalActivityReport-US/Info.plist:**
- ✅ TotalActivityReport-US

**TotalActivityReport-US/TotalActivityReport-US.entitlements:**
- ✅ TotalActivityReport-US

---

## 步骤 6: 更新 Scheme

### 6.1 锚点 CN Scheme

1. **Product** → **Scheme** → **Edit Scheme...**
2. 选择 **锚点 CN** scheme
3. 在左侧选择 **Build**
4. 确保 **TotalActivityReport-CN** 被包含
5. 移除 **TotalActivityReport-US**（如果存在）

### 6.2 锚点 US Scheme

1. 选择 **锚点 US** scheme
2. 在左侧选择 **Build**
3. 确保 **TotalActivityReport-US** 被包含
4. 移除 **TotalActivityReport-CN**（如果存在）

---

## 步骤 7: 清理和验证

### 7.1 清理构建

```bash
# 在终端执行
cd /Users/mercury/Desktop/锚点
rm -rf ~/Library/Developer/Xcode/DerivedData/*锚点*
```

### 7.2 编译测试

```bash
# 测试 CN 版本
xcodebuild -scheme "锚点 CN" -configuration Debug clean build

# 测试 US 版本
xcodebuild -scheme "锚点 US" -configuration Debug clean build
```

### 7.3 验证清单

- [ ] 两个 Extension target 都能成功编译
- [ ] CN 版本包含 TotalActivityReport-CN.appex
- [ ] US 版本包含 TotalActivityReport-US.appex
- [ ] Bundle ID 正确：
  - CN Extension: `com.mercury.chengyu.cn.TotalActivityReport`
  - US Extension: `com.mercury.serenity.us.TotalActivityReport`
- [ ] App Group 正确：
  - CN Extension: `group.com.mercury.chengyu.cn`
  - US Extension: `group.com.mercury.serenity.us`

---

## 常见问题

### Q: 编译时提示 "Duplicate symbols"
**A:** 检查源代码文件的 Target Membership，确保没有重复包含。

### Q: Extension 无法访问 App Group
**A:** 检查 Entitlements 文件中的 App Group 标识符是否正确。

### Q: 两个版本无法同时安装
**A:** 这是正常的，因为 Extension 的 Bundle ID 不同。需要先卸载一个版本再安装另一个。

---

## 完成后的项目结构

```
锚点/
├── 锚点.xcodeproj/
├── 锚点/                           # 主应用代码（共享）
├── 锚点-CN/                        # CN 版本配置
│   ├── Info.plist
│   └── 锚点-CN.entitlements
├── 锚点-US/                        # US 版本配置
│   ├── Info.plist
│   └── 锚点-US.entitlements
├── TotalActivityReport/            # CN Extension 代码
│   ├── TotalActivityReport.swift   # 共享代码
│   ├── Info.plist                  # CN 配置
│   └── TotalActivityReport.entitlements
└── TotalActivityReport-US/         # US Extension 配置
    ├── Info.plist
    └── TotalActivityReport-US.entitlements
```

---

## 下一步

完成上述步骤后，您将拥有：
- ✅ 两个完全独立的主应用版本
- ✅ 两个完全独立的 Extension 版本
- ✅ 每个版本都有完整的 Screen Time 功能
- ✅ 可以独立打包上传到不同地区的 App Store

开始配置吧！🚀
