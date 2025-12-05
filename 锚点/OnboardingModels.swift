import Foundation

// MARK: - User Profile Data Models

/// 用户痛点类型
enum UserPainPoint: String, CaseIterable, Codable {
    case anxiety = "anxiety"           // 焦虑不安
    case insomnia = "insomnia"         // 失眠困扰
    case distraction = "distraction"   // 注意力分散
    case stress = "stress"             // 压力过大
    case overwhelm = "overwhelm"       // 信息过载
    case burnout = "burnout"           // 精疲力竭
    
    var displayName: String {
        if L10n.isUSVersion {
            switch self {
            case .anxiety: return "Anxiety & Restlessness"
            case .insomnia: return "Sleep Issues"
            case .distraction: return "Can't Focus"
            case .stress: return "High Stress"
            case .overwhelm: return "Information Overload"
            case .burnout: return "Mental Exhaustion"
            }
        } else {
            switch self {
            case .anxiety: return "焦虑不安"
            case .insomnia: return "失眠困扰"
            case .distraction: return "注意力分散"
            case .stress: return "压力过大"
            case .overwhelm: return "信息过载"
            case .burnout: return "精疲力竭"
            }
        }
    }
    
    var icon: String {
        switch self {
        case .anxiety: return "bolt.heart.fill"
        case .insomnia: return "moon.zzz.fill"
        case .distraction: return "eye.trianglebadge.exclamationmark.fill"
        case .stress: return "flame.fill"
        case .overwhelm: return "brain.head.profile"
        case .burnout: return "battery.0"
        }
    }
    
    var color: String {
        switch self {
        case .anxiety: return "FF6B6B"
        case .insomnia: return "4ECDC4"
        case .distraction: return "FFE66D"
        case .stress: return "FF8B94"
        case .overwhelm: return "A8E6CF"
        case .burnout: return "C7CEEA"
        }
    }
}

/// 用户目标类型
enum UserGoal: String, CaseIterable, Codable {
    case betterSleep = "better_sleep"
    case reducedAnxiety = "reduced_anxiety"
    case improvedFocus = "improved_focus"
    case stressRelief = "stress_relief"
    case mentalClarity = "mental_clarity"
    case emotionalBalance = "emotional_balance"
    
    var displayName: String {
        if L10n.isUSVersion {
            switch self {
            case .betterSleep: return "Sleep Better"
            case .reducedAnxiety: return "Reduce Anxiety"
            case .improvedFocus: return "Improve Focus"
            case .stressRelief: return "Manage Stress"
            case .mentalClarity: return "Mental Clarity"
            case .emotionalBalance: return "Emotional Balance"
            }
        } else {
            switch self {
            case .betterSleep: return "改善睡眠"
            case .reducedAnxiety: return "减少焦虑"
            case .improvedFocus: return "提升专注"
            case .stressRelief: return "缓解压力"
            case .mentalClarity: return "头脑清晰"
            case .emotionalBalance: return "情绪平衡"
            }
        }
    }
    
    var icon: String {
        switch self {
        case .betterSleep: return "bed.double.fill"
        case .reducedAnxiety: return "heart.fill"
        case .improvedFocus: return "target"
        case .stressRelief: return "leaf.fill"
        case .mentalClarity: return "sparkles"
        case .emotionalBalance: return "scale.3d"
        }
    }
    
    /// 推荐的首次练习
    var recommendedFirstPractice: String {
        switch self {
        case .betterSleep, .reducedAnxiety:
            return "calm" // 冥想
        case .improvedFocus, .mentalClarity:
            return "focus" // 深度阅读
        case .stressRelief, .emotionalBalance:
            return "touch" // 触点锚定
        }
    }
}

/// 用户练习频率偏好
enum PracticeFrequency: String, CaseIterable, Codable {
    case daily = "daily"
    case fewTimesWeek = "few_times_week"
    case weekly = "weekly"
    case flexible = "flexible"
    
    var displayName: String {
        if L10n.isUSVersion {
            switch self {
            case .daily: return "Every Day"
            case .fewTimesWeek: return "3-4 Times/Week"
            case .weekly: return "Once a Week"
            case .flexible: return "When I Need It"
            }
        } else {
            switch self {
            case .daily: return "每天练习"
            case .fewTimesWeek: return "每周3-4次"
            case .weekly: return "每周一次"
            case .flexible: return "随时随地"
            }
        }
    }
}

/// 用户引导配置
struct OnboardingProfile: Codable {
    var painPoints: [UserPainPoint] = []
    var primaryGoal: UserGoal?
    var practiceFrequency: PracticeFrequency?
    var preferredTime: String? // "morning", "afternoon", "evening", "night"
    var hasCompletedQuickExperience: Bool = false
    var completedAt: Date?
    
    // 推荐的首次功能
    var recommendedFirstFeature: String {
        guard let goal = primaryGoal else { return "touch" }
        return goal.recommendedFirstPractice
    }
}

// MARK: - Onboarding Manager

@MainActor
class OnboardingManager: ObservableObject {
    static let shared = OnboardingManager()
    
    @Published var profile: OnboardingProfile
    @Published var hasCompletedOnboarding: Bool
    
    private let profileKey = "onboardingProfile"
    private let completedKey = "hasSeenOnboarding"
    
    private init() {
        // Load saved profile
        if let data = UserDefaults.standard.data(forKey: profileKey),
           let decoded = try? JSONDecoder().decode(OnboardingProfile.self, from: data) {
            self.profile = decoded
        } else {
            self.profile = OnboardingProfile()
        }
        
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: completedKey)
    }
    
    func updatePainPoints(_ points: [UserPainPoint]) {
        profile.painPoints = points
        saveProfile()
    }
    
    func updateGoal(_ goal: UserGoal) {
        profile.primaryGoal = goal
        saveProfile()
    }
    
    func updateFrequency(_ frequency: PracticeFrequency) {
        profile.practiceFrequency = frequency
        saveProfile()
    }
    
    func updatePreferredTime(_ time: String) {
        profile.preferredTime = time
        saveProfile()
    }
    
    func markQuickExperienceComplete() {
        profile.hasCompletedQuickExperience = true
        saveProfile()
    }
    
    func completeOnboarding() {
        profile.completedAt = Date()
        hasCompletedOnboarding = true
        saveProfile()
        UserDefaults.standard.set(true, forKey: completedKey)
        
        // 设置首次引导标记为false，让用户看到SerenityGuide
        UserDefaults.standard.set(false, forKey: "hasSeenSerenityGuide")
    }
    
    private func saveProfile() {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: profileKey)
        }
    }
    
    // 获取个性化欢迎消息
    func getPersonalizedWelcome() -> String {
        guard let goal = profile.primaryGoal else {
            return L10n.isUSVersion ? "Welcome to Lumea" : "欢迎来到澄域"
        }
        
        if L10n.isUSVersion {
            switch goal {
            case .betterSleep:
                return "Let's improve your sleep"
            case .reducedAnxiety:
                return "Let's find your calm"
            case .improvedFocus:
                return "Let's sharpen your focus"
            case .stressRelief:
                return "Let's ease your stress"
            case .mentalClarity:
                return "Let's clear your mind"
            case .emotionalBalance:
                return "Let's balance your emotions"
            }
        } else {
            switch goal {
            case .betterSleep:
                return "让我们改善你的睡眠"
            case .reducedAnxiety:
                return "让我们找到内心的平静"
            case .improvedFocus:
                return "让我们提升你的专注力"
            case .stressRelief:
                return "让我们缓解你的压力"
            case .mentalClarity:
                return "让我们清理你的思绪"
            case .emotionalBalance:
                return "让我们平衡你的情绪"
            }
        }
    }
}
