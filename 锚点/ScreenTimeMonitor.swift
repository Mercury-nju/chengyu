import Foundation
import FamilyControls
import DeviceActivity
import ManagedSettings
import Combine
import SwiftUI

extension DeviceActivityReport.Context {
    static let totalActivity = Self("Total Activity")
}

/// 监测 Screen Time 数据并计算 HDA 使用影响
@MainActor
class ScreenTimeMonitor: ObservableObject {
    static let shared = ScreenTimeMonitor()
    
    @Published var isAuthorized: Bool = false
    @Published var lastSyncDate: Date?
    @Published var isMonitoring: Bool = false
    
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
        let extensionLastSync = sharedDefaults.object(forKey: "LastHDASyncDate") as? Date
        
        print("[ScreenTimeMonitor] Read from shared storage: \(duration) seconds, extension last sync: \(String(describing: extensionLastSync))")
        
        // 使用扩展的真实同步时间，如果没有则使用当前时间
        lastSyncDate = extensionLastSync ?? Date()
        
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
    
    /// 启动 DeviceActivity 监控
    func startMonitoring() async {
        guard isAuthorized else {
            print("[ScreenTimeMonitor] Not authorized, cannot start monitoring")
            return
        }
        
        // 停止现有监控
        stopMonitoring()
        
        // 创建监控计划
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        let activityName = DeviceActivityName("hdaMonitoring")
        
        do {
            try deviceActivityCenter.startMonitoring(
                activityName,
                during: schedule
            )
            isMonitoring = true
            print("[ScreenTimeMonitor] Started monitoring HDA usage")
        } catch {
            print("[ScreenTimeMonitor] Failed to start monitoring: \(error)")
            isMonitoring = false
        }
    }
    
    /// 停止监控
    func stopMonitoring() {
        let activityName = DeviceActivityName("hdaMonitoring")
        deviceActivityCenter.stopMonitoring([activityName])
        isMonitoring = false
        print("[ScreenTimeMonitor] Stopped monitoring")
    }
    
    /// 启动定期同步（每 5 分钟）
    private func startPeriodicSync() {
        // 立即同步一次
        syncFromSharedStorage()
        
        // 每 5 分钟同步一次
        syncTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.syncFromSharedStorage()
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
}
