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
    
    private init() {
        // 监听 activitySelection 变化
        $activitySelection
            .sink { [weak self] newSelection in
                self?.updateMonitoredApps(from: newSelection)
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    /// 从 FamilyActivitySelection 更新监测列表
    private func updateMonitoredApps(from selection: FamilyActivitySelection) {
        // 更新 ScreenTimeMonitor 的过滤器
        ScreenTimeMonitor.shared.updateFilter(with: selection)
    }
}
