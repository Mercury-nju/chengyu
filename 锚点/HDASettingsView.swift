import SwiftUI
import FamilyControls
import DeviceActivity

struct HDASettingsView: View {
    @ObservedObject var hdaManager = HDAManager.shared
    @ObservedObject var screenTimeMonitor = ScreenTimeMonitor.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var showAppPicker = false
    @State private var reportContext = DeviceActivityReport.Context.totalActivity
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.black.ignoresSafeArea()
                
                // Hidden DeviceActivityReport to trigger Extension
                // DeviceActivityReport - Full screen to ensure rendering
                if screenTimeMonitor.isAuthorized && hdaManager.monitoredAppsCount > 0 {
                    DeviceActivityReport(reportContext, filter: screenTimeMonitor.deviceActivityFilter)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.red.opacity(0.001)) // Force layout
                        .opacity(0.01)
                        .allowsHitTesting(false)
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L10n.hdaMonitoring)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(L10n.hdaDescription)
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Authorization Status
                        if !screenTimeMonitor.isAuthorized {
                            authorizationPrompt
                        }
                        
                        // Total Usage Time Card (if apps are monitored)
                        if hdaManager.monitoredAppsCount > 0 && screenTimeMonitor.isAuthorized {
                            totalUsageCard
                        }
                        
                        // Monitored Apps Display
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(L10n.currentMonitorList)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Spacer()
                                
                                if hdaManager.monitoredAppsCount > 0 {
                                    Text("\(hdaManager.monitoredAppsCount) \(L10n.appsCount)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            if hdaManager.monitoredAppsCount == 0 {
                                emptyState
                            } else {
                                // Flat Grid of Selected Apps
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 20) {
                                    ForEach(Array(hdaManager.activitySelection.applicationTokens), id: \.self) { token in
                                        VStack {
                                            Label(token)
                                                .labelStyle(.iconOnly)
                                                .scaleEffect(1.5)
                                                .frame(width: 50, height: 50)
                                                .background(Color.white.opacity(0.1))
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                            
                                            Label(token)
                                                .labelStyle(.titleOnly)
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.8))
                                                .lineLimit(1)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Add/Edit Apps Button
                        Button(action: {
                            showAppPicker = true
                        }) {
                            HStack {
                                Image(systemName: hdaManager.monitoredAppsCount == 0 ? "plus.circle.fill" : "pencil.circle.fill")
                                    .font(.system(size: 20))
                                Text(hdaManager.monitoredAppsCount == 0 ? "添加应用" : "编辑应用")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        
                        // Minimal Sync Footer
                        if screenTimeMonitor.isAuthorized {
                            syncFooter
                        }
                        
                        Spacer().frame(height: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.done) {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .familyActivityPicker(isPresented: $showAppPicker, selection: $hdaManager.activitySelection)
        }
    }
    
    // MARK: - Subviews
    
    var authorizationPrompt: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32))
                .foregroundColor(.orange)
            
            Text(L10n.screenTimePermission)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            Text(L10n.screenTimePermissionDesc)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Button(action: {
                Task {
                    do {
                        try await screenTimeMonitor.requestAuthorization()
                        // 授权成功后，如果已有监测应用，立即启动监控
                        if hdaManager.monitoredAppsCount > 0 {
                            await screenTimeMonitor.startMonitoring()
                        }
                    } catch {
                        print("Authorization failed: \(error)")
                    }
                }
            }) {
                Text(L10n.grantPermission)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(20)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
    
    var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "app.dashed")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.3))
            
            Text(L10n.noMonitoredApps)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.6))
            
            Text(L10n.tapToAddApps)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Minimal Sync Footer
    var syncFooter: some View {
        Button(action: {
            Task {
                await screenTimeMonitor.syncAndApplyImpact()
            }
        }) {
            HStack(spacing: 6) {
                Text(L10n.lastSync)
                    .font(.system(size: 11, weight: .light))
                    .foregroundColor(.white.opacity(0.4))
                
                if let lastSync = screenTimeMonitor.lastSyncDate {
                    Text(timeAgo(lastSync))
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(.white.opacity(0.6))
                } else {
                    Text(L10n.never)
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
    }
    
    func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    // MARK: - Total Usage Card
    var totalUsageCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.cyan)
                
                Text(L10n.isUSVersion ? "Total Usage Today" : "今日总使用时长")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
            }
            
            // Embed the DeviceActivityReport here to ensure it renders
            ZStack {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(formatTotalUsage())
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(L10n.isUSVersion ? "min" : "分钟")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                    
                    Button(action: {
                        Task {
                            await screenTimeMonitor.syncAndApplyImpact()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16))
                            .foregroundColor(.cyan)
                            .padding(8)
                            .background(Color.cyan.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                
                // Small visible report to trigger Extension
                DeviceActivityReport(reportContext, filter: screenTimeMonitor.deviceActivityFilter)
                    .frame(width: 1, height: 1)
                    .opacity(0.01)
            }
            
            if let lastSync = screenTimeMonitor.lastSyncDate {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.4))
                    
                    Text(L10n.isUSVersion ? "Updated \(timeAgo(lastSync))" : "更新于 \(timeAgo(lastSync))")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cyan.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
    
    func formatTotalUsage() -> String {
        #if US_VERSION
        let appGroupIdentifier = "group.com.mercury.serenity.us"
        #else
        let appGroupIdentifier = "group.com.mercury.chengyu.cn"
        #endif
        
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            print("❌ [HDASettings] Cannot access shared UserDefaults: \(appGroupIdentifier)")
            return "0"
        }
        
        let totalSeconds = sharedDefaults.double(forKey: "TotalHDAUsageDuration")
        let lastSync = sharedDefaults.object(forKey: "LastHDASyncDate") as? Date
        
        print("📊 [HDASettings] Total usage: \(totalSeconds)s (\(Int(totalSeconds/60))m), last sync: \(String(describing: lastSync))")
        
        let minutes = Int(totalSeconds / 60)
        return "\(minutes)"
    }
}
