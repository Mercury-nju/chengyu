# 快速集成指南 - 认知负荷追踪系统

## 已完成 ✅

1. **创建了CognitiveLoadTracker.swift** - 核心追踪器
2. **App启动追踪** - __App.swift中已添加
3. **冥想追踪** - CalmView.swift中已添加

## 需要手动完成的步骤

### 步骤1：TouchAnchor追踪
在 `TouchAnchorSessionView.swift` 中找到完成逻辑（通常在holdProgress达到1.0时），添加：

```swift
CognitiveLoadTracker.shared.trackTouchAnchorCompleted()
```

### 步骤2：FlowSession追踪  
在 `MindfulRevealSessionView.swift` 中找到完成逻辑，添加：

```swift
CognitiveLoadTracker.shared.trackFlowSessionCompleted()
```

### 步骤3：更新StatusView
替换HDA相关UI为新的认知压力显示。在StatusView.swift中：

```swift
// 获取认知负荷数据
let tracker = CognitiveLoadTracker.shared
let cli = tracker.cognitiveLoadIndex
let status = tracker.getCLIStatus()
let insights = tracker.getInsights()

// 显示UI
VStack {
    Text("认知压力指数")
    Text("\(Int(cli))")
    Text(status)
    
    ForEach(insights, id: \.self) { insight in
        Text(insight)
    }
}
```

### 步骤4：测试流程

1. Clean Build Folder
2. Archive
3. 应该能成功（无Family Controls错误）
4. 上传TestFlight

## 完整功能

- ✅ 追踪应用打开次数
- ✅ 追踪后台切换
- ✅ 追踪冥想完成/中断
- ⏳ 追踪TouchAnchor完成
- ⏳ 追踪FlowSession完成
- ⏳ 显示认知压力指数
- ⏳ 显示行为洞察

## 优势

- 无需Family Controls权限
- 立即可以Archive上传
- 提供有价值的用户洞察
- 容易通过App Store审核

## 后续优化

等Family Controls Distribution权限批准后，可以：
1. 恢复entitlements配置
2. 集成真实的屏幕时间数据
3. 提供更精确的认知负荷计算
4. 发布更新版本
