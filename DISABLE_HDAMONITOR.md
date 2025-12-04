# 禁用 HDAMonitor-US Extension

## 问题
HDAMonitor-US.appex 被重复嵌入到 Extensions 和 Plugins 文件夹，导致安装失败。

## 解决方案：暂时禁用 HDAMonitor-US

由于 TotalActivityReport Extension 已经可以收集 HDA 使用数据，我们可以暂时禁用 HDAMonitor-US。

### 步骤

#### 1. 在 Xcode 中禁用 Target

1. **打开 Xcode 项目**

2. **选择项目根节点**（最顶层的"锚点"）

3. **在 TARGETS 列表中找到 "HDAMonitor-US"**

4. **右键点击 "HDAMonitor-US"**
   - 选择 "Delete" 或 "Remove"
   - 选择 "Remove Reference"（不要选择 "Move to Trash"）

#### 2. 从主 App 中移除嵌入

1. **选择 "锚点 US" target**

2. **进入 "General" 标签**

3. **在 "Frameworks, Libraries, and Embedded Content" 中**
   - 找到 HDAMonitor-US.appex
   - 点击 "-" 按钮删除

4. **进入 "Build Phases" 标签**

5. **在 "Embed Foundation Extensions" 中**
   - 找到 HDAMonitor-US.appex
   - 删除所有出现的实例

6. **检查 "Copy Files" 阶段**
   - 删除任何 HDAMonitor-US.appex 引用

#### 3. Clean 并重新构建

1. **Clean Build Folder**
   - Product > Clean Build Folder (Shift + Cmd + K)

2. **删除 DerivedData**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   ```

3. **删除设备上的 App**

4. **重新构建并安装**
   - Product > Build (Cmd + B)
   - Product > Run (Cmd + R)

## 为什么可以禁用

1. **TotalActivityReport Extension 已经在工作**
   - 它可以收集 HDA 使用数据
   - 数据会写入 App Group

2. **HDAMonitor Extension 是可选的**
   - 它主要用于实时监控
   - 对于基本功能不是必需的

3. **可以稍后重新添加**
   - 等项目稳定后
   - 可以重新创建一个正确配置的 Extension

## 验证

禁用后，应该能够：
- ✅ 成功安装 App
- ✅ 使用 TotalActivityReport 收集数据
- ✅ 在 HDA 设置页面看到使用时间

## 如果需要重新启用

稍后可以：
1. File > New > Target
2. 选择 "Device Activity Monitor Extension"
3. 使用不同的名称（如 "HDAMonitor"）
4. 确保 Bundle ID 唯一
5. 复制代码
