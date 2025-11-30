# 高多巴胺应用（HDA）监测功能实现说明

## 功能概述

分心监测功能通过 iOS Screen Time API 追踪用户使用高多巴胺应用的时长，并计算对稳定值（SV）和认知负荷指数（CLI）的影响。

## 实现架构

### 1. 核心组件

#### HDAManager
- 管理用户选择的监测应用列表
- 使用 `FamilyActivitySelection` 存储应用选择
- 自动通知 ScreenTimeMonitor 更新过滤器

#### ScreenTimeMonitor
- 请求 Screen Time 权限
- 启动 DeviceActivity 监控
- 从 App Group 共享存储读取使用数据
- 每 5 分钟自动同步数据

#### TotalActivityReport Extension
- DeviceActivity Extension
- 计算监测应用的总使用时长
- 将数据写入 App Group 共享存储

#### StatusManager
- 应用 HDA 使用影响到稳定值
- 计算认知负荷指数（CLI）
- 记录分心轨迹日志
- 触发 CLI 阈值提醒

### 2. 数据流

```
用户使用 HDA 应用
    ↓
iOS Screen Time API 记录
    ↓
TotalActivityReport Extension 计算总时长
    ↓
写入 App Group 共享存储
    ↓
ScreenTimeMonitor 定期读取（每 5 分钟）
    ↓
StatusManager 应用影响
    ↓
更新 SV 和 CLI
    ↓
UI 显示分心轨迹
```

### 3. 关键配置

#### App Group ID
- 主应用和 Extension 必须使用相同的 App Group ID
- 当前使用：`group.com.mercury.chengyu.cn`
- 已在 entitlements 文件中配置

#### 权限要求
- Family Controls（Screen Time API）
- App Groups（共享数据）

## 使用流程

### 1. 授权 Screen Time 访问
1. 打开应用，进入 Status 页面
2. 点击 CLI 卡片上的"设置"按钮
3. 点击"授权访问"按钮
4. 在系统弹窗中授权

### 2. 添加监测应用
1. 在 HDA 设置页面点击"添加应用"
2. 在系统选择器中选择要监测的应用
3. 点击"完成"保存

### 3. 自动监控
- 系统会自动开始监控选中的应用
- 每 5 分钟同步一次数据
- 进入 Status 页面时也会触发同步

### 4. 查看分心轨迹
- 在 Status 页面的"分心轨迹"卡片中查看
- 显示最近 3 条 HDA 使用记录
- 包含使用时长和 SV 损失

## 影响计算

### 稳定值（SV）损失
- 公式：每小时使用 = -10% SV
- 示例：使用 30 分钟 = -5% SV

### 认知负荷指数（CLI）
- 基于最近 24 小时的 HDA 使用时长
- 使用对数曲线计算：`CLI = 50 * log2(hours + 1) * 1.5`
- 范围：0-100

### CLI 阈值提醒
- 30%：注意力开始分散
- 60%：高负荷状态
- 90%：严重透支
- 100%：达到极限

## 调试功能

在 HDA 设置页面底部有调试信息区域，显示：
- 监控状态（运行中/未启动）
- 最后同步时间
- 监测应用数量
- 手动同步按钮

## 测试步骤

### 1. 基础测试
1. 授权 Screen Time 访问
2. 添加一个测试应用（如 Safari）
3. 使用该应用 5-10 分钟
4. 等待 5 分钟或手动同步
5. 检查 Status 页面是否显示分心记录

### 2. CLI 测试
1. 持续使用监测应用
2. 观察 CLI 数值变化
3. 测试阈值提醒（30/60/90）

### 3. SV 损失测试
1. 记录当前 SV 值
2. 使用监测应用 30 分钟
3. 同步数据后检查 SV 是否减少约 5%

## 已知限制

### iOS 限制
- DeviceActivity Extension 的数据更新频率由系统控制
- 可能存在延迟（通常 5-15 分钟）
- 后台运行时更新频率更低

### 实现限制
- 当前只统计总使用时长，不区分具体应用
- 24 小时后数据自动清零
- 需要用户手动添加监测应用

## 故障排查

### 数据不同步
1. 检查 App Group ID 是否一致
2. 检查 Screen Time 权限是否授权
3. 查看调试信息中的监控状态
4. 尝试手动同步

### CLI 显示为 0
1. 确认已添加监测应用
2. 确认已使用监测应用
3. 等待至少 5 分钟后同步
4. 检查系统设置中的 Screen Time 是否启用

### 分心轨迹为空
1. 确认数据已同步（查看调试信息）
2. 确认有 HDA 使用记录
3. 检查 StatusManager 日志

## 开发注意事项

### Extension 开发
- Extension 无法直接调试
- 使用 NSLog 输出日志
- 在 Console.app 中查看日志

### 数据持久化
- 使用 UserDefaults 存储上次处理的时长
- 避免重复扣除 SV
- 只处理增量数据

### 性能优化
- 定时器使用 5 分钟间隔
- 避免频繁读写共享存储
- 增量计算，不重复处理

## 未来改进

1. 支持按应用分别统计
2. 添加每日/每周报告
3. 自定义 CLI 阈值
4. 更精细的时间段统计
5. 导出使用数据

## 参考资料

- [Apple DeviceActivity Framework](https://developer.apple.com/documentation/deviceactivity)
- [Family Controls Framework](https://developer.apple.com/documentation/familycontrols)
- [App Groups](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups)
