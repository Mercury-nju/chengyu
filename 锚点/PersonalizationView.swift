import SwiftUI

/// 个性化问卷页面 - 在引导结束后显示
struct PersonalizationView: View {
    @Binding var isCompleted: Bool
    @State private var currentStep = 0 // 0: 目标, 1: 时间, 2: 频率
    @State private var selectedGoal: UserGoal?
    @State private var selectedTime: PreferredTime?
    @State private var selectedFrequency: PracticeFrequency?
    @State private var showResultPage = false
    @State private var showSubscription = false
    
    enum UserGoal: String, CaseIterable {
        case sleep = "sleep"
        case focus = "focus"
        case anxiety = "anxiety"
        case stress = "stress"
        
        var displayName: String {
            if L10n.isUSVersion {
                switch self {
                case .sleep: return "Better Sleep"
                case .focus: return "Sharper Focus"
                case .anxiety: return "Less Anxiety"
                case .stress: return "Stress Relief"
                }
            } else {
                switch self {
                case .sleep: return "改善睡眠"
                case .focus: return "提升专注"
                case .anxiety: return "减少焦虑"
                case .stress: return "缓解压力"
                }
            }
        }
        
        var icon: String {
            switch self {
            case .sleep: return "moon.zzz.fill"
            case .focus: return "target"
            case .anxiety: return "heart.fill"
            case .stress: return "leaf.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .sleep: return Color(hex: "4ECDC4")
            case .focus: return Color(hex: "FFE66D")
            case .anxiety: return Color(hex: "FF6B6B")
            case .stress: return Color(hex: "A8E6CF")
            }
        }
        
        var description: String {
            if L10n.isUSVersion {
                switch self {
                case .sleep: return "Fall asleep faster and sleep deeper"
                case .focus: return "Rebuild your attention span"
                case .anxiety: return "Find inner peace and calm"
                case .stress: return "Release tension and relax"
                }
            } else {
                switch self {
                case .sleep: return "更快入睡，睡得更深"
                case .focus: return "重建你的专注力"
                case .anxiety: return "找到内心的平静"
                case .stress: return "释放紧张，放松身心"
                }
            }
        }
    }
    
    enum PreferredTime: String, CaseIterable {
        case morning = "morning"
        case afternoon = "afternoon"
        case evening = "evening"
        case night = "night"
        
        var displayName: String {
            if L10n.isUSVersion {
                switch self {
                case .morning: return "Morning (6-9 AM)"
                case .afternoon: return "Afternoon (12-6 PM)"
                case .evening: return "Evening (6-10 PM)"
                case .night: return "Night (10 PM-12 AM)"
                }
            } else {
                switch self {
                case .morning: return "早晨 (6-9点)"
                case .afternoon: return "下午 (12-18点)"
                case .evening: return "傍晚 (18-22点)"
                case .night: return "深夜 (22-24点)"
                }
            }
        }
        
        var icon: String {
            switch self {
            case .morning: return "sunrise.fill"
            case .afternoon: return "sun.max.fill"
            case .evening: return "sunset.fill"
            case .night: return "moon.stars.fill"
            }
        }
    }
    
    enum PracticeFrequency: String, CaseIterable {
        case daily = "daily"
        case frequent = "frequent"
        case weekly = "weekly"
        case flexible = "flexible"
        
        var displayName: String {
            if L10n.isUSVersion {
                switch self {
                case .daily: return "Every Day"
                case .frequent: return "3-4 Times/Week"
                case .weekly: return "Once a Week"
                case .flexible: return "When I Need It"
                }
            } else {
                switch self {
                case .daily: return "每天练习"
                case .frequent: return "每周3-4次"
                case .weekly: return "每周一次"
                case .flexible: return "随时随地"
                }
            }
        }
        
        var icon: String {
            switch self {
            case .daily: return "calendar"
            case .frequent: return "calendar.badge.clock"
            case .weekly: return "calendar.circle"
            case .flexible: return "clock"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background - 延续引导页的风格
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.0, blue: 0.3), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 80)
                
                // Title
                VStack(spacing: 12) {
                    Text(L10n.isUSVersion ? "Let Lumea Know You Better" : "让澄域更懂你")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(L10n.isUSVersion ? "What would you like to improve?" : "你最想改善什么？")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 30)
                
                Spacer().frame(height: 50)
                
                // Goal Cards
                VStack(spacing: 16) {
                    ForEach(UserGoal.allCases, id: \.self) { goal in
                        GoalCard(
                            goal: goal,
                            isSelected: selectedGoal == goal,
                            onSelect: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedGoal = goal
                                }
                                HapticManager.shared.impact(style: .light)
                                
                                // 选择后延迟显示结果页面
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    saveGoal(goal)
                                    showResultPage = true
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Skip Button
                Button(action: {
                    // 跳过直接进入主界面
                    isCompleted = true
                    UserDefaults.standard.set(false, forKey: "hasSeenSerenityGuide")
                }) {
                    Text(L10n.isUSVersion ? "Skip for now" : "暂时跳过")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.vertical, 12)
                }
                
                Spacer().frame(height: 40)
            }
        }
        .fullScreenCover(isPresented: $showResultPage) {
            if let goal = selectedGoal {
                PersonalizationResultView(
                    goal: goal,
                    onContinue: {
                        showResultPage = false
                        // 延迟显示订阅页面，让结果页面先消失
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showSubscription = true
                        }
                    }
                )
            }
        }
        .fullScreenCover(isPresented: $showSubscription) {
            SubscriptionView()
                .onDisappear {
                    // 订阅页面关闭后，完成整个引导流程
                    isCompleted = true
                    
                    // 重置 SerenityGuide，让用户首次进入主界面时看到功能引导
                    UserDefaults.standard.set(false, forKey: "hasSeenSerenityGuide")
                }
        }
    }
    
    private func saveGoal(_ goal: UserGoal) {
        UserDefaults.standard.set(goal.rawValue, forKey: "userPrimaryGoal")
        
        // 根据目标设置推荐功能
        let recommendedFeature: String
        switch goal {
        case .sleep, .anxiety:
            recommendedFeature = "calm"
        case .focus:
            recommendedFeature = "focus"
        case .stress:
            recommendedFeature = "touch"
        }
        UserDefaults.standard.set(recommendedFeature, forKey: "recommendedFirstFeature")
    }
}

// MARK: - Goal Card Component

struct GoalCard: View {
    let goal: PersonalizationView.UserGoal
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(goal.color.opacity(0.2))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: goal.icon)
                        .font(.system(size: 24))
                        .foregroundColor(goal.color)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.displayName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(goal.description)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Selection Indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? goal.color : Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(goal.color)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? goal.color.opacity(0.1) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isSelected ? goal.color.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(color: isSelected ? goal.color.opacity(0.3) : .clear, radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Personalization Result View

struct PersonalizationResultView: View {
    let goal: PersonalizationView.UserGoal
    let onContinue: () -> Void
    
    @State private var showContent = false
    
    var recommendedFeature: String {
        switch goal {
        case .sleep, .anxiety:
            return L10n.isUSVersion ? "Meditation" : "冥想"
        case .focus:
            return L10n.isUSVersion ? "Deep Reading" : "深度阅读"
        case .stress:
            return L10n.isUSVersion ? "Touch Anchor" : "触点锚定"
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.0, blue: 0.3), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Icon
                ZStack {
                    Circle()
                        .fill(goal.color.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: goal.icon)
                        .font(.system(size: 50))
                        .foregroundColor(goal.color)
                }
                .scaleEffect(showContent ? 1.0 : 0.5)
                .opacity(showContent ? 1.0 : 0.0)
                
                Spacer().frame(height: 40)
                
                // Title
                Text(L10n.isUSVersion ? "Perfect!" : "很好！")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(showContent ? 1.0 : 0.0)
                
                Spacer().frame(height: 20)
                
                // Description
                VStack(spacing: 12) {
                    Text(L10n.isUSVersion ? "We've prepared a personalized plan for you" : "我们为你准备了个性化方案")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                    
                    Text(L10n.isUSVersion ? "Recommended: \(recommendedFeature)" : "推荐功能：\(recommendedFeature)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(goal.color)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(goal.color.opacity(0.2))
                                .overlay(
                                    Capsule()
                                        .stroke(goal.color.opacity(0.5), lineWidth: 1)
                                )
                        )
                }
                .padding(.horizontal, 30)
                .opacity(showContent ? 1.0 : 0.0)
                
                Spacer()
                
                // Continue Button
                Button(action: {
                    HapticManager.shared.impact(style: .medium)
                    onContinue()
                }) {
                    Text(L10n.isUSVersion ? "Continue" : "继续")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            LinearGradient(
                                colors: [goal.color, goal.color.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(27)
                        .shadow(color: goal.color.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 30)
                .opacity(showContent ? 1.0 : 0.0)
                
                Spacer().frame(height: 60)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                showContent = true
            }
        }
    }
}
