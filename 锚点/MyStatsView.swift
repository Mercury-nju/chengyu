import SwiftUI

// MARK: - Premium Lock Overlay for Status Page
struct StatusPremiumLockOverlay: View {
    var onUpgrade: () -> Void
    
    var body: some View {
        ZStack {
            // Frosted glass background
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            
            VStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.orange)
                    
                    Text(L10n.flowTrajectory + L10n.premiumExclusiveSuffix)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text(L10n.upgradeToMaster)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                
                Button(action: onUpgrade) {
                    Text(L10n.upgradeToPlus)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }
}

// MARK: - Deep Insights Section

struct DeepInsightsSection: View {
    @StateObject private var insightsManager = DeepInsightsManager.shared
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    @State private var showFlowStabilityInfo = false
    @State private var showMeditationEchoInfo = false
    @State private var showSubscription = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Flow Stability
            SimpleInsightCard(
                title: L10n.flowStability,
                onInfoTap: { showFlowStabilityInfo = true },
                content: AnyView(
                    ZStack {
                        VStack(spacing: 20) {
                            if let interruption = insightsManager.focusInterruptionData {
                                FocusInterruptionChart(data: interruption)
                            }
                            
                            if !insightsManager.svHeatmapData.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(L10n.flowHeatmap)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                    SVHeatmapChart(data: insightsManager.svHeatmapData)
                                }
                            }
                        }
                        .blur(radius: subscriptionManager.isPremium ? 0 : 8)
                        
                        if !subscriptionManager.isPremium {
                            StatusPremiumLockOverlay(onUpgrade: { showSubscription = true })
                        }
                    }
                )
            )
            

            
            // Serenity Echo
            if !insightsManager.meditationEffectData.isEmpty {
                SimpleInsightCard(
                    title: L10n.serenityEcho,
                    onInfoTap: { showMeditationEchoInfo = true },
                    content: AnyView(
                        ZStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(L10n.meditationEffect)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                MeditationEffectChart(data: insightsManager.meditationEffectData)
                            }
                            .blur(radius: subscriptionManager.isPremium ? 0 : 8)
                            
                            if !subscriptionManager.isPremium {
                                StatusPremiumLockOverlay(onUpgrade: { showSubscription = true })
                            }
                        }
                    )
                )
            }
        }
        .task {
            // 刷新订阅状态
            await subscriptionManager.updateSubscriptionStatus()
            // 刷新数据
            await insightsManager.refreshAllData()
        }
        .sheet(isPresented: $showFlowStabilityInfo) {
            InfoSheetView(
                title: L10n.flowStability,
                content: flowStabilityInfoContent
            )
        }
        .sheet(isPresented: $showMeditationEchoInfo) {
            InfoSheetView(
                title: L10n.serenityEcho,
                content: meditationEchoInfoContent
            )
        }
        .sheet(isPresented: $showSubscription) {
            SubscriptionView()
        }
    }
    
    // MARK: - Info Content
    
    var flowStabilityInfoContent: String {
        L10n.flowStabilityInfoContent
    }
    
    var meditationEchoInfoContent: String {
        L10n.meditationEchoInfoContent
    }
}

// MARK: - Simple Insight Card

struct SimpleInsightCard: View {
    let title: String
    let onInfoTap: () -> Void
    let content: AnyView
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: onInfoTap) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            content
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct MyStatsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var statusManager = StatusManager.shared
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text(L10n.myStatsTitle)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    Color.clear.frame(width: 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Total Stats Card
                        VStack(spacing: 16) {
                            Text(L10n.totalMeditation)
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text("0")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.cyan)
                            
                            Text(L10n.minutesUnit)
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.05))
                        )
                        .padding(.horizontal, 20)
                        
                        // Stats Grid
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                StatCard(
                                    icon: "flame.fill",
                                    title: L10n.currentStreakTitle,
                                    value: "0",
                                    unit: L10n.daysUnit,
                                    color: .orange
                                )
                                
                                StatCard(
                                    icon: "calendar",
                                    title: L10n.totalDaysTitle,
                                    value: "0",
                                    unit: L10n.daysUnit,
                                    color: .blue
                                )
                            }
                            
                            HStack(spacing: 12) {
                                StatCard(
                                    icon: "checkmark.circle.fill",
                                    title: L10n.completedSessionsTitle,
                                    value: "0",
                                    unit: L10n.timesUnit,
                                    color: .green
                                )
                                
                                StatCard(
                                    icon: "chart.line.uptrend.xyaxis",
                                    title: L10n.stabilityValueTitle,
                                    value: "\(Int(statusManager.stabilityValue))",
                                    unit: "%",
                                    color: .purple
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Weekly Chart
                        VStack(alignment: .leading, spacing: 16) {
                            Text(L10n.weeklyStats)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            // Simple bar chart placeholder
                            HStack(alignment: .bottom, spacing: 8) {
                                ForEach(L10n.isUSVersion ? ["M", "T", "W", "T", "F", "S", "S"] : ["一", "二", "三", "四", "五", "六", "日"], id: \.self) { day in
                                    VStack(spacing: 8) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.cyan.opacity(0.3))
                                            .frame(height: CGFloat.random(in: 20...80))
                                        
                                        Text(day)
                                            .font(.system(size: 11))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .frame(height: 120)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.05))
                        )
                        .padding(.horizontal, 20)
                        
                        // Emotional Logs History
                        VStack(alignment: .leading, spacing: 16) {
                            Text(L10n.emotionalLogsTitle)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            if emotionalLogs.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "heart.text.square")
                                        .font(.system(size: 32))
                                        .foregroundColor(.white.opacity(0.3))
                                    
                                    Text(L10n.noEmotionalLogs)
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(emotionalLogs) { log in
                                        HStack(spacing: 12) {
                                            Image(systemName: "sparkles")
                                                .font(.system(size: 16))
                                                .foregroundColor(.cyan)
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(log.name)
                                                    .font(.system(size: 15, weight: .medium))
                                                    .foregroundColor(.white)
                                                
                                                HStack(spacing: 8) {
                                                    Text(formatDate(log.date))
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.white.opacity(0.5))
                                                    
                                                    Text("·")
                                                        .foregroundColor(.white.opacity(0.3))
                                                    
                                                    Text(formatDuration(log.duration))
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.white.opacity(0.5))
                                                }
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white.opacity(0.03))
                                        )
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.05))
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var emotionalLogs: [StatusManager.EmotionalLog] {
        if let data = UserDefaults.standard.data(forKey: "emotionalLogs"),
           let logs = try? JSONDecoder().decode([StatusManager.EmotionalLog].self, from: data) {
            return logs.sorted(by: { $0.date > $1.date })
        }
        return []
    }
    
    // MARK: - Helper Functions
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日 HH:mm"
        return formatter.string(from: date)
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if minutes > 0 {
            return "\(minutes)分\(seconds)秒"
        } else {
            return "\(seconds)秒"
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(unit)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
    }
}
