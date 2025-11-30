import Foundation
import FamilyControls
import DeviceActivity
import Combine

/// 管理高多巴胺应用 (HDA) 列表
@MainActor
class HDAManager: ObservableObject {
    static let shared = HDAManager()
    
    // 使用 FamilyActivitySelection 存储用户选择的应用
    @Published var activitySelection = FamilyActivitySelection()
    
    // 监测的应用数量
    var monitoredAppsCount: Int {
        return activitySelection.applications.count
    }
    
    private let userDefaultsKey = "HDAMonitoredAppsSelection"
    
    private init() {
        // Load saved selection first
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            self.activitySelection = selection
            // Ensure monitor is updated with loaded selection
            // We need to do this asynchronously to ensure ScreenTimeMonitor is ready
            Task { @MainActor in
                self.updateMonitoredApps(from: selection)
            }
        }
        
        // Listen for changes
        $activitySelection
            .dropFirst() // Avoid re-saving the initial loaded value immediately
            .sink { [weak self] newSelection in
                self?.saveSelection(newSelection)
                self?.updateMonitoredApps(from: newSelection)
            }
            .store(in: &cancellables)
    }
    
    private func saveSelection(_ selection: FamilyActivitySelection) {
        if let data = try? JSONEncoder().encode(selection) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
            print("💾 [HDAManager] Saved selection with \(selection.applications.count) apps")
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    /// 从 FamilyActivitySelection 更新监测列表
    private func updateMonitoredApps(from selection: FamilyActivitySelection) {
        // 更新 ScreenTimeMonitor 的过滤器
        ScreenTimeMonitor.shared.updateFilter(with: selection)
    }
}
