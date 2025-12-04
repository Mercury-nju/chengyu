import SwiftUI

struct DeepInsightsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var insightsManager = DeepInsightsManager.shared
    @State private var selectedTab: InsightTab = .flowStability
    @State private var selectedInsight: String?
    @State private var showInsightDetail = false
    
    enum InsightTab: CaseIterable {
        case flowStability
        case meditationEcho
        
        var title: String {
            switch self {
            case .flowStability: return L10n.flowStability
            case .meditationEcho: return L10n.meditationEcho
            }
        }
        
        var icon: String {
            switch self {
            case .flowStability: return "waveform.path.ecg"
            case .meditationEcho: return "sparkles"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background
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
                    
                    Text(L10n.deepInsightsTitle)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 24)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                // Tab Selector
                HStack(spacing: 12) {
                    ForEach(InsightTab.allCases, id: \.self) { tab in
                        TabButton(
                            title: tab.title,
                            icon: tab.icon,
                            isSelected: selectedTab == tab
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedTab = tab
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        switch selectedTab {
                        case .flowStability:
                            FlowStabilityView(insightsManager: insightsManager)
                        case .meditationEcho:
                            MeditationEchoView(insightsManager: insightsManager)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            Task {
                await insightsManager.refreshAllData()
            }
        }
    }
}

// MARK: - Tab Button

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                
                Text(title)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(isSelected ? .cyan : .white.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.cyan.opacity(0.15) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.cyan.opacity(0.5) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - A. Flow Stability View

struct FlowStabilityView: View {
    @ObservedObject var insightsManager: DeepInsightsManager
    
    var body: some View {
        VStack(spacing: 24) {
            // Insights Cards
            InsightCardsSection(insights: insightsManager.flowStabilityInsights)
            
            // SV Heatmap
            SectionCard(title: L10n.flowHeatmap, icon: "chart.bar.fill") {
                SVHeatmapChart(data: insightsManager.svHeatmapData)
            }
            
            // Focus Interruption
            if let interruption = insightsManager.focusInterruptionData {
                SectionCard(title: L10n.focusInterruption, icon: "timer") {
                    FocusInterruptionChart(data: interruption)
                }
            }
            
            // Recovery Curve
            if !insightsManager.svRecoveryData.isEmpty {
                SectionCard(title: L10n.flowRecoveryCurve, icon: "arrow.up.heart") {
                    ZStack {
                        SVRecoveryCurveChart(data: insightsManager.svRecoveryData)
                            .blur(radius: SubscriptionManager.shared.isPremium ? 0 : 10)
                        
                        if !SubscriptionManager.shared.isPremium {
                            PremiumLockOverlay()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Premium Lock Overlay
struct PremiumLockOverlay: View {
    var body: some View {
        ZStack {
            // Frosted glass background
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.3))
                )
            
            VStack(spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                    
                    Text(L10n.flowTrajectoryPremium)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text(L10n.upgradePremiumMessage)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
}

// MARK: - B. Meditation Echo View

struct MeditationEchoView: View {
    @ObservedObject var insightsManager: DeepInsightsManager
    
    var body: some View {
        VStack(spacing: 24) {
            // Insights Cards
            InsightCardsSection(insights: insightsManager.meditationEchoInsights)
            
            // Meditation Effect
            if !insightsManager.meditationEffectData.isEmpty {
                SectionCard(title: L10n.meditationEffect, icon: "sparkles") {
                    MeditationEffectChart(data: insightsManager.meditationEffectData)
                }
            }
            
            // Meditation Frequency
            SectionCard(title: L10n.isUSVersion ? "Meditation Frequency & Baseline" : "冥想频率与基线", icon: "chart.line.uptrend.xyaxis") {
                Text(L10n.dataCollecting)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(height: 200)
            }
        }
    }
}

// MARK: - Insight Cards Section

struct InsightCardsSection: View {
    let insights: [String]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(insights, id: \.self) { insight in
                InsightCard(text: insight)
            }
        }
    }
}

struct InsightCard: View {
    let text: String
    @State private var isExpanded = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                isExpanded.toggle()
            }
        }) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.yellow.opacity(0.8))
                    .padding(.top, 2)
                
                Text(text)
                    .font(.system(size: 15, weight: .light, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
                
                Spacer()
            }
            .padding(16)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .opacity(0.3)
                    
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.yellow.opacity(0.1),
                                    Color.orange.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.yellow.opacity(0.3),
                                    Color.orange.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: Color.yellow.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Section Card

struct SectionCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(.cyan)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}
