# 修复 HDAMonitor Bundle ID 冲突

## 问题
安装时出现错误：两个 Extension 使用了相同的 Bundle ID `com.mercury.serenity.us.HDAMonitor`

## 解决方案

### 方法 1：在 Xcode 中修改 Bundle ID

1. **打开 Xcode 项目**

2. **选择 HDAMonitor-US Target**
   - 在左侧项目导航器中，点击项目名称
   - 在 TARGETS 列表中找到 "HDAMonitor-US"

3. **修改 Bundle Identifier**
   - 选择 "General" 标签
   - 找到 "Bundle Identifier"
   - 将其改为：`com.mercury.serenity.us.HDAMonitorExtension`
   - （添加 "Extension" 后缀使其唯一）

4. **Clean Build Folder**
   - Product > Clean Build Folder (Shift + Cmd + K)

5. **重新构建**
   - Product > Build (Cmd + B)

### 方法 2：删除重复的 Target

如果项目中有多个 HDAMonitor targets：

1. **检查所有 Targets**
   - 在 Xcode 中查看 TARGETS 列表
   - 查找是否有重复的 HDAMonitor targets

2. **删除重复的 Target**
   - 选择重复的 target
   - 按 Delete 键
   - 确认删除

3. **清理项目**
   - Product > Clean Build Folder

### 方法 3：检查 Embedded Content

1. **选择主 App Target（锚点 US）**

2. **查看 General > Frameworks, Libraries, and Embedded Content**
   - 确保 HDAMonitor-US.appex 只出现一次

3. **查看 Build Phases > Embed Foundation Extensions**
   - 确保 HDAMonitor-US.appex 只出现一次
   - 如果有重复，删除多余的

### 方法 4：使用不同的 Extension 类型

如果以上方法都不行，可能需要：

1. **删除现有的 HDAMonitor-US target**

2. **重新创建 Extension**
   - File > New > Target
   - 选择 "Device Activity Monitor Extension"
   - 命名为 "HDAMonitorExtension"
   - Bundle ID 会自动生成为唯一的

3. **复制代码**
   - 将 HDAMonitorExtension.swift 的代码复制到新 target

## 验证修复

修复后，检查：

1. **Build Settings**
   ```
   Target: HDAMonitor-US
   Product Bundle Identifier: com.mercury.serenity.us.HDAMonitorExtension
   ```

2. **Info.plist**
   - 确保 Bundle Identifier 与 Build Settings 一致

3. **重新安装**
   - 完全删除设备上的 App
   - Clean Build Folder
   - 重新构建并安装

## 推荐的 Bundle ID 结构

```
主 App:     com.mercury.serenity.us
Extension:  com.mercury.serenity.us.HDAMonitorExtension
Report:     com.mercury.serenity.us.TotalActivityReport
```

确保每个 Extension 都有唯一的 Bundle ID。
