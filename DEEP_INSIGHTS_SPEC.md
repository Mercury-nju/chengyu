# 深度洞察功能设计文档

## 🎯 功能概述

在洞察页面（StatusView）添加"深度解析"板块，提供三个核心维度的数据可视化和现象洞察。

## 📊 三大核心维度

### A. 心流稳定性（核心维度）

#### 1. SV 值波动热力图
**数据展示**：
- X轴：24小时时间轴
- Y轴：周/月维度
- 颜色：青色（高）→ 紫色（中）→ 暗红（低）
- 视觉：光球的明暗渐变

**数据需求**：
```swift
struct SVHeatmapData {
    let hour: Int           // 0-23
    let day: Int            // 周几或日期
    let svValue: Double     // SV值
    let color: Color        // 根据SV值计算的颜色
}
```

#### 2. 专注周期中断率图
**数据展示**：
- 环形图或流线图
- 显示中断比例
- 标注最常中断的时长

**数据需求**：
```swift
struct FocusInterruptionData {
    let totalSessions: Int      // 总专注次数
    let completedSessions: Int  // 完成的次数
    let interruptedSessions: Int // 中断的次数
    let avgInterruptionTime: TimeInterval // 平均中断时长
    let commonInterruptionTimes: [TimeInterval] // 常见中断时长
}
```

#### 3. SV 恢复曲线
**数据展示**：
- 曲线图
- 显示从低谷到恢复的时间
- 平均恢复时长

**数据需求**：
```swift
struct SVRecoveryData {
    let dropTime: Date          // 下降时间
    let recoveryTime: Date      // 恢复时间
    let duration: TimeInterval  // 恢复时长
    let dropValue: Double       // 下降值
    let recoveryValue: Double   // 恢复值
}
```

**洞察文案**：
- "你的心流之光，在午后 3 点至 5 点间最为脆弱。"
- "当你的心流陷入混沌，通常需要 X 分钟才能重归澄澈。"
- "在最近的专注旅程中，你常在 X 分钟后，感到心境的波动。"

### B. 数字共生关系（HDA 关联）

#### 1. HDA 触发 SV 下降分布
**数据展示**：
- 饼图或柱状图
- 按应用类型分类（社交、娱乐、资讯）

**数据需求**：
```swift
struct HDAImpactData {
    let appCategory: String     // 应用类型
    let impactCount: Int        // 影响次数
    let avgSVDrop: Double       // 平均SV下降值
    let totalUsageTime: TimeInterval // 总使用时长
}
```

#### 2. HDA 使用时长与 SV 趋势对比
**数据展示**：
- 双轴折线图
- 左轴：HDA 使用时长
- 右轴：SV 值

#### 3. 数字分心热力图
**数据展示**：
- 类似 SV 热力图
- 侧重分心发生的时间点和强度

**洞察文案**：
- "你的心流之镜，对社交涟漪尤其敏感。"
- "当数字的喧嚣占据 X 分钟，你的心境之光便会黯淡。"
- "在某些时段，数字的引力显得格外强大。"

### C. 宁静回响（冥想实践反馈）

#### 1. 冥想后 SV 提升幅度
**数据展示**：
- 柱状图或散点图
- 显示每次冥想后的 SV 提升

**数据需求**：
```swift
struct MeditationEffectData {
    let sessionDate: Date
    let duration: TimeInterval
    let svBefore: Double
    let svAfter: Double
    let improvement: Double
    let mode: String? // 引导模式
}
```

#### 2. 冥想频率与 SV 基线变化
**数据展示**：
- 折线图
- 显示长期趋势

#### 3. 引导模式效果对比
**数据展示**：
- 柱状图
- 对比不同模式的效果

**洞察文案**：
- "冥想，为你带来 X% 的澄澈能量回馈。"
- "持续的宁静实践，已让你的心流基线悄然上扬。"
- "[某种引导模式]，似乎更能触及你内心的平静之源。"

## 🎨 视觉设计原则

### 光影美学
- 深色背景（纯黑或深灰）
- 发光线条和文字
- 青色到紫色的渐变
- 柔和的阴影和光晕

### 图表样式
```swift
// 颜色方案
let highSV = Color.cyan          // 高SV值
let mediumSV = Color.purple      // 中等SV值
let lowSV = Color.red.opacity(0.6) // 低SV值

// 发光效果
.shadow(color: .cyan.opacity(0.5), radius: 10)
.shadow(color: .purple.opacity(0.3), radius: 15)
```

### 文案风格
- 富有哲思和诗意
- 描述性而非命令性
- 使用隐喻和意象
- 避免直接的数字堆砌

## 🔧 技术实现

### 数据模型
```swift
// 深度洞察数据管理器
class DeepInsightsManager: ObservableObject {
    @Published var svHeatmapData: [SVHeatmapData] = []
    @Published var focusInterruptionData: FocusInterruptionData?
    @Published var svRecoveryData: [SVRecoveryData] = []
    @Published var hdaImpactData: [HDAImpactData] = []
    @Published var meditationEffectData: [MeditationEffectData] = []
    
    // 计算方法
    func calculateSVHeatmap(period: Period) -> [SVHeatmapData]
    func analyzeFocusInterruptions() -> FocusInterruptionData
    func calculateRecoveryCurve() -> [SVRecoveryData]
    func analyzeHDAImpact() -> [HDAImpactData]
    func analyzeMeditationEffect() -> [MeditationEffectData]
}
```

### 算法逻辑

#### SV 恢复力算法
```swift
func detectSVDropAndRecovery() -> [SVRecoveryData] {
    // 1. 计算SV平均值和标准差
    let average = calculateAverage(svHistory)
    let stdDev = calculateStandardDeviation(svHistory)
    
    // 2. 识别下降事件（跌破平均值一个标准差）
    let threshold = average - stdDev
    let dropEvents = svHistory.filter { $0.value < threshold }
    
    // 3. 计算恢复时间
    var recoveryData: [SVRecoveryData] = []
    for drop in dropEvents {
        if let recovery = findRecoveryPoint(after: drop, threshold: average) {
            let duration = recovery.time - drop.time
            recoveryData.append(SVRecoveryData(
                dropTime: drop.time,
                recoveryTime: recovery.time,
                duration: duration,
                dropValue: drop.value,
                recoveryValue: recovery.value
            ))
        }
    }
    
    return recoveryData
}
```

#### HDA 关联分析
```swift
func analyzeHDACorrelation() -> [HDAImpactData] {
    // 1. 获取HDA使用记录
    let hdaEvents = getHDAUsageEvents()
    
    // 2. 匹配SV值变化
    var impactData: [String: HDAImpactData] = [:]
    
    for event in hdaEvents {
        let svBefore = getSVValue(at: event.startTime)
        let svAfter = getSVValue(at: event.endTime)
        let drop = svBefore - svAfter
        
        if drop > 0 {
            // 记录影响
            let category = event.appCategory
            if var data = impactData[category] {
                data.impactCount += 1
                data.avgSVDrop = (data.avgSVDrop + drop) / 2
                data.totalUsageTime += event.duration
                impactData[category] = data
            } else {
                impactData[category] = HDAImpactData(
                    appCategory: category,
                    impactCount: 1,
                    avgSVDrop: drop,
                    totalUsageTime: event.duration
                )
            }
        }
    }
    
    return Array(impactData.values)
}
```

## 📱 UI 组件

### 1. 深度洞察入口
在 StatusView 中添加入口卡片

### 2. 深度洞察页面
```swift
struct DeepInsightsView: View {
    @StateObject private var insightsManager = DeepInsightsManager()
    @State private var selectedTab: InsightTab = .flowStability
    
    enum InsightTab {
        case flowStability    // 心流稳定性
        case digitalRelation  // 数字共生关系
        case meditationEcho   // 宁静回响
    }
    
    var body: some View {
        // 实现
    }
}
```

### 3. 图表组件
- SVHeatmapChart
- FocusInterruptionChart
- SVRecoveryCurveChart
- HDAImpactChart
- MeditationEffectChart

## 🎯 实现优先级

### Phase 1: 基础框架（当前）
- [x] 创建设计文档
- [ ] 创建 DeepInsightsManager
- [ ] 创建基础 UI 框架
- [ ] 添加入口卡片

### Phase 2: 心流稳定性
- [ ] SV 值波动热力图
- [ ] 专注周期中断率图
- [ ] SV 恢复曲线
- [ ] 洞察文案生成

### Phase 3: 数字共生关系
- [ ] HDA 触发 SV 下降分布
- [ ] HDA 使用时长与 SV 趋势对比
- [ ] 数字分心热力图
- [ ] 洞察文案生成

### Phase 4: 宁静回响
- [ ] 冥想后 SV 提升幅度
- [ ] 冥想频率与 SV 基线变化
- [ ] 引导模式效果对比
- [ ] 洞察文案生成

### Phase 5: 优化和完善
- [ ] 交互式探索
- [ ] 现象解读小卡片
- [ ] 性能优化
- [ ] 动画效果

## 💡 注意事项

1. **数据隐私**：所有数据本地存储和计算
2. **性能优化**：大量数据需要异步处理
3. **渐进式实现**：先实现基础功能，再逐步完善
4. **会员功能**：深度洞察可以作为会员专属功能

## 📝 下一步

由于这是一个非常庞大的功能，建议：
1. 先实现基础框架和入口
2. 逐步实现每个维度的数据收集
3. 最后完善图表和洞察文案

是否开始实现 Phase 1 的基础框架？
