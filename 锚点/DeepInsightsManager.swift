import Foundation
import SwiftUI
import Combine

// MARK: - Data Models

struct SVHeatmapData: Identifiable {
    let id = UUID()
    let hour: Int           // 0-23
    let day: Int            // 周几或日期
    let svValue: Double     // SV值
    let timestamp: Date
    
    var color: Color {
        // 0值：无数据（灰色）
        if svValue == 0 {
            return Color.gray.opacity(0.2)
        }
        // 青色（高）→ 紫色（中）→ 暗红（低）
        else if svValue >= 70 {
            return Color.cyan
        } else if svValue >= 40 {
            let progress = (svValue - 40) / 30
            return Color.cyan.interpolate(to: .purple, progress: 1 - progress)
        } else {
            let progress = svValue / 40
            return Color.purple.interpolate(to: Color.red.opacity(0.6), progress: 1 - progress)
        }
    }
}

struct FocusInterruptionData {
    let totalSessions: Int
    let completedSessions: Int
    let interruptedSessions: Int
    let avgInterruptionTime: TimeInterval
    let commonInterruptionTimes: [TimeInterval]
    
    var interruptionRate: Double {
        guard totalSessions > 0 else { return 0 }
        return Double(interruptedSessions) / Double(totalSessions)
    }
}

struct SVRecoveryData: Identifiable {
    let id = UUID()
    let dropTime: Date
    let recoveryTime: Date
    let duration: TimeInterval
    let dropValue: Double
    let recoveryValue: Double
    
    var durationMinutes: Int {
        return Int(duration / 60)
    }
}

struct MeditationEffectData: Identifiable {
    let id = UUID()
    let sessionDate: Date
    let duration: TimeInterval
    let svBefore: Double
    let svAfter: Double
    let mode: String?
    
    var improvement: Double {
        return svAfter - svBefore
    }
    
    var improvementPercentage: Double {
        guard svBefore > 0 else { return 0 }
        return (improvement / svBefore) * 100
    }
}

// MARK: - Deep Insights Manager

@MainActor
class DeepInsightsManager: ObservableObject {
    static let shared = DeepInsightsManager()
    
    @Published var svHeatmapData: [SVHeatmapData] = []
    @Published var focusInterruptionData: FocusInterruptionData?
    @Published var svRecoveryData: [SVRecoveryData] = []
    @Published var meditationEffectData: [MeditationEffectData] = []
    
    // 洞察文案
    @Published var flowStabilityInsights: [String] = []
    @Published var digitalRelationInsights: [String] = []
    @Published var meditationEchoInsights: [String] = []
    
    private init() {
        // 初始化时加载数据
        Task {
            await refreshAllData()
        }
    }
    
    // MARK: - Data Refresh
    
    func refreshAllData() async {
        await calculateSVHeatmap(period: .week)
        await analyzeFocusInterruptions()
        await calculateRecoveryCurve()
        await analyzeMeditationEffect()
        await generateInsights()
    }
    
    // MARK: - A. 心流稳定性
    
    func calculateSVHeatmap(period: Period) async {
        let statusManager = StatusManager.shared
        var heatmapData: [SVHeatmapData] = []
        
        let calendar = Calendar.current
        let now = Date()
        let daysToAnalyze = period == .week ? 7 : 30
        
        // 从 stabilityLogs 中获取真实的小时级数据
        let logs = statusManager.stabilityLogs
        
        for dayOffset in 0..<daysToAnalyze {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }
            
            // 为每个小时生成数据点
            for hour in 0..<24 {
                guard let hourDate = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: date) else { continue }
                
                // 计算该小时的SV值
                let svValue: Double
                
                if hourDate > now {
                    // 未来时间，不显示数据
                    svValue = 0
                } else {
                    // 找出该小时内的所有SV变化记录
                    let hourLogs = logs.filter { log in
                        let logHour = calendar.component(.hour, from: log.timestamp)
                        return calendar.isDate(log.timestamp, inSameDayAs: date) && logHour == hour
                    }
                    
                    if !hourLogs.isEmpty {
                        // 计算该小时的平均SV值
                        // 使用累积计算：从当前SV值往回推
                        var cumulativeSV = statusManager.stabilityValue
                        
                        // 计算该小时结束时的SV值
                        for log in logs.sorted(by: { $0.timestamp > $1.timestamp }) {
                            if log.timestamp <= hourDate.addingTimeInterval(3600) {
                                // 找到该小时结束时的SV值
                                break
                            }
                            // 往回推算
                            if log.type == .gain {
                                cumulativeSV -= log.amount
                            } else {
                                cumulativeSV += abs(log.amount)
                            }
                        }
                        
                        svValue = max(0, min(100, cumulativeSV))
                    } else {
                        // 该小时没有记录，检查当天是否有任何活动
                        let dayLogs = logs.filter { log in
                            calendar.isDate(log.timestamp, inSameDayAs: date)
                        }
                        
                        if !dayLogs.isEmpty {
                            // 当天有活动，使用当天的历史记录
                            let dayHistory = statusManager.history.first { record in
                                calendar.isDate(record.date, inSameDayAs: date)
                            }
                            svValue = dayHistory?.score ?? 0
                        } else {
                            // 当天完全没有记录，显示为无数据（0值会显示为灰色）
                            svValue = 0
                        }
                    }
                }
                
                heatmapData.append(SVHeatmapData(
                    hour: hour,
                    day: dayOffset,
                    svValue: svValue,
                    timestamp: hourDate
                ))
            }
        }
        
        self.svHeatmapData = heatmapData
    }
    
    func analyzeFocusInterruptions() async {
        let statusManager = StatusManager.shared
        
        // 专注会话定义：
        // 1. 冥想会话：从开始冥想到结束，目标时长由用户设定（5/10/20/30分钟）
        // 2. 其他专注活动：触感锚点、心流铸核、情绪光解等，每次活动算一个会话
        
        let logs = statusManager.stabilityLogs.sorted(by: { $0.timestamp < $1.timestamp })
        
        var totalSessions = 0
        var completedSessions = 0
        var interruptedSessions = 0
        var interruptionTimes: [TimeInterval] = []
        
        // 分析冥想会话
        var meditationStart: Date?
        var meditationDuration: TimeInterval = 0
        
        for i in 0..<logs.count {
            let log = logs[i]
            
            // 检测冥想开始
            if log.type == .gain && log.source.contains("冥想") {
                if meditationStart == nil {
                    // 新的冥想会话开始
                    meditationStart = log.timestamp
                    // 从source中提取目标时长
                    meditationDuration = extractDuration(from: log.source)
                }
            }
            
            // 检测冥想结束或中断
            if meditationStart != nil {
                let nextLog = i + 1 < logs.count ? logs[i + 1] : nil
                
                // 如果下一条记录是loss（被打断）或者是另一个gain（完成）
                if let next = nextLog {
                    if next.type == .loss || (next.type == .gain && !next.source.contains("冥想")) {
                        // 会话结束
                        let actualDuration = next.timestamp.timeIntervalSince(meditationStart!)
                        totalSessions += 1
                        
                        // 判断是否完成：实际时长达到目标时长的80%以上
                        if actualDuration >= meditationDuration * 0.8 {
                            completedSessions += 1
                        } else {
                            interruptedSessions += 1
                            interruptionTimes.append(actualDuration)
                        }
                        
                        meditationStart = nil
                        meditationDuration = 0
                    }
                } else if i == logs.count - 1 {
                    // 最后一条记录，检查是否完成
                    let actualDuration = Date().timeIntervalSince(meditationStart!)
                    totalSessions += 1
                    
                    if actualDuration >= meditationDuration * 0.8 {
                        completedSessions += 1
                    } else {
                        interruptedSessions += 1
                        interruptionTimes.append(actualDuration)
                    }
                }
            }
            
            // 其他专注活动（触感锚点、心流铸核、情绪光解）
            // 这些活动通常较短，只要完成就算成功
            if log.type == .gain && (log.source.contains("触感") || log.source.contains("心流") || log.source.contains("情绪")) {
                totalSessions += 1
                completedSessions += 1
            }
        }
        
        // 如果没有数据，不显示
        guard totalSessions > 0 else {
            self.focusInterruptionData = nil
            return
        }
        
        let avgInterruptionTime = interruptionTimes.isEmpty ? 0 : interruptionTimes.reduce(0, +) / Double(interruptionTimes.count)
        
        let interruptionData = FocusInterruptionData(
            totalSessions: totalSessions,
            completedSessions: completedSessions,
            interruptedSessions: interruptedSessions,
            avgInterruptionTime: avgInterruptionTime,
            commonInterruptionTimes: interruptionTimes.sorted().suffix(3).map { $0 }
        )
        
        self.focusInterruptionData = interruptionData
    }
    
    func calculateRecoveryCurve() async {
        let statusManager = StatusManager.shared
        let svHistory = statusManager.stabilityLogs
        
        // 计算平均值和标准差
        let svValues = svHistory.map { $0.amount }
        guard !svValues.isEmpty else { return }
        
        let average = svValues.reduce(0, +) / Double(svValues.count)
        let variance = svValues.map { pow($0 - average, 2) }.reduce(0, +) / Double(svValues.count)
        let stdDev = sqrt(variance)
        
        // 识别下降事件
        let threshold = average - stdDev
        var recoveryData: [SVRecoveryData] = []
        
        var i = 0
        while i < svHistory.count {
            let log = svHistory[i]
            
            // 检测下降事件
            if log.amount < threshold && log.type == .loss {
                // 查找恢复点
                var j = i + 1
                while j < svHistory.count {
                    if svHistory[j].amount >= average {
                        // 找到恢复点
                        let recovery = SVRecoveryData(
                            dropTime: log.timestamp,
                            recoveryTime: svHistory[j].timestamp,
                            duration: svHistory[j].timestamp.timeIntervalSince(log.timestamp),
                            dropValue: log.amount,
                            recoveryValue: svHistory[j].amount
                        )
                        recoveryData.append(recovery)
                        i = j
                        break
                    }
                    j += 1
                }
            }
            i += 1
        }
        
        self.svRecoveryData = recoveryData
    }
    
    // MARK: - B. 宁静回响
    
    func analyzeMeditationEffect() async {
        let statusManager = StatusManager.shared
        
        // 分析冥想对SV的提升效果
        var effectData: [MeditationEffectData] = []
        
        // 从稳定值日志中找出冥想相关的提升
        let meditationLogs = statusManager.stabilityLogs.filter { log in
            log.type == .gain && log.source.contains("冥想")
        }
        
        // 按时间排序
        let sortedLogs = meditationLogs.sorted { $0.timestamp < $1.timestamp }
        
        // 计算每次冥想前后的SV值
        var cumulativeSV = statusManager.stabilityValue
        
        // 从最新的记录往回推算
        for log in sortedLogs.reversed() {
            let svAfter = cumulativeSV
            let svBefore = cumulativeSV - log.amount
            
            // 提取冥想时长
            let duration = extractDuration(from: log.source)
            
            let effect = MeditationEffectData(
                sessionDate: log.timestamp,
                duration: duration,
                svBefore: max(0, svBefore),
                svAfter: svAfter,
                mode: nil
            )
            effectData.append(effect)
            
            // 更新累积SV值（往前推）
            cumulativeSV = svBefore
        }
        
        // 只保留最近10次
        self.meditationEffectData = effectData.sorted { $0.sessionDate > $1.sessionDate }.prefix(10).map { $0 }
    }
    
    // MARK: - Insights Generation
    
    func generateInsights() async {
        await generateFlowStabilityInsights()
        // Removed calls to generateDigitalRelationInsights and generateMeditationEchoInsights
        // as per instruction to remove ScreenTimeMonitor related code and return empty insights
        // Digital relation insights are now handled by getDigitalRelationInsights()
        // Meditation echo insights are no longer generated here.
    }
    
    func getDigitalRelationInsights() -> [String] {
        // Note: CognitiveLoadTracker removed - digital relation insights deprecated
        // Return empty array as behavior tracking is no longer available
        return []
    }
    
    private func generateFlowStabilityInsights() async {
        var insights: [String] = []
        
        // 分析最脆弱的时段
        if let weakestPeriod = findWeakestTimePeriod() {
            insights.append(String(format: L10n.insightWeakestPeriod, weakestPeriod))
        }
        
        // 分析平均恢复时间
        if !svRecoveryData.isEmpty {
            let avgRecovery = svRecoveryData.map { $0.duration }.reduce(0, +) / Double(svRecoveryData.count)
            let minutes = Int(avgRecovery / 60)
            insights.append(String(format: L10n.insightRecoveryTime, minutes))
        }
        
        // 分析中断模式
        if let interruption = focusInterruptionData {
            let avgMinutes = Int(interruption.avgInterruptionTime / 60)
            insights.append(String(format: L10n.insightInterruption, avgMinutes))
        }
        
        self.flowStabilityInsights = insights
    }
    
    // Digital Relation insights removed - no longer tracking HDA data
    private func generateDigitalRelationInsights() async {
        self.digitalRelationInsights = []
    }
    
    // Meditation Echo insights removed - functionality deprecated
    private func generateMeditationEchoInsights() async {
        self.meditationEchoInsights = []
    }
    
    // MARK: - Helper Methods
    
    private func getSVValueAt(date: Date) -> Double {
        // 从历史数据获取或模拟SV值
        let statusManager = StatusManager.shared
        
        // 简化：使用当前SV值加上一些随机波动
        let baseValue = statusManager.stabilityValue
        let randomVariation = Double.random(in: -20...20)
        return max(0, min(100, baseValue + randomVariation))
    }
    
    private func findWeakestTimePeriod() -> String? {
        // 分析热力图数据，找出SV值最低的时段
        guard !svHeatmapData.isEmpty else { return nil }
        
        let sortedData = svHeatmapData.sorted { $0.svValue < $1.svValue }
        if let weakest = sortedData.first {
            let hour = weakest.hour
            if hour >= 15 && hour <= 17 {
                return L10n.timeAfternoon
            } else if hour >= 21 && hour <= 23 {
                return L10n.timeNight
            } else if hour >= 9 && hour <= 11 {
                return L10n.timeMorning
            }
        }
        
        return nil
    }
    
    private func extractCategory(from source: String) -> String {
        if source.contains("社交") || source.contains("Social") {
            return L10n.categorySocial
        } else if source.contains("娱乐") || source.contains("Entertainment") {
            return L10n.categoryEntertainment
        } else {
            // 默认归类为娱乐
            return L10n.categoryEntertainment
        }
    }
    
    private func extractDuration(from source: String) -> TimeInterval {
        // 从source字符串中提取时长
        // 例如："冥想 (10分钟)" -> 600秒
        if let range = source.range(of: "\\d+", options: .regularExpression) {
            let numberString = String(source[range])
            if let minutes = Int(numberString) {
                return TimeInterval(minutes * 60)
            }
        }
        return 600 // 默认10分钟
    }
    
    enum Period {
        case week
        case month
    }
}

// MARK: - Color Extension

extension Color {
    func interpolate(to color: Color, progress: Double) -> Color {
        let progress = max(0, min(1, progress))
        
        let fromComponents = UIColor(self).cgColor.components ?? [0, 0, 0, 1]
        let toComponents = UIColor(color).cgColor.components ?? [0, 0, 0, 1]
        
        let r = fromComponents[0] + (toComponents[0] - fromComponents[0]) * progress
        let g = fromComponents[1] + (toComponents[1] - fromComponents[1]) * progress
        let b = fromComponents[2] + (toComponents[2] - fromComponents[2]) * progress
        
        return Color(red: r, green: g, blue: b)
    }
}
