import Foundation
import FamilyControls
import DeviceActivity
import ManagedSettings
import Combine
import SwiftUI

extension DeviceActivityReport.Context {
    static let totalActivity = Self("Total Activity")
}

extension DeviceActivityName {
    static let hdaUsage = Self("hdaUsage")
}

extension DeviceActivityEvent.Name {
    static let threshold = Self("threshold")
}

/// 监测 Screen Time 数据并计算 HDA 使用影响
@MainActor
class ScreenTimeMonitor: ObservableObject {
    static let shared = ScreenTimeMonitor()
    
    @Published var isAuthorized: Bool = false
    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published var lastSyncDate: Date?
    @Published var isMonitoring: Bool = false
    @Published var todayHDAUsage: TimeInterval = 0
    
    private let authorizationCenter = AuthorizationCenter.shared
    private let deviceActivityCenter = DeviceActivityCenter()
    private var cancellables = Set<AnyCancellable>()
    private var syncTimer: Timer?
    
    private init() {
        checkAuthorizationStatus()
        startPeriodicSync()
    }
    
    /// 检查授权状态
    func checkAuthorizationStatus() {
        let status = authorizationCenter.authorizationStatus
        self.authorizationStatus = status
        print("🔐 [ScreenTimeMonitor] Authorization status: \(status)")
        
        switch status {
        case .approved:
            isAuthorized = true
            print("✅ [ScreenTimeMonitor] Screen Time authorized!")
        default:
            isAuthorized = false
            print("❌ [ScreenTimeMonitor] Screen Time NOT authorized. Current status: \(status)")
        }
    }
    
    /// 请求 Screen Time 权限
    func requestAuthorization() async throws {
        do {
            try await authorizationCenter.requestAuthorization(for: .individual)
            await MainActor.run {
                self.isAuthorized = true
            }
        } catch {
            await MainActor.run {
                self.isAuthorized = false
            }
            throw error
        }
    }
    
    /// 当前的应用选择（用于过滤）
    private var currentSelection = FamilyActivitySelection()
    
    /// App Group 标识符（根据版本使用不同的 ID）
    private var appGroupIdentifier: String {
        #if US_VERSION
        return "group.com.mercury.serenity.us"
        #else
        return "group.com.mercury.chengyu.cn"
        #endif
    }
    
    /// 更新过滤器（从 HDAManager 调用）
    func updateFilter(with selection: FamilyActivitySelection) {
        currentSelection = selection
        // 重新启动监控以应用新的过滤器
        Task {
            await startMonitoring()
            print("Filter updated with \(selection.applications.count) apps and \(selection.categories.count) categories.")
        }
    }
    
    /// 启动监控（使用事件触发模式）
    func startMonitoring() async {
        guard isAuthorized else {
            print("❌ [ScreenTimeMonitor] Not authorized, cannot start monitoring")
            return
        }
        
        guard !currentSelection.applications.isEmpty else {
            print("⚠️ [ScreenTimeMonitor] No apps selected for monitoring")
            return
        }
        
        // 停止旧的监控（如果有）
        let activityName = DeviceActivityName("hdaUsage")
        deviceActivityCenter.stopMonitoring([activityName])
        
        // 创建 24 小时监控计划
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        // 创建阈值事件：每分钟触发一次
        let eventName = DeviceActivityEvent.Name("usageThreshold")
        let event = DeviceActivityEvent(
            applications: currentSelection.applicationTokens,
            threshold: DateComponents(minute: 1) // 每累计使用1分钟触发一次
        )
        
        let events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [
            eventName: event
        ]
        
        do {
            try deviceActivityCenter.startMonitoring(
                activityName,
                during: schedule,
                events: events
            )
            
            await MainActor.run {
                self.isMonitoring = true
            }
            
            print("✅ [ScreenTimeMonitor] Started monitoring HDA usage with event-based triggers")
            print("📱 [ScreenTimeMonitor] Monitoring \(currentSelection.applications.count) apps")
            print("⏱️ [ScreenTimeMonitor] Event will trigger every 1 minute of usage")
        } catch {
            print("❌ [ScreenTimeMonitor] Failed to start monitoring: \(error)")
            await MainActor.run {
                self.isMonitoring = false
            }
        }
    }
    
    /// 停止监控
    func stopMonitoring() {
        let activityName = DeviceActivityName("hdaUsage")
        deviceActivityCenter.stopMonitoring([activityName])
        isMonitoring = false
        print("🛑 [ScreenTimeMonitor] Stopped monitoring")
    }
    
    /// 获取 DeviceActivityFilter
    var deviceActivityFilter: DeviceActivityFilter {
        // Extract tokens from Application and ActivityCategory objects
        // Note: token properties return Optional, so we use compactMap
        let appTokens = Set(currentSelection.applications.compactMap { $0.token })
        let categoryTokens = Set(currentSelection.categories.compactMap { $0.token })
        
        return DeviceActivityFilter(
            segment: .daily(during: Calendar.current.dateInterval(of: .day, for: Date())!),
            users: .all,
            devices: .init([.iPhone, .iPad]),
            applications: appTokens,
            categories: categoryTokens
        )
    }
    
    /// 从共享存储同步数据
    func syncFromSharedStorage() {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            print("[ScreenTimeMonitor] Could not access shared UserDefaults with identifier: \(appGroupIdentifier)")
            return
        }
        
        let duration = sharedDefaults.double(forKey: "TotalHDAUsageDuration")
        let lastSync = sharedDefaults.object(forKey: "LastHDASyncDate") as? Date
        
        // Read debug log from extension
        readDebugLog()
        
        Task { @MainActor in
            self.todayHDAUsage = duration
            self.lastSyncDate = lastSync
        }
        
        // 计算增量并应用影响
        let lastProcessedDuration = UserDefaults.standard.double(forKey: "LastProcessedHDADuration")
        let delta = max(0, duration - lastProcessedDuration)
        
        if delta > 0 {
            print("[ScreenTimeMonitor] Applying HDA impact: \(delta) seconds")
            StatusManager.shared.applyHDAImpact(duration: delta)
            UserDefaults.standard.set(duration, forKey: "LastProcessedHDADuration")
        } else if duration > 0 {
            print("[ScreenTimeMonitor] No new usage detected (total: \(duration)s, last processed: \(lastProcessedDuration)s)")
        } else {
            print("[ScreenTimeMonitor] No HDA usage data available")
        }
    }
    
    /// 同步数据并更新稳定值 (入口)
    func syncAndApplyImpact() async {
        // 触发 Extension 刷新需要在 UI 层显示 Report。
        // 这里我们只负责读取数据。
        syncFromSharedStorage()
    }
    
    /// 启动定期同步（每 5 分钟）
    private func startPeriodicSync() {
        // 立即同步一次
        syncFromSharedStorage()
        
        // 每 5 分钟同步一次
        syncTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.syncFromSharedStorage()
            }
        }
    }
    
    /// 停止定期同步
    func stopPeriodicSync() {
        syncTimer?.invalidate()
        syncTimer = nil
    }
    
    deinit {
        // 直接清理 timer，避免调用 @MainActor 方法
        syncTimer?.invalidate()
        syncTimer = nil
    }
    
    private func readDebugLog() {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else { return }
        let logFileURL = containerURL.appendingPathComponent("hda_monitor_debug.log")
        
        if let logContent = try? String(contentsOf: logFileURL, encoding: .utf8) {
            print("\n--- 📜 HDAMonitor Extension Log ---")
            print(logContent)
            print("-----------------------------------\n")
        } else {
            print("[ScreenTimeMonitor] No extension log file found yet.")
        }
    }
}
