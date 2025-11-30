import SwiftUI
import Combine
import UserNotifications

class StatusManager: ObservableObject {
    static let shared = StatusManager()
    
    // MARK: - Core Data Properties (Daily) - Now Persisted
    @AppStorage("anchorSessionsCompleted") var anchorSessionsCompleted: Int = 0
    @AppStorage("readingTimeTotal") var readingTimeTotal: Double = 0
    @AppStorage("readingTimeEffective") var readingTimeEffective: Double = 0
    @AppStorage("voiceLogsValid") var voiceLogsValid: Int = 0
    @AppStorage("distractionIntercepts") var distractionIntercepts: Int = 0
    @AppStorage("totalThoughtOutput") var totalThoughtOutput: Int = 0
    @AppStorage("avgReadingDepth") var avgReadingDepth: Double = 0
    
    // Daily First Completion Tracking (for stability rewards)
    @AppStorage("hasMeditatedToday") private var hasMeditatedToday: Bool = false
    @AppStorage("hasReadToday") private var hasReadToday: Bool = false
    @AppStorage("hasRecordedEmotionToday") private var hasRecordedEmotionToday: Bool = false
    @AppStorage("sphereMaterial") var sphereMaterial: String = "default"
    
    // MARK: - MOF Model Properties
    @AppStorage("stabilityValue") var stabilityValue: Double = 50.0 // Default 50%
    @AppStorage("lastDecayDate") var lastDecayDate: Double = Date().timeIntervalSince1970
    
    // Targets (Daily Goals)
    let anchorTarget: Int = 3
    let voiceTarget: Int = 3
    
    // MARK: - CRDS (Cognitive Resource Decay System)
    
    /// Current decay multiplier (1.0 = normal, 7.5 = accelerated during distraction)
    @Published var decayMultiplier: Double = 1.0
    
    // MARK: - Computed Metrics
    
    // 1. Core Stability Index (0-100)
    var coreStabilityIndex: Double {
        // Anchor Score (30%): Completed / Target
        let anchorScore = min(Double(anchorSessionsCompleted) / Double(anchorTarget), 1.0) * 100
        
        // Reading Score (40%): Effective Time / Total Time
        let readingScore = readingTimeTotal > 0 ? (readingTimeEffective / readingTimeTotal) * 100 : 0
        
        // Voice Score (30%): Valid Logs / Target
        let voiceScore = min(Double(voiceLogsValid) / Double(voiceTarget), 1.0) * 100
        
        let weightedScore = (anchorScore * 0.3) + (readingScore * 0.4) + (voiceScore * 0.3)
        return weightedScore
    }
    
    // 2. Total Flow Time
    var totalFlowTime: TimeInterval {
        // Anchor duration (assuming 3 mins per session) + Effective Reading Time
        return (Double(anchorSessionsCompleted) * 180) + readingTimeEffective
    }
    
    // MARK: - Historical Data (Dynamic)
    struct DailyRecord: Identifiable, Codable {
        let id = UUID()
        let day: String
        let score: Double
        let date: Date
    }
    
    struct StabilityLog: Identifiable, Codable {
        let id = UUID()
        let timestamp: Date
        let amount: Double
        let source: String
        let type: LogType
        
        enum LogType: String, Codable {
            case gain
            case loss
        }
    }
    
    @AppStorage("historicalRecords") private var historicalRecordsData: Data = Data()
    @AppStorage("stabilityLogs") private var stabilityLogsData: Data = Data()
    
    private var _stabilityLogsCache: [StabilityLog]?
    private var _logsLoaded = false
    
    var stabilityLogs: [StabilityLog] {
        get {
            if !_logsLoaded {
                _logsLoaded = true
                if let decoded = try? JSONDecoder().decode([StabilityLog].self, from: stabilityLogsData) {
                    _stabilityLogsCache = decoded
                } else {
                    _stabilityLogsCache = []
                }
            }
            return _stabilityLogsCache ?? []
        }
        set {
            _stabilityLogsCache = newValue
            if let encoded = try? JSONEncoder().encode(newValue) {
                stabilityLogsData = encoded
            }
            objectWillChange.send()
        }
    }
    
    var history: [DailyRecord] {
        get {
            if let decoded = try? JSONDecoder().decode([DailyRecord].self, from: historicalRecordsData) {
                // Return last 7 days
                return Array(decoded.suffix(7))
            }
            // Default data if no history
            return [
                DailyRecord(day: "Mon", score: 45, date: Date().addingTimeInterval(-6*86400)),
                DailyRecord(day: "Tue", score: 52, date: Date().addingTimeInterval(-5*86400)),
                DailyRecord(day: "Wed", score: 38, date: Date().addingTimeInterval(-4*86400)),
                DailyRecord(day: "Thu", score: 65, date: Date().addingTimeInterval(-3*86400)),
                DailyRecord(day: "Fri", score: 72, date: Date().addingTimeInterval(-2*86400)),
                DailyRecord(day: "Sat", score: 85, date: Date().addingTimeInterval(-1*86400)),
                DailyRecord(day: "Today", score: coreStabilityIndex, date: Date())
            ]
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                historicalRecordsData = encoded
            }
        }
    }
    
    // MARK: - Daily Reset Logic
    @AppStorage("lastResetDate") private var lastResetDate: Double = Date().timeIntervalSince1970
    
    func checkDailyReset() {
        let lastDate = Date(timeIntervalSince1970: lastResetDate)
        if !Calendar.current.isDateInToday(lastDate) {
            // It's a new day, reset counters
            anchorSessionsCompleted = 0
            readingTimeTotal = 0
            readingTimeEffective = 0
            voiceLogsValid = 0
            distractionIntercepts = 0
            totalThoughtOutput = 0
            
            // Reset daily first-completion flags
            hasMeditatedToday = false
            hasReadToday = false
            hasRecordedEmotionToday = false
            
            // Update reset date
            lastResetDate = Date().timeIntervalSince1970
            
            // Force UI update
            objectWillChange.send()
        }
    }
    
    // MARK: - MOF Decay Logic
    private func calculateStabilityDecay() {
        let lastDate = Date(timeIntervalSince1970: lastDecayDate)
        let now = Date()
        
        // Check if more than 24 hours have passed since last decay check
        // Or if it's a new calendar day (simplifying to daily check for now)
        if !Calendar.current.isDateInToday(lastDate) {
            let daysPassed = Calendar.current.dateComponents([.day], from: lastDate, to: now).day ?? 1
            
            if daysPassed > 0 {
                // Decay 15% per day
                let decayAmount = 15.0 * Double(daysPassed)
                let actualDecay = min(stabilityValue, decayAmount)
                stabilityValue = max(0, stabilityValue - decayAmount)
                
                if actualDecay > 0 {
                    addLog(amount: -actualDecay, source: "每日自然衰减", type: .loss)
                }
                
                // Update last decay date to today
                lastDecayDate = now.timeIntervalSince1970
            }
        }
    }
    
    func incrementStability(amount: Double, source: String = "未知来源") {
        let oldVal = stabilityValue
        stabilityValue = min(100, stabilityValue + amount)
        let actualGain = stabilityValue - oldVal
        
        if actualGain > 0 {
            addLog(amount: actualGain, source: source, type: .gain)
        }
        updateTodayRecord()
    }
    
    private func addLog(amount: Double, source: String, type: StabilityLog.LogType) {
        let log = StabilityLog(timestamp: Date(), amount: amount, source: source, type: type)
        var logs = stabilityLogs  // This triggers lazy loading
        logs.insert(log, at: 0)
        
        // Keep only last 50 logs
        if logs.count > 50 {
            logs = Array(logs.prefix(50))
        }
        
        stabilityLogs = logs  // This triggers auto-save
    }
    
    
    // MARK: - CRDS Methods (New System - Batch Adjustment)
    
    /// Apply HDA usage impact to stability value (CRDS batch adjustment)
    /// - Parameter duration: Total HDA usage duration in seconds since last sync
    func applyHDAImpact(duration: TimeInterval) {
        guard duration > 0 else { return }
        
        // 计算认知负荷指数 (CLI)
        // 每小时 HDA 使用 = 10% SV 损失
        let hoursUsed = duration / 3600.0
        let svLoss = hoursUsed * 10.0
        
        let previousSV = stabilityValue
        stabilityValue = max(0, stabilityValue - svLoss)
        
        // 记录日志
        let minutesUsed = Int(duration / 60)
        addLog(
            amount: -svLoss,
            source: "高多巴胺应用使用 (\(minutesUsed)分钟)",
            type: .loss
        )
        
        NSLog("[StatusManager] HDA impact applied: -\(String(format: "%.2f", svLoss))% for \(minutesUsed) minutes of usage")
    }
    
    // CLI 阈值追踪
    @AppStorage("lastCLIThreshold") private var lastCLIThreshold: Int = 0
    @Published var shouldShowCLIAlert: Bool = false
    @Published var cliAlertMessage: String = ""
    
    /// 计算认知负荷指数 (Cognitive Load Index)
    /// 基于近期 HDA 使用情况
    func calculateCLI() -> Double {
        // 查找最近的 HDA 相关日志
        let hdaLogs = stabilityLogs.filter { $0.source.contains("高多巴胺") }
        
        guard !hdaLogs.isEmpty else {
            // 如果没有使用记录，重置阈值
            if lastCLIThreshold != 0 {
                lastCLIThreshold = 0
            }
            return 0
        }
        
        // 计算最近 24 小时的总损失
        let oneDayAgo = Date().addingTimeInterval(-86400)
        let recentLoss = hdaLogs
            .filter { $0.timestamp > oneDayAgo }
            .reduce(0) { $0 + abs($1.amount) }
        
        // 优化后的 CLI 计算：
        // 0-30分钟: 低负荷 (0-25)
        // 30-90分钟: 中等负荷 (25-50)
        // 90-180分钟: 高负荷 (50-75)
        // 180分钟+: 极高负荷 (75-100)
        
        // recentLoss 是 SV 损失百分比
        // 转换为使用时长（小时）: loss / 10
        let hoursUsed = recentLoss / 10.0
        
        // 使用对数曲线，让增长更平缓
        // CLI = 50 * log2(hours + 1) * 1.5
        let cli = 50 * log2(hoursUsed + 1) * 1.5
        
        let finalCLI = min(cli, 100)
        
        // 检查是否需要触发提醒
        checkCLIThreshold(cli: finalCLI)
        
        return finalCLI
    }
    
    /// 检查 CLI 阈值并触发提醒
    private func checkCLIThreshold(cli: Double) {
        let currentThreshold: Int
        
        if cli >= 100 {
            currentThreshold = 100
        } else if cli >= 90 {
            currentThreshold = 90
        } else if cli >= 60 {
            currentThreshold = 60
        } else if cli >= 30 {
            currentThreshold = 30
        } else {
            currentThreshold = 0
        }
        
        // 只在跨越新阈值时提醒（避免重复提醒）
        if currentThreshold > lastCLIThreshold && currentThreshold > 0 {
            lastCLIThreshold = currentThreshold
            triggerCLIAlert(threshold: currentThreshold)
        } else if currentThreshold < lastCLIThreshold {
            // CLI 下降时，更新阈值但不提醒
            lastCLIThreshold = currentThreshold
        }
    }
    
    /// 触发 CLI 提醒
    private func triggerCLIAlert(threshold: Int) {
        switch threshold {
        case 30:
            cliAlertMessage = "认知负荷已达 30%\n\n注意力开始分散。\n建议暂停使用高多巴胺应用，\n来澄域进行短暂冥想。"
        case 60:
            cliAlertMessage = "认知负荷已达 60%\n\n大脑处于高负荷状态。\n强烈建议休息 10 分钟，\n或进行一次触感锚点练习。"
        case 90:
            cliAlertMessage = "认知负荷已达 90%\n\n警告：认知资源严重透支！\n请立即停止使用分心应用，\n进行深度休息或冥想恢复。"
        case 100:
            cliAlertMessage = "认知负荷已达极限\n\n你的大脑需要休息。\n建议关闭所有应用，\n进行至少 15 分钟的冥想或休息。"
        default:
            return
        }
        
        shouldShowCLIAlert = true
        
        // 发送本地通知（如果应用在后台）
        sendCLINotification(threshold: threshold)
    }
    
    /// 发送 CLI 通知
    private func sendCLINotification(threshold: Int) {
        let content = UNMutableNotificationContent()
        content.title = "认知负荷警告"
        content.body = cliAlertMessage.replacingOccurrences(of: "\n", with: " ")
        content.sound = .default
        content.badge = 1
        
        let request = UNNotificationRequest(
            identifier: "cli_threshold_\(threshold)",
            content: content,
            trigger: nil // 立即发送
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending CLI notification: \(error)")
            }
        }
    }
    
    /// 重置 CLI 提醒状态
    func dismissCLIAlert() {
        shouldShowCLIAlert = false
    }

    
    // MARK: - UI Status Helpers
    var isTouchCompleted: Bool { anchorSessionsCompleted > 0 }
    var isReadingCompleted: Bool { readingTimeEffective > 30 } // Threshold: 30s reading
    var isVoiceCompleted: Bool { voiceLogsValid > 0 }
    
    func resetDailyStats() {
        anchorSessionsCompleted = 0
        readingTimeTotal = 0
        readingTimeEffective = 0
        voiceLogsValid = 0
        distractionIntercepts = 0
        totalThoughtOutput = 0
        updateTodayRecord()
    }
    
    private init() {
        // Note: stabilityLogs will be lazy-loaded on first access
        checkDailyReset()
        calculateStabilityDecay() // Check for decay on launch
        // Update today's record when initialized
        updateTodayRecord()
    }
    
    // MARK: - Recording Methods
    
    func recordAnchorSession(duration: TimeInterval) {
        checkDailyReset() // Ensure we are on the right day
        anchorSessionsCompleted += 1
        
        // Only award stability on first completion of the day
        if anchorSessionsCompleted == 1 {
            incrementStability(amount: 5.0, source: "触感锚点 (首次完成)")
        }
        
        updateTodayRecord()
    }
    
    func recordReadingSession(totalTime: TimeInterval, effectiveTime: TimeInterval) {
        checkDailyReset()
        readingTimeTotal += totalTime
        readingTimeEffective += effectiveTime
        
        // Simulate depth update (simple average for demo)
        let newDepth = Double.random(in: 3.0...8.0)
        if avgReadingDepth == 0 {
            avgReadingDepth = newDepth
        } else {
            avgReadingDepth = (avgReadingDepth + newDepth) / 2
        }

        // Only award stability on first completion of the day
        if !hasReadToday {
            incrementStability(amount: 8.0, source: "心流铸核 (首次完成)")
            hasReadToday = true
        }
        
        updateTodayRecord()
    }
    
    func recordVoiceLog(duration: TimeInterval, wordCount: Int) {
        checkDailyReset()
        if duration > 5 { // Lowered threshold
            voiceLogsValid += 1
            totalThoughtOutput += wordCount
            incrementStability(amount: 7.0, source: "情绪光解") // +7% SV
        }
        updateTodayRecord()
    }
    
    struct EmotionalLog: Codable, Identifiable {
        let id = UUID()
        let date: Date
        let name: String
        let duration: TimeInterval
    }
    
    @AppStorage("emotionalLogs") private var emotionalLogsData: Data = Data()
    
    func recordEmotionalLog(name: String, duration: TimeInterval) {
        checkDailyReset()
        voiceLogsValid += 1
        
        // Only award stability on first completion of the day
        if !hasRecordedEmotionToday {
            incrementStability(amount: 7.0, source: "情绪光解 (首次完成)")
            hasRecordedEmotionToday = true
        }
        
        // Save Log
        var logs: [EmotionalLog] = []
        if let decoded = try? JSONDecoder().decode([EmotionalLog].self, from: emotionalLogsData) {
            logs = decoded
        }
        logs.append(EmotionalLog(date: Date(), name: name, duration: duration))
        if let encoded = try? JSONEncoder().encode(logs) {
            emotionalLogsData = encoded
        }
        
        updateTodayRecord()
    }
    
    func incrementIntercept() {
        checkDailyReset()
        distractionIntercepts += 1
        updateTodayRecord()
    }
    
    // MARK: - CALM Feature
    
    func recordMeditationSession(duration: TimeInterval) {
        checkDailyReset()
        
        // Only award stability on first completion of the day
        if !hasMeditatedToday {
            // Reward: 10 minutes = 10% SV
            // Formula: duration (seconds) / 60.0
            let minutes = duration / 60.0
            let svReward = min(minutes, 30.0) // Cap at 30% per session
            
            incrementStability(amount: svReward, source: "冥想 (\(Int(minutes))分钟, 首次完成)")
            hasMeditatedToday = true
        }
        
        updateTodayRecord()
    }
    
    // Update today's record in history
    private func updateTodayRecord() {
        // Get all stored records (not just last 7 days)
        var allRecords: [DailyRecord] = []
        if let decoded = try? JSONDecoder().decode([DailyRecord].self, from: historicalRecordsData) {
            allRecords = decoded
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        
        // Remove today's old record if exists
        allRecords.removeAll { Calendar.current.isDate($0.date, inSameDayAs: today) }
        
        // Add updated record
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        let dayName = dayFormatter.string(from: Date())
        
        allRecords.append(DailyRecord(day: dayName, score: coreStabilityIndex, date: today))
        
        // Save all records (not just last 7)
        if let encoded = try? JSONEncoder().encode(allRecords) {
            historicalRecordsData = encoded
        }
    }
    
    // Helper for formatting time
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes)"
    }
}
