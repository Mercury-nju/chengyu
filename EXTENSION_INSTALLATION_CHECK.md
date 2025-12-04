# Extension 安装检查方案

## 完整检查清单

### 第一步：检查 Xcode 项目配置

#### 1.1 检查 Targets 列表

1. 在 Xcode 中，点击左侧项目根节点
2. 查看 TARGETS 列表，应该看到：
   - ✅ 锚点 US（主 App）
   - ✅ TotalActivityReport（Report Extension）
   - ✅ HDAMonitor-US（Monitor Extension）

#### 1.2 检查 Scheme 配置

1. Product > Scheme > Edit Scheme
2. 在左侧选择 "Build"
3. 确认以下 targets 都被勾选：
   - ✅ 锚点 US
   - ✅ TotalActivityReport
   - ✅ HDAMonitor-US

#### 1.3 检查主 App 的 Build Phases

1. 选择 "锚点 US" target
2. 进入 "Build Phases" 标签
3. 展开 "Embed Foundation Extensions"
4. 应该看到：
   - ✅ TotalActivityReport.appex
   - ✅ HDAMonitor-US.appex
5. **重要：确保每个 Extension 只出现一次！**

#### 1.4 检查 Extension 的 Bundle ID

1. 选择 "HDAMonitor-US" target
2. 进入 "General" 标签
3. 查看 Bundle Identifier：
   - 应该是：`com.mercury.serenity.us.HDAMonitorExtension`
   - 或类似的唯一 ID

### 第二步：检查 Entitlements 配置

#### 2.1 主 App Entitlements

文件：`锚点-US/锚点-US.entitlements`

应该包含：
```xml
<key>com.apple.developer.family-controls</key>
<true/>
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.mercury.serenity.us</string>
</array>
```

#### 2.2 HDAMonitor-US Entitlements

文件：`HDAMonitor-US/HDAMonitor-US.entitlements`

应该包含：
```xml
<key>com.apple.developer.family-controls</key>
<true/>
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.mercury.serenity.us</string>
</array>
```

#### 2.3 TotalActivityReport Entitlements

文件：`TotalActivityReport/TotalActivityReport.entitlements`

应该包含相同的配置。

### 第三步：检查设备上的安装

#### 3.1 在设备上检查

1. 打开 iOS 设置
2. 通用 > iPhone 储存空间
3. 找到 "Lumea" 或 "锚点"
4. 点击进入，查看 "文稿与数据"
5. 应该能看到 Extensions 的大小

#### 3.2 检查 Extension 权限

1. 设置 > 屏幕使用时间
2. 查看 "所有活动"
3. 确认能看到今天的数据

### 第四步：运行时检查

#### 4.1 在 Xcode 控制台运行诊断代码

在 App 运行时，在 Xcode 控制台底部输入：

```swift
// 检查授权状态
po AuthorizationCenter.shared.authorizationStatus

// 检查监控状态
po ScreenTimeMonitor.shared.isMonitoring

// 检查选择的应用数量
po HDAManager.shared.monitoredAppsCount

// 检查 App Group 数据
if let shared = UserDefaults(suiteName: "group.com.mercury.serenity.us") {
    let duration = shared.double(forKey: "totalHDAUsageDuration")
    let lastSync = shared.object(forKey: "lastHDASyncDate") as? Date
    print("Duration: \(duration)s (\(Int(duration/60))m)")
    print("Last Sync: \(String(describing: lastSync))")
}
```

#### 4.2 查看日志输出

在 Xcode 控制台搜索以下关键词：

**主 App 日志：**
- `[ScreenTimeMonitor]`
- `[HDAManager]`
- `[HDASettings]`

**Extension 日志：**
- `[HDAMonitor]`
- `[Extension]`

### 第五步：强制触发测试

#### 5.1 手动触发监控

在 HDA 设置页面：

1. 点击"编辑应用"
2. 选择一个你经常使用的 app（如 Safari）
3. 返回设置页面
4. 观察 Xcode 控制台，应该看到：
   ```
   ✅ [ScreenTimeMonitor] Started monitoring HDA usage
   📱 [ScreenTimeMonitor] Monitoring 1 apps
   ```

#### 5.2 使用被监测的 App

1. 退出你的 App（保持在后台）
2. 打开被监测的 app（如 Safari）
3. 使用至少 1-2 分钟
4. 返回你的 App
5. 打开 HDA 设置页面
6. 点击刷新按钮

#### 5.3 检查日志

在 Xcode 控制台应该看到：

**如果 Extension 工作正常：**
```
🎯 [HDAMonitor] Interval started for: hdaUsage
⏰ [HDAMonitor] Event threshold reached: usageThreshold
✅ [HDAMonitor] Updated total usage: 60s (1m)
📊 [HDASettings] Total usage: 60.0s (1m), last sync: ...
```

**如果 Extension 没有工作：**
```
📊 [HDASettings] Total usage: 0.0s (0m), last sync: nil
```

### 第六步：常见问题排查

#### 问题 1：Extension 从未被触发

**症状：**
- 控制台没有任何 `[HDAMonitor]` 日志
- 使用时间始终为 0

**解决方案：**
1. 检查 Extension 是否在 Scheme 中被勾选
2. 检查 Build Phases 中是否正确嵌入
3. 完全删除 App 并重新安装
4. 检查 Info.plist 中的 Extension Point

#### 问题 2：Extension 被触发但数据为 0

**症状：**
- 能看到 `[HDAMonitor] Interval started` 日志
- 但没有 `Event threshold reached` 日志

**解决方案：**
1. 确认被监测的 app 确实被使用了
2. 等待至少 1 分钟（阈值时间）
3. 检查 App 是否在前台运行（某些 app 后台时间不计入）

#### 问题 3：Extension 写入数据失败

**症状：**
- 能看到 `Event threshold reached` 日志
- 但看到 `❌ Cannot access App Group` 或 `Failed to synchronize`

**解决方案：**
1. 检查 Entitlements 配置
2. 确认 App Group ID 一致
3. 在 Apple Developer 网站确认 App Group 已创建

### 第七步：验证 Extension 安装

#### 方法 1：通过 Xcode

1. Window > Devices and Simulators
2. 选择你的设备
3. 找到你的 App
4. 点击齿轮图标 > Show Container
5. 查看 PlugIns 文件夹
6. 应该看到 HDAMonitor-US.appex

#### 方法 2：通过设备

1. 设置 > 通用 > iPhone 储存空间
2. 找到你的 App
3. 查看大小（应该包含 Extensions）

### 第八步：如果一切都失败了

#### 最后的解决方案

如果 HDAMonitor Extension 始终无法工作，可以：

1. **使用 TotalActivityReport Extension**
   - 它使用不同的触发机制（UI 渲染）
   - 虽然不是实时的，但更可靠

2. **或者重新创建 Extension**
   - 删除现有的 HDAMonitor-US target
   - File > New > Target
   - 选择 "Device Activity Monitor Extension"
   - 使用新的名称和 Bundle ID
   - 复制代码

## 快速诊断命令

在终端运行：
```bash
./test_hda_monitoring.sh
```

然后在 Xcode 控制台运行诊断代码，查看 App Group 中的数据。

## 需要的信息

请告诉我：
1. Xcode 控制台中能看到哪些日志？
2. 是否看到 `[HDAMonitor]` 开头的日志？
3. 是否看到 `[ScreenTimeMonitor] Started monitoring` 日志？
4. 运行诊断代码后，App Group 中的数据是多少？
