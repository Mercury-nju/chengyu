# Extension Bundle ID 冲突解决方案

## 问题
Extension 的 Bundle ID 必须以主应用的 Bundle ID 为前缀，但现在有两个主应用：
- CN: `com.mercury.chengyu.cn`
- US: `com.mercury.serenity.us`

Extension 当前的 Bundle ID 是 `com.mercury.chengyu.TotalActivityReport`，只匹配 CN 版本。

## 解决方案

### 方案 A：只为 CN 版本启用 Extension（推荐）

**操作步骤：**
1. 在 Xcode 中选择 **锚点 US** target
2. 在 **General** 标签页，找到 **Frameworks, Libraries, and Embedded Content**
3. 移除 `TotalActivityReport.appex`
4. 在 **Build Phases** 标签页，找到 **Embed ExtensionKit Extensions**
5. 移除 `TotalActivityReport.appex`

**优点：**
- 简单快速
- 不需要修改代码
- CN 版本功能完整

**缺点：**
- US 版本没有 Screen Time 数据报告功能

### 方案 B：创建两个 Extension Target

**操作步骤：**
1. Duplicate `TotalActivityReport` target
2. 重命名为 `TotalActivityReport-US`
3. 修改 Bundle ID 为 `com.mercury.serenity.us.TotalActivityReport`
4. 修改 Entitlements 使用 `group.com.mercury.serenity.us`
5. 将 `TotalActivityReport-US` 嵌入到 **锚点 US** target

**优点：**
- 两个版本功能完整
- 独立配置

**缺点：**
- 需要维护两个 Extension target
- 配置复杂

### 方案 C：使用条件配置（不推荐）

尝试让一个 Extension 根据编译配置动态调整 Bundle ID。

**缺点：**
- 技术上复杂
- 可能不被 Xcode 支持

## 推荐行动

**立即采用方案 A**，让 US 版本暂时不包含 Extension。

如果未来需要 US 版本也有完整功能，再采用方案 B 创建第二个 Extension。

## 手动操作指南（方案 A）

1. 打开 Xcode
2. 选择项目文件 → 选择 **锚点 US** target
3. **General** 标签页 → 滚动到底部 → **Frameworks, Libraries, and Embedded Content**
4. 找到 `TotalActivityReport.appex`，点击 **-** 按钮移除
5. 切换到 **Build Phases** 标签页
6. 展开 **Embed ExtensionKit Extensions**
7. 找到 `TotalActivityReport.appex`，点击 **-** 按钮移除
8. 清理并重新编译

完成后，CN 版本将包含完整的 Screen Time 功能，US 版本暂时不包含。
