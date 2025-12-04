//
//  TotalActivityReport.swift
//  TotalActivityReport
//
//  Created by Mercury on 2025/11/24.
//

import DeviceActivity
import ExtensionKit
import SwiftUI

extension DeviceActivityReport.Context {
    static let totalActivity = Self("Total Activity")
}

@main
struct TotalActivityReportExtension: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        TotalActivityReport()
    }
}

struct TotalActivityReport: DeviceActivityReportScene {
    let context: DeviceActivityReport.Context = .totalActivity
    
    let content: (String) -> TotalActivityView = { totalActivity in
        TotalActivityView(totalActivity: totalActivity)
    }
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> String {
        // 最简化的实现：立即返回固定值测试 Extension 是否能运行
        print("🚀 [Extension] ========== EXTENSION TRIGGERED ==========")
        print("🚀 [Extension] Minimal test version")
        
        // 保存测试数据
        let appGroupID = "group.com.mercury.serenity.us"
        if let sharedDefaults = UserDefaults(suiteName: appGroupID) {
            sharedDefaults.set(123.0, forKey: "TotalHDAUsageDuration")
            sharedDefaults.set(Date(), forKey: "LastHDASyncDate")
            let success = sharedDefaults.synchronize()
            print("🔍 [Extension] Test save to \(appGroupID): \(success)")
        } else {
            print("❌ [Extension] Cannot access \(appGroupID)")
        }
        
        return "2m"
    }
}
