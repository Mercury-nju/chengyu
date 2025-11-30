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
    // If your app initializes a DeviceActivityReport with this context, then the system will use
    // your extension's corresponding DeviceActivityReportScene to render the contents of the
    // report.
    static let totalActivity = Self("Total Activity")
}

@main
struct TotalActivityReportExtension: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        // Create a report for each context that your app supports.
        TotalActivityReport()
    }
}

struct TotalActivityReport: DeviceActivityReportScene {
    // Define which context your scene will represent.
    let context: DeviceActivityReport.Context = .totalActivity
    
    // Define the custom configuration and the resulting view for this report.
    let content: (String) -> TotalActivityView = { totalActivity in
        TotalActivityView(totalActivity: totalActivity)
    }
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> String {
        // Reformat the data into a configuration that can be used to create
        // the report's view.
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        
        print("🚀 [Extension] ========== EXTENSION TRIGGERED ==========")
        print("🚀 [Extension] makeConfiguration called")
        print("🚀 [Extension] Data type: \(type(of: data))")
        
        // Calculate total duration by accessing segments from all activities
        var totalActivityDuration: TimeInterval = 0.0
        var segmentCount = 0
        
        // Flatten all segments from all activities (returns AsyncFlatMapSequence)
        for await segment in data.flatMap({ $0.activitySegments }) {
            totalActivityDuration += segment.totalActivityDuration
            segmentCount += 1
        }
        
        print("🔍 [Extension] Activity segments: \(segmentCount)")
        
        print("🔍 [Extension] Total duration: \(totalActivityDuration) seconds (\(Int(totalActivityDuration/60)) minutes)")
        
        // Save to shared UserDefaults for the main app to read
        // Define app group identifiers based on build configuration
        #if US_VERSION
        let appGroupIdentifiers = [
            "group.com.mercury.serenity.us",
            "group.com.mercury.chengyu"  // Fallback for compatibility
        ]
        #else
        let appGroupIdentifiers = [
            "group.com.mercury.chengyu.cn",
            "group.com.mercury.chengyu"  // Fallback for compatibility
        ]
        #endif
        
        var savedSuccessfully = false
        for identifier in appGroupIdentifiers {
            if let sharedDefaults = UserDefaults(suiteName: identifier) {
                sharedDefaults.set(totalActivityDuration, forKey: "TotalHDAUsageDuration")
                sharedDefaults.set(Date(), forKey: "LastHDASyncDate")
                let success = sharedDefaults.synchronize()
                print("🔍 [Extension] Saved to \(identifier): \(success)")
                savedSuccessfully = savedSuccessfully || success
            } else {
                print("❌ [Extension] Cannot access \(identifier)")
            }
        }
        
        if !savedSuccessfully {
            print("❌ [Extension] Failed to save to any app group")
        }
        
        return formatter.string(from: totalActivityDuration) ?? "0m"
    }
}
