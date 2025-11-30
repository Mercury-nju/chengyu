# 🔧 添加 US_VERSION 编译标志 - 必须操作！

## ⚠️ 重要：这是为什么显示中文的原因

你的 US 版本没有设置 `US_VERSION` 编译标志，所以 `L10n.isUSVersion` 返回 `false`，导致显示中文。

## 📝 解决步骤（5分钟）

### 1. 在 Xcode 中打开项目
```bash
open 锚点.xcodeproj
```

### 2. 选择 "锚点 US" Target
- 在左侧项目导航器中，点击最顶部的项目图标（蓝色的）
- 在中间区域，选择 **TARGETS** 下的 **"锚点 US"**

### 3. 添加编译标志
- 选择 **Build Settings** 标签
- 在搜索框中输入：`Swift Compiler - Custom Flags`
- 或者搜索：`SWIFT_ACTIVE_COMPILATION_CONDITIONS`

### 4. 添加 US_VERSION
- 找到 **"Swift Compiler - Custom Flags"** 或 **"Active Compilation Conditions"**
- 展开这一行（点击左边的三角形）
- 你会看到 **Debug** 和 **Release** 两行
- 在 **Debug** 行，双击值的部分
- 添加：`US_VERSION`（如果已经有 DEBUG，就添加为 `DEBUG US_VERSION`）
- 在 **Release** 行，也添加：`US_VERSION`

### 5. 清理并重新构建
```
Product → Clean Build Folder (⌘⇧K)
Product → Build (⌘B)
```

### 6. 运行测试
```
Product → Run (⌘R)
```

现在应该显示英文了！

---

## 🎯 快速验证

构建后，检查编译标志是否生效：

```bash
xcodebuild -project 锚点.xcodeproj -scheme "锚点 US" -showBuildSettings 2>/dev/null | grep "SWIFT_ACTIVE_COMPILATION_CONDITIONS"
```

应该看到：
```
SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG US_VERSION
```

---

## 📸 截图指南

### 步骤 2-3 的位置：
```
项目导航器（左侧）
  └─ 锚点（蓝色图标）← 点击这里
       ├─ PROJECT
       │   └─ 锚点
       └─ TARGETS
           ├─ 锚点 CN
           ├─ 锚点 US  ← 选择这个
           └─ ...
```

### 步骤 4 的位置：
```
Build Settings 标签
  └─ 搜索框：输入 "compilation conditions"
       └─ Swift Compiler - Custom Flags
            └─ Active Compilation Conditions
                 ├─ Debug: [双击这里] 输入 "DEBUG US_VERSION"
                 └─ Release: [双击这里] 输入 "US_VERSION"
```

---

## ❓ 常见问题

### Q: 找不到 "Active Compilation Conditions"？
A: 确保你选择的是 **Build Settings** 标签，不是 **General** 或其他标签

### Q: 已经有 DEBUG 了怎么办？
A: 保留 DEBUG，在后面加空格和 US_VERSION，变成：`DEBUG US_VERSION`

### Q: Debug 和 Release 都要加吗？
A: 是的，两个都要加。Debug 用于开发，Release 用于发布

### Q: 添加后还是中文？
A: 确保：
1. Clean Build Folder (⌘⇧K)
2. 删除模拟器上的 app
3. 重新 Build 和 Run

---

## 🔍 验证是否成功

运行 app 后，你应该看到：
- ✅ App 名称：Lumea（不是 澄域）
- ✅ 标签栏：Calm, Flow, Insight, Profile（不是中文）
- ✅ 所有界面文字都是英文

如果还是中文，说明编译标志没有生效，请重新检查上述步骤。

---

## 💡 原理说明

`Localizable.swift` 中的代码：

```swift
static var isUSVersion: Bool {
    #if US_VERSION
    return true  // ← 只有设置了 US_VERSION 才会执行这里
    #else
    return false // ← 没有设置时执行这里，返回中文
    #endif
}
```

所以必须在编译时设置 `US_VERSION` 标志！
