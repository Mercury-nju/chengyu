import SwiftUI
import Combine
import UserNotifications

class StatusManager: ObservableObject {
    static let shared = StatusManager()
    
    // MARK: - Core Data Properties (Daily) - Now Persisted
    @AppStorage("anchorSessionsCompleted") var anchorSessionsCompleted: Int = 0
    @AppStorage("voiceLogsValid") var voiceLogsValid: Int = 0
    
    // Daily First Completion Tracking (for stability rewards)
    @AppStorage("hasMeditatedToday") private var hasMeditatedToday: Bool = false
    @AppStorage("hasCompletedFlowToday") private var hasCompletedFlowToday: Bool = false
    @AppStorage("hasRecordedEmotionToday") private var hasRecordedEmotionToday: Bool = false
    @AppStorage("sphereMaterial") var sphereMaterial: String = "default"
    
    // MARK: - MOF Model Properties
    @AppStorage("stabilityValue") var stabilityValue: Double = 50.0 // Default 50%
    @AppStorage("lastDecayDate") var lastDecayDate: Double = Date().timeIntervalSince1970
    
    // Targets (Daily Goals)
    let anchorTarget: Int = 3
    let voiceTarget: Int = 3
    
    // MARK: - Computed Metrics
    // Total Flow Time (meditation + anchor sessions)
    var totalFlowTime: TimeInterval {
        // Anchor duration (assuming 3 mins per session)
        return Double(anchorSessionsCompleted) * 180
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
                DailyRecord(day: "Today", score: stabilityValue, date: Date())
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
            voiceLogsValid = 0
            
            // Reset daily first-completion flags
            hasMeditatedToday = false
            hasCompletedFlowToday = false
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
                    addLog(amount: -actualDecay, source: L10n.isUSVersion ? "Daily Decay" : "每日自然衰减", type: .loss)
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
    
    


    
    // MARK: - UI Status Helpers
    var isTouchCompleted: Bool { anchorSessionsCompleted > 0 }
    var isFlowCompleted: Bool { hasCompletedFlowToday }
    var isVoiceCompleted: Bool { voiceLogsValid > 0 }
    
    func resetDailyStats() {
        anchorSessionsCompleted = 0
        voiceLogsValid = 0
        hasCompletedFlowToday = false
        updateTodayRecord()
    }
    
    // MARK: - Flow Completion
    func recordFlowCompletion() {
        checkDailyReset()
        
        // Only award stability on first completion of the day
        if !hasCompletedFlowToday {
            incrementStability(amount: 8.0, source: L10n.isUSVersion ? "Flow Forging (First)" : "心流铸核 (首次完成)")
            hasCompletedFlowToday = true
        }
        
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
            incrementStability(amount: 5.0, source: L10n.isUSVersion ? "Touch Anchor (First)" : "触感锚点 (首次完成)")
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
            incrementStability(amount: 7.0, source: L10n.isUSVersion ? "Emotional Release (First)" : "情绪光解 (首次完成)")
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
    

    
    // MARK: - CALM Feature
    
    func recordMeditationSession(duration: TimeInterval) {
        checkDailyReset()
        
        // Only award stability on first completion of the day
        if !hasMeditatedToday {
            // Reward: 10 minutes = 10% SV
            // Formula: duration (seconds) / 60.0
            let minutes = duration / 60.0
            let svReward = min(minutes, 30.0) // Cap at 30% per session
            
            incrementStability(amount: svReward, source: L10n.isUSVersion ? "Meditation (\(Int(minutes))min, First)" : "冥想 (\(Int(minutes))分钟, 首次完成)")
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
        
        allRecords.append(DailyRecord(day: dayName, score: stabilityValue, date: today))
        
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
