import SwiftUI
import DeviceActivity

struct StatusView: View {
    @ObservedObject var statusManager = StatusManager.shared
    @ObservedObject var screenTimeMonitor = ScreenTimeMonitor.shared
    @ObservedObject var hdaManager = HDAManager.shared
    @ObservedObject var authManager = AuthManager.shared
    @State private var showHDASettings = false
    @State private var showLoginView = false
    @State private var showProfileView = false
    @State private var showCLIInfo = false
    @State private var showSVInfo = false
    @State private var showTrendInfo = false
    
    // Helper to get material colors
    var currentMaterialColors: [Color] {
        let material: FluidSphereView.SphereMaterial = FluidSphereView.SphereMaterial.fromString(statusManager.sphereMaterial)
        return material.colors
    }
    
    // Health status based on stability
    var stabilityHealth: (color: Color, label: String) {
        let value = statusManager.stabilityValue
        if value >= 70 {
            return (.green, L10n.statusExcellent)
        } else if value >= 40 {
            return (.yellow, L10n.statusModerate)
        } else {
            return (.red, L10n.statusAtRisk)
        }
    }
    
    // Gradient colors based on stability value (red -> yellow -> green)
    var healthGradientColors: [Color] {
        let value = statusManager.stabilityValue
        
        if value < 40 {
            // 0-40%: Red to Orange
            return [
                Color(red: 0.9, green: 0.2, blue: 0.2),
                Color(red: 1.0, green: 0.4, blue: 0.2)
            ]
        } else if value < 70 {
            // 40-70%: Orange to Yellow
            return [
                Color(red: 1.0, green: 0.5, blue: 0.2),
                Color(red: 1.0, green: 0.8, blue: 0.2)
            ]
        } else {
            // 70-100%: Yellow-Green to Green
            return [
                Color(red: 0.6, green: 0.9, blue: 0.3),
                Color(red: 0.2, green: 0.8, blue: 0.3)
            ]
        }
    }
    
    var currentDateString: String {
        let formatter = DateFormatter()
        if L10n.isUSVersion {
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "EEEE, MMM d"
        } else {
            formatter.locale = Locale(identifier: "zh_CN")
            formatter.dateFormat = "M月d日，EEEE"
        }
        return formatter.string(from: Date())
    }
    
    var body: some View {
        ZStack {
            ThemeManager.shared.currentTheme.backgroundView
            
            // DeviceActivityReport to trigger Extension
            // Note: Needs non-zero frame to actually render and trigger extension
            if screenTimeMonitor.isAuthorized && hdaManager.monitoredAppsCount > 0 {
                DeviceActivityReport(.totalActivity, filter: screenTimeMonitor.deviceActivityFilter)
                    .frame(width: 1, height: 1)
                    .opacity(0.01)  // Nearly invisible but not completely transparent
                    .allowsHitTesting(false)
            }
            
            VStack(spacing: 0) {
                navigationBar
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .onAppear {
                        // Refresh authorization status
                        screenTimeMonitor.checkAuthorizationStatus()
                        
                        print("📊 [StatusView] Appeared")
                        print("📊 [StatusView] Screen Time authorized: \(screenTimeMonitor.isAuthorized)")
                        print("📊 [StatusView] Monitored apps count: \(hdaManager.monitoredAppsCount)")
                        print("📊 [StatusView] Last sync: \(String(describing: screenTimeMonitor.lastSyncDate))")
                        print("📊 [StatusView] Monitoring active: \(screenTimeMonitor.isMonitoring)")
                        
                        // Auto-start monitoring if conditions met
                        if screenTimeMonitor.isAuthorized && hdaManager.monitoredAppsCount > 0 && !screenTimeMonitor.isMonitoring {
                            Task {
                                print("🚀 [StatusView] Starting monitoring...")
                                await screenTimeMonitor.startMonitoring()
                                
                                // Force sync after starting monitoring
                                try? await Task.sleep(nanoseconds: 1_000_000_000) // Wait 1 second
                                print("🔄 [StatusView] Force syncing data...")
                                await screenTimeMonitor.syncAndApplyImpact()
                            }
                        } else if screenTimeMonitor.isAuthorized && hdaManager.monitoredAppsCount > 0 {
                            // If already monitoring, just sync
                            Task {
                                print("🔄 [StatusView] Syncing data...")
                                await screenTimeMonitor.syncAndApplyImpact()
                            }
                        }
                    }
                    .padding(.bottom, 10)
                
                ScrollView {
                    VStack(spacing: 30) {
                        mainContent
                    }
                }
            }
            .onAppear {
                statusManager.checkDailyReset()
                screenTimeMonitor.checkAuthorizationStatus()
                
                Task {
                    await screenTimeMonitor.syncAndApplyImpact()
                }
            }
        }
        .fullScreenCover(isPresented: $showHDASettings) {
            HDASettingsView()
        }
        .fullScreenCover(isPresented: $showLoginView) {
            LoginView()
        }
        .sheet(isPresented: $showProfileView) {
            ProfileView()
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showCLIInfo) {
            InfoSheetView(
                title: L10n.cliInfoTitle,
                content: cliInfoContent
            )
        }
        .sheet(isPresented: $showSVInfo) {
            InfoSheetView(
                title: L10n.svInfoTitle,
                content: svInfoContent
            )
        }
        .sheet(isPresented: $showTrendInfo) {
            InfoSheetView(
                title: L10n.trendInfoTitle,
                content: trendInfoContent
            )
        }
        .alert(L10n.cliAlertTitle, isPresented: $statusManager.shouldShowCLIAlert) {
            Button(L10n.gotIt, role: .cancel) {
                statusManager.dismissCLIAlert()
            }
            Button(L10n.goToMeditate) {
                statusManager.dismissCLIAlert()
            }
        } message: {
            Text(statusManager.cliAlertMessage)
        }
    }
    
    // MARK: - Main Content
    @ViewBuilder
    private var mainContent: some View {
        cognitiveLoadSection
        stabilityProgressSection
        stabilityDynamicsSection
        distractionTrajectorySection
        DeepInsightsSection()
        historyChartSection
    }
    
    // MARK: - Section Views
    private var cognitiveLoadSection: some View {
        Group {
            if !screenTimeMonitor.isAuthorized {
                unauthorizedCard
            } else {
                CognitiveLoadCard(
                    cli: statusManager.calculateCLI(),
                    monitor: screenTimeMonitor,
                    onSettingsTap: { showHDASettings = true },
                    onInfoTap: { showCLIInfo = true }
                )
                .padding(.horizontal)
            }
        }
    }
    
    private var unauthorizedCard: some View {
        Button(action: {
            showHDASettings = true
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.orange)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.unlockInsights)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(L10n.authorizeToQuantify)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal)
    }
    
    private var stabilityProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            HStack(spacing: 6) {
                                Text(L10n.stabilityScore)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Button(action: {
                                    showSVInfo = true
                                }) {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.4))
                                }
                            }
                            
                            Spacer()
                            
                            Text("\(Int(statusManager.stabilityValue))%")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(stabilityHealth.color)
                        }
                        
                        // Progress Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background Track
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 24)
                                
                                // Filled Progress with Health-based Gradient
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: healthGradientColors,
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: max(0, CGFloat(statusManager.stabilityValue) / 100.0 * geometry.size.width), height: 24)
                                    .shadow(color: stabilityHealth.color.opacity(0.5), radius: 8)
                                    .animation(.spring(response: 0.8, dampingFraction: 0.7), value: statusManager.stabilityValue)
                                
                                // Glow overlay
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: [.white.opacity(0.3), .clear],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: max(0, CGFloat(statusManager.stabilityValue) / 100.0 * geometry.size.width), height: 12)
                                    .offset(y: -6)
                            }
                        }
                        .frame(height: 24)
                        
                        // Status Label
                        HStack {
                            Circle()
                                .fill(stabilityHealth.color)
                                .frame(width: 8, height: 8)
                            Text(stabilityHealth.label)
                                .font(.caption)
                                .foregroundColor(stabilityHealth.color)
                        }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
        .padding(.horizontal)
    }
    
    private var stabilityDynamicsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(L10n.stabilityDynamics)
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            if statusManager.stabilityLogs.isEmpty {
                                Text(L10n.noRecords)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        if statusManager.stabilityLogs.isEmpty {
                            // Empty State
                            HStack {
                                Spacer()
                                VStack(spacing: 8) {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .font(.system(size: 24))
                                        .foregroundColor(.gray.opacity(0.5))
                                    Text(L10n.completeTasksForStability)
                                        .font(.caption)
                                        .foregroundColor(.gray.opacity(0.5))
                                }
                                .padding(.vertical, 20)
                                Spacer()
                            }
                        } else {
                            // Recent Logs (Limit to 5)
                            ForEach(statusManager.stabilityLogs.prefix(5)) { log in
                                HStack {
                                    Image(systemName: log.type == .gain ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                        .foregroundColor(log.type == .gain ? .green : .red)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(log.source)
                                            .font(.caption)
                                            .foregroundColor(.white)
                                        Text(timeAgo(log.timestamp))
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Text((log.type == .gain ? "+" : "-") + String(format: "%.1f%%", abs(log.amount)))
                                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                                        .foregroundColor(log.type == .gain ? .green : .red)
                                }
                                .padding(.vertical, 4)
                                
                                if log.id != statusManager.stabilityLogs.prefix(5).last?.id {
                                    Divider().background(Color.white.opacity(0.1))
                                }
                            }
                        }
                        
                        if statusManager.stabilityValue < 50 {
                            Divider().background(Color.white.opacity(0.1))
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text(L10n.warningLowStability)
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    private var distractionTrajectorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
                        Text(L10n.distractionTrajectory)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        // Filter for HDA usage logs
                        if statusManager.stabilityLogs.filter({ $0.type == .loss && ($0.source.contains("分心") || $0.source.contains("高多巴胺")) }).isEmpty {
                            HStack {
                                Spacer()
                                Text(L10n.goodFocusToday)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .padding(.vertical, 10)
                        } else {
                            ForEach(statusManager.stabilityLogs.filter({ $0.type == .loss && ($0.source.contains("分心") || $0.source.contains("高多巴胺")) }).prefix(3)) { log in
                                HStack {
                                    Image(systemName: "eye.slash.fill")
                                        .foregroundColor(.red)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(log.source) // Show actual source (e.g., "高多巴胺应用使用 (30分钟)")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                        Text(timeAgo(log.timestamp))
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Text(String(format: "-%.1f%%", abs(log.amount)))
                                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                                        .foregroundColor(.red)
                                }
                                .padding(.vertical, 4)
                            }
                        }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    private var historyChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 6) {
                            Text(L10n.sevenDayTrend)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Button(action: {
                                showTrendInfo = true
                            }) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                        }
                        
                        ZStack {
                            VStack(spacing: 0) {
                                FluidTrendChart(data: statusManager.history.map { $0.score })
                                    .frame(height: 180)
                                    .padding(.top, 10)
                                
                                // Days Labels
                                HStack {
                                    ForEach(statusManager.history) { record in
                                        Text(record.day)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                            .blur(radius: SubscriptionManager.shared.isPremium ? 0 : 8)
                            
                            if !SubscriptionManager.shared.isPremium {
                                StatusPremiumLockOverlay(onUpgrade: {
                                    // TODO: Navigate to subscription view
                                })
                            }
                        }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal)
        .padding(.bottom, 40)
    }
    
    // MARK: - Helper Methods
    
    // MARK: - Info Content
    
    var cliInfoContent: String {
        L10n.cliInfoContent
    }
    
    var svInfoContent: String {
        L10n.svInfoContent
    }
    
    var trendInfoContent: String {
        L10n.trendInfoContent
    }
    
    func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    // MARK: - Subviews
    private var navigationBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("STATUS")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(currentDateString)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            profileButton
        }
    }
    
    private var profileButton: some View {
        Button(action: {
            if authManager.isLoggedIn {
                showProfileView = true
            } else {
                showLoginView = true
            }
        }) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: authManager.isLoggedIn ? [.cyan.opacity(0.5), .blue.opacity(0.3)] : [.white.opacity(0.2), .white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: authManager.isLoggedIn ? Color.cyan.opacity(0.3) : Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 18))
                    .foregroundColor(authManager.isLoggedIn ? .white : .white.opacity(0.6))
            }
        }
    }
}

struct FluidTrendChart: View {
    let data: [Double]
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let stepX = width / CGFloat(max(data.count - 1, 1))
            
            ZStack {
                // Gradient Fill
                Path { path in
                    path.move(to: CGPoint(x: 0, y: height))
                    
                    for (index, value) in data.enumerated() {
                        let x = CGFloat(index) * stepX
                        let y = height - (CGFloat(value) / 100.0 * height)
                        
                        if index == 0 {
                            path.addLine(to: CGPoint(x: x, y: y))
                        } else {
                            let prevX = CGFloat(index - 1) * stepX
                            let prevY = height - (CGFloat(data[index - 1]) / 100.0 * height)
                            let controlX1 = prevX + (stepX / 2)
                            let controlX2 = x - (stepX / 2)
                            
                            path.addCurve(to: CGPoint(x: x, y: y),
                                          control1: CGPoint(x: controlX1, y: prevY),
                                          control2: CGPoint(x: controlX2, y: y))
                        }
                    }
                    
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [Theme.dopamineBlue.opacity(0.5), Theme.dopamineBlue.opacity(0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Line Stroke
                Path { path in
                    for (index, value) in data.enumerated() {
                        let x = CGFloat(index) * stepX
                        let y = height - (CGFloat(value) / 100.0 * height)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            let prevX = CGFloat(index - 1) * stepX
                            let prevY = height - (CGFloat(data[index - 1]) / 100.0 * height)
                            let controlX1 = prevX + (stepX / 2)
                            let controlX2 = x - (stepX / 2)
                            
                            path.addCurve(to: CGPoint(x: x, y: y),
                                          control1: CGPoint(x: controlX1, y: prevY),
                                          control2: CGPoint(x: controlX2, y: y))
                        }
                    }
                }
                .stroke(
                    LinearGradient(
                        colors: [.cyan, .blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                )
                .shadow(color: .cyan.opacity(0.5), radius: 10, x: 0, y: 0)
                
                // Points
                ForEach(0..<data.count, id: \.self) { index in
                    let value = data[index]
                    let x = CGFloat(index) * stepX
                    let y = height - (CGFloat(value) / 100.0 * height)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 6, height: 6)
                        .position(x: x, y: y)
                        .shadow(color: .white, radius: 4)
                }
            }
        }
    }
}

struct StatusCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                Spacer()
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

// Extension to help convert String to SphereMaterial
extension FluidSphereView.SphereMaterial {
    static func fromString(_ string: String) -> FluidSphereView.SphereMaterial {
        switch string {
        case "lava": return .lava
        case "ice": return .ice
        case "amber": return .amber
        case "gold": return .gold
        case "neon": return .neon
        case "nebula": return .nebula
        case "aurora": return .aurora
        case "sakura": return .sakura
        case "ocean": return .ocean
        case "sunset": return .sunset
        case "forest": return .forest
        case "galaxy": return .galaxy
        case "crystal": return .crystal
        default: return .default
        }
    }
}

// Debug Button Style
struct DebugButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(configuration.isPressed ? 0.5 : 0.3))
            .cornerRadius(8)
    }
}

// MARK: - Profile Header View
struct ProfileHeaderView: View {
    @ObservedObject var authManager: AuthManager
    @Binding var showLoginView: Bool
    
    var body: some View {
        Button(action: {
            if !authManager.isLoggedIn {
                showLoginView = true
            }
        }) {
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: authManager.isLoggedIn ? [.cyan, .blue] : [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    
                    if authManager.isLoggedIn, let user = authManager.currentUser {
                        Text(String(user.displayName.prefix(1)))
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.3))
                    }
                }
                
                // Text Info
                VStack(alignment: .leading, spacing: 4) {
                    if authManager.isLoggedIn, let user = authManager.currentUser {
                        Text(user.displayName)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 6, height: 6)
                            Text(L10n.connected)
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    } else {
                        Text(L10n.loginAccount)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(L10n.syncYourJourney)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                Spacer()
                
                // Action Icon
                if authManager.isLoggedIn {
                    Menu {
                        Button(role: .destructive, action: {
                            authManager.logout()
                        }) {
                            Label(L10n.logout, systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.4))
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.05))
                            .clipShape(Circle())
                    }
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(8)
                        .background(Color.white.opacity(0.05))
                        .clipShape(Circle())
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.2), .white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Cognitive Load Card
struct CognitiveLoadCard: View {
    let cli: Double
    @ObservedObject var monitor: ScreenTimeMonitor
    @ObservedObject var hdaManager = HDAManager.shared
    var onSettingsTap: () -> Void
    
    var statusColor: Color {
        if cli >= 90 { return .red }
        if cli >= 60 { return .orange }
        if cli >= 30 { return .yellow }
        return .green
    }
    
    var statusText: String {
        if cli >= 90 { return L10n.cliStatusCritical }
        if cli >= 60 { return L10n.cliStatusHigh }
        if cli >= 30 { return L10n.cliStatusModerate }
        return L10n.cliStatusGood
    }
    
    var statusIcon: String {
        if cli >= 90 { return "exclamationmark.triangle.fill" }
        if cli >= 60 { return "exclamationmark.circle.fill" }
        if cli >= 30 { return "info.circle.fill" }
        return "checkmark.circle.fill"
    }
    
    var onInfoTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(L10n.cognitiveLoadIndex)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Button(action: onInfoTap) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(Int(cli))")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(statusColor)
                        
                        Text("/ 100")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                
                Spacer()
                
                // Settings button with label - Different states
                Button(action: onSettingsTap) {
                    if hdaManager.monitoredAppsCount == 0 {
                        // No apps added - Warning state
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(Color.orange.opacity(0.2))
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.orange)
                            }
                            
                            Text(L10n.addApp)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.orange)
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.orange.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                        )
                    } else {
                        // Apps added - Normal state (no badge)
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(Color.cyan.opacity(0.15))
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: "app.badge.checkmark")
                                    .font(.system(size: 16))
                                    .foregroundColor(.cyan)
                            }
                            
                            Text(L10n.monitorList)
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                        )
                    }
                }
            }
            
            // Visual indicator - Circular segments
            HStack(spacing: 8) {
                ForEach(0..<4, id: \.self) { index in
                    let threshold = Double((index + 1) * 25)
                    let isActive = cli >= threshold - 12.5
                    
                    VStack(spacing: 4) {
                        Circle()
                            .fill(isActive ? statusColor : Color.white.opacity(0.1))
                            .frame(width: isActive ? 12 : 8, height: isActive ? 12 : 8)
                            .overlay(
                                Circle()
                                    .stroke(statusColor.opacity(0.3), lineWidth: isActive ? 2 : 0)
                                    .frame(width: 20, height: 20)
                            )
                        
                        Text("\(Int(threshold))")
                            .font(.system(size: 9))
                            .foregroundColor(isActive ? statusColor : .white.opacity(0.3))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 8)
            
            // Status description
            HStack(spacing: 8) {
                Image(systemName: statusIcon)
                    .font(.system(size: 14))
                    .foregroundColor(statusColor)
                
                Text(statusText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                if cli > 0 {
                    Text(L10n.within24h)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(statusColor.opacity(0.1))
            )
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
    }
}


