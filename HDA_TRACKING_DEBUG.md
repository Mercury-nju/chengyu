# HDA 使用时间追踪调试指南

## 当前问题
显示 0 分钟，即使系统设置中显示有使用时间。

## 调试步骤

### 1. 检查 Xcode 控制台日志

运行 App 后，在 Xcode 控制台搜索以下关键词：

**Extension 日志（最重要）：**
```
🔍 [Extension] makeConfiguration called
🔍 [Extension] Data count: 
🔍 [Extension] Total duration:
🔍 [Extension] Saved to
```

**主 App 日志：**
```
📊 [HDASettings] Total usage:
[ScreenTimeMonitor]
```

### 2. 如果看不到 Extension 日志

这说明 Extension 没有被触发，可能的原因：

#### A. Extension Target 配置问题

1. 在 Xcode 中，选择 Scheme
2. 确保 `TotalActivityReport` Extension 被包含在构建中
3. Product > Scheme > Edit Scheme
4. 确保 "TotalActivityReport" 在 Build 列表中

#### B. App Group 配置问题

检查以下文件的 App Group 配置是否一致：

**主 App (锚点.entitlements):**
```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.mercury.chengyu.cn</string>
</array>
```

**Extension (TotalActivityReport.entitlements):**
```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.mercury.chengyu.cn</string>
</array>
```

#### C. 权限问题

1. 确保已授权 Screen Time 权限
2. 在 iOS 设置 > 屏幕使用时间 > 查看所有活动
3. 确认能看到今天的使用数据

### 3. 强制触发 Extension

在 HDA 设置页面：

1. 点击"编辑应用"按钮
2. 重新选择要监测的应用（即使已经选择过）
3. 返回设置页面
4. 等待 5-10 秒
5. 点击刷新按钮

### 4. 清理并重新构建

```bash
# 1. 清理构建缓存
rm -rf ~/Library/Developer/Xcode/DerivedData

# 2. 在 Xcode 中
Product > Clean Build Folder (Shift + Cmd + K)

# 3. 删除设备上的 App

# 4. 重新构建并安装
Product > Run (Cmd + R)
```

### 5. 检查 Extension 是否正确安装

在设备上：
1. 设置 > 通用 > iPhone 存储
2. 找到你的 App
3. 查看是否有 Extension 被安装

### 6. 手动测试 Extension

创建一个测试按钮来强制触发：

在 HDASettingsView 中添加：
```swift
Button("测试 Extension") {
    // 强制刷新 Report
    reportContext = DeviceActivityReport.Context("Test-\(UUID().uuidString)")
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        reportContext = .totalActivity
    }
}
```

## 预期行为

### 正常工作时的日志：

```
🔍 [Extension] makeConfiguration called
🔍 [Extension] Data count: 1
🔍 [Extension] Total duration: 3540.0 seconds (59 minutes)
🔍 [Extension] Saved to group.com.mercury.chengyu.cn: true
📊 [HDASettings] Total usage: 3540.0s (59m), last sync: 2025-11-30 15:30:00
```

### 问题情况的日志：

**Extension 未触发：**
- 看不到任何 `[Extension]` 日志
- 解决：检查 Extension Target 配置

**Extension 触发但数据为 0：**
```
🔍 [Extension] makeConfiguration called
🔍 [Extension] Data count: 0
🔍 [Extension] Total duration: 0.0 seconds (0 minutes)
```
- 解决：检查是否正确选择了监测应用，或者今天确实没有使用

**无法保存数据：**
```
❌ [Extension] Cannot access group.com.mercury.chengyu.cn
❌ [Extension] Failed to save to any app group
```
- 解决：检查 App Group 配置

## 常见问题

### Q: 为什么需要打开页面才能看到数据？
A: DeviceActivityReport 需要被渲染才会触发 Extension。我们在页面中嵌入了一个几乎不可见的 Report 来触发数据收集。

### Q: 数据多久更新一次？
A: 每次打开 HDA 设置页面或状态页面时会触发更新。也可以手动点击刷新按钮。

### Q: 为什么显示的时间和系统设置不完全一样？
A: 可能有几秒到几分钟的延迟，这是正常的。系统的 Screen Time 数据不是实时的。

## 下一步

如果以上步骤都无法解决问题，请提供：
1. Xcode 控制台的完整日志
2. 截图显示系统设置中的使用时间
3. 截图显示 App 中的显示
