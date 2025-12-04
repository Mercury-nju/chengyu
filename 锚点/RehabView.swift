import SwiftUI

struct RehabView: View {
    @State private var showTouchSession = false
    @State private var showFocusSession = false
    @State private var showVoiceSession = false
    
    @State private var isInteractingWithFluid = false
    @State private var touchLocation: CGPoint = .zero
    @State private var showCards = true
    @State private var dragOffset: CGFloat = 0
    @State private var isStabilizing = false // 长按稳定光球
    @State private var stabilizingProgress: Double = 0.0 // 稳定进度 0-1
    @State private var stabilizingTimer: Timer?
    
    // Serenity Guide State
    // Default to FALSE so new users see the guide
    @AppStorage("hasSeenSerenityGuide") var hasSeenGuide: Bool = false
    @State private var showGuide: Bool = false
    @State private var currentStep = 0
    @State private var targetFrames: [Int: CGRect] = [:]
    
    // Derived state for card visibility during guide
    var effectiveShowCards: Bool {
        if showGuide && currentStep == 0 {
            return false // Hide cards during Sphere intro
        }
        return showCards
    }
    
    @ObservedObject var statusManager = StatusManager.shared // Observe status
    @ObservedObject var themeManager = ThemeManager.shared // Observe theme
    @State private var showThemeSheet = false
    @State private var showSubscriptionView = false
    @State private var currentMaterial: FluidSphereVisualizer.SphereMaterial = .default
    @State private var currentStability: Double = 50.0
    
    // Helper to convert String -> Enum
    private func updateMaterial() {
        currentMaterial = switch statusManager.sphereMaterial {
        case "lava": .lava
        case "ice": .ice
        case "amber": .amber
        case "gold": .gold
        case "neon": .neon
        case "nebula": .nebula
        case "aurora": .aurora
        case "sakura": .sakura
        case "ocean": .ocean
        case "sunset": .sunset
        case "forest": .forest
        case "galaxy": .galaxy
        case "crystal": .crystal
        default: .default
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            themeManager.currentTheme.backgroundView
            
            // 1. Fluid Sphere - 独立层，不受背景影响
            PersistentFluidSphere(
                isInteracting: $isInteractingWithFluid,
                touchLocation: $touchLocation,
                material: currentMaterial,
                stability: currentStability,
                showCards: effectiveShowCards
            )
            .equatable() // 只在相关属性改变时重建
            .anchorPreference(key: GuideAnchorKey.self, value: .bounds) { anchor in
                return [0: anchor] // Step 0: Sphere
            }
            
            // 2. Foreground: Task Cards (Floating Light Shadow Cards)
            VStack {
                // Top Bar with Theme Switcher
                HStack {
                    Button(action: {
                        showThemeSheet = true
                    }) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.4))
                            .padding(10)
                    }
                    .padding(.leading, 20)
                    .padding(.top, 60)
                    
                    Spacer()
                    
                    // Preview Mode Unlock Indicator
                    if themeManager.isPreviewMode {
                        Button(action: {
                            showSubscriptionView = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 12))
                                Text(L10n.previewMode)
                                    .font(.system(size: 13, weight: .medium))
                                Text(L10n.unlock)
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "FFD700").opacity(0.2))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color(hex: "FFD700").opacity(0.6), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 60)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                
                Spacer()
                
                if effectiveShowCards {
                    VStack(spacing: 16) {
                        // Logic for Sequential Tasks
                        // 1. Touch Anchor: Always unlocked. Active if not completed.
                        let isTouchLocked = false
                        let isTouchActive = !statusManager.isTouchCompleted
                        
                        // 2. Flow Core: Locked if Touch not completed. Active if unlocked & not completed.
                        let isFlowLocked = !statusManager.isTouchCompleted
                        let isFlowActive = !isFlowLocked && !statusManager.isFlowCompleted
                        
                        // 3. Emotional Photolysis: Locked if Flow not completed. Active if unlocked & not completed.
                        let isPhotoLocked = !statusManager.isFlowCompleted
                        let isPhotoActive = !isPhotoLocked && !statusManager.isVoiceCompleted
                        
                        // Special Case: If all completed, nothing is "Active" (pulsing), or maybe just free access.
                        // The requirement says "After all tasks completed, user can continue freely".
                        // So we keep them unlocked but maybe not pulsing if completed.
                        
                        // Card 1: Touch Anchor
                        LightShadowCard(
                            title: L10n.touchAnchorTitle,
                            subtitle: statusManager.isTouchCompleted ? L10n.touchAnchorCompleted : L10n.touchAnchorSubtitle,
                            iconType: .ripple,
                            color: Theme.dopamineBlue,
                            isCompleted: statusManager.isTouchCompleted,
                            isLocked: isTouchLocked,
                            isActive: isTouchActive
                        ) {
                            showTouchSession = true
                        }
                        .anchorPreference(key: GuideAnchorKey.self, value: .bounds) { anchor in
                            return [1: anchor]
                        }

                        
                        // Card 2: Flow Core Casting
                        LightShadowCard(
                            title: L10n.flowReadingTitle,
                            subtitle: statusManager.isFlowCompleted ? L10n.flowReadingCompleted : L10n.flowReadingSubtitle,
                            iconType: .eye,
                            color: Color(red: 1.0, green: 0.8, blue: 0.4),
                            isCompleted: statusManager.isFlowCompleted,
                            isLocked: isFlowLocked,
                            isActive: isFlowActive
                        ) {
                            showFocusSession = true
                        }
                        .anchorPreference(key: GuideAnchorKey.self, value: .bounds) { anchor in
                            return [2: anchor]
                        }

                        
                        // Card 3: Emotional Photolysis
                        LightShadowCard(
                            title: L10n.emotionReleaseTitle,
                            subtitle: statusManager.isVoiceCompleted ? L10n.emotionReleaseCompleted : L10n.emotionReleaseSubtitle,
                            iconType: .purification,
                            color: Color(red: 1.0, green: 0.4, blue: 0.4),
                            isCompleted: statusManager.isVoiceCompleted,
                            isLocked: isPhotoLocked,
                            isActive: isPhotoActive
                        ) {
                            showVoiceSession = true
                        }
                        .anchorPreference(key: GuideAnchorKey.self, value: .bounds) { anchor in
                            return [3: anchor]
                        }

                        
                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: effectiveShowCards)
        }
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .simultaneousGesture(
            // 长按手势：逐渐稳定光球
            LongPressGesture(minimumDuration: 0.5)
                .onChanged { _ in
                    // 开始长按，启动渐进稳定
                    if !isStabilizing {
                        isStabilizing = true
                        startStabilizing()
                    }
                }
                .onEnded { _ in
                    // 松开，恢复原状
                    stopStabilizing()
                }
        )
        .gesture(
            // 滑动手势：显示/隐藏卡片
            DragGesture(minimumDistance: 30)
                .onChanged { value in
                    dragOffset = value.translation.height
                }
                .onEnded { value in
                    if !showCards {
                        // 卡片隐藏时：上滑显示卡片
                        if dragOffset < -100 {
                            withAnimation {
                                showCards = true
                            }
                        }
                    } else {
                        // 卡片显示时：下滑隐藏卡片
                        if dragOffset > 100 {
                            withAnimation {
                                showCards = false
                            }
                        }
                    }
                    
                    dragOffset = 0
                }
        ) // Ensure ZStack fills screen for correct coordinate space
        .overlayPreferenceValue(GuideAnchorKey.self) { preferences in
            GeometryReader { geometry in
                if showGuide {
                    SerenityGuideView(
                        currentStep: $currentStep,
                        targetFrames: preferences.reduce(into: [:]) { result, pair in
                            result[pair.key] = geometry[pair.value]
                        },
                        onDismiss: {
                            showGuide = false
                            hasSeenGuide = true
                        }
                    )
                }
            }
            .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showTouchSession) {
            TouchAnchorSessionView(unlockNext: .constant(true))
        }
        .fullScreenCover(isPresented: $showFocusSession) {
            MindfulRevealSessionView(unlockNext: .constant(true))
        }
        .fullScreenCover(isPresented: $showVoiceSession) {
            VoiceLogSessionView()
        }
        .onAppear {
            updateMaterial()
            currentStability = calculateStability()
            if !hasSeenGuide {
                showGuide = true
            }
        }
        .onChange(of: statusManager.sphereMaterial) { _ in
            updateMaterial()
        }
        .onChange(of: statusManager.stabilityValue) { _ in
            currentStability = calculateStability()
        }
        .onChange(of: isStabilizing) { _ in
            currentStability = calculateStability()
        }
        .onChange(of: stabilizingProgress) { _ in
            if isStabilizing {
                currentStability = calculateStability()
            }
        }
        .sheet(isPresented: $showThemeSheet) {
            ThemeSelectionView()
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSubscriptionView) {
            SubscriptionView()
        }
    }
    
    // MARK: - Stabilizing Methods
    
    private func calculateStability() -> Double {
        // 引导模式下的特殊处理
        if showGuide && currentStep == 0 {
            return 30.0
        }
        
        // 长按时，根据进度逐渐提升稳定值
        if isStabilizing {
            let baseStability = statusManager.stabilityValue
            let targetStability = 100.0
            return baseStability + (targetStability - baseStability) * stabilizingProgress
        }
        
        // 正常状态
        return statusManager.stabilityValue
    }
    
    private func startStabilizing() {
        stabilizingProgress = 0.0
        
        // 创建定时器，每 0.05 秒增加进度
        stabilizingTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            if self.stabilizingProgress < 1.0 {
                withAnimation(.linear(duration: 0.05)) {
                    self.stabilizingProgress = min(1.0, self.stabilizingProgress + 0.02)
                }
            }
        }
    }
    
    private func stopStabilizing() {
        // 停止定时器
        stabilizingTimer?.invalidate()
        stabilizingTimer = nil
        
        // 恢复原状
        withAnimation(.easeOut(duration: 0.5)) {
            isStabilizing = false
            stabilizingProgress = 0.0
        }
    }
}




struct GuideAnchorKey: PreferenceKey {
    static var defaultValue: [Int: Anchor<CGRect>] = [:]
    static func reduce(value: inout [Int: Anchor<CGRect>], nextValue: () -> [Int: Anchor<CGRect>]) {
        value.merge(nextValue()) { $1 }
    }
}

struct ThemeSelectionView: View {
    @ObservedObject var themeManager = ThemeManager.shared
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var showSubscription = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                Text(L10n.selectTheme)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                    .padding(.bottom, 24)
                
                // Grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 20) {
                    ForEach(AppTheme.allCases) { theme in
                        Button(action: {
                            if theme.isPremium && !subscriptionManager.isPremium {
                                // Allow preview mode
                                themeManager.setTheme(theme, isPreview: true)
                                dismiss()
                            } else {
                                themeManager.setTheme(theme, isPreview: false)
                                dismiss()
                            }
                        }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(themePreviewColor(for: theme))
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Circle()
                                                .stroke(themeManager.currentTheme == theme ? Color.white : Color.white.opacity(0.1), lineWidth: themeManager.currentTheme == theme ? 2 : 1)
                                        )
                                    
                                    if themeManager.currentTheme == theme {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)
                                    } else if theme.isPremium && !subscriptionManager.isPremium {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                                
                                Text(theme.displayName)
                                    .font(.caption)
                                    .foregroundColor(themeManager.currentTheme == theme ? .white : .white.opacity(0.5))
                                
                                // 只在非会员状态下显示 VIP 标签
                                if theme.isPremium && !subscriptionManager.isPremium {
                                    Text("VIP")
                                        .font(.system(size: 8, weight: .bold))
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background(Color(hex: "FFD700").opacity(0.2))
                                        .foregroundColor(Color(hex: "FFD700"))
                                        .cornerRadius(4)
                                }
                            }
                        }
                    }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showSubscription) {
            SubscriptionView()
        }
    }
    
    func themePreviewColor(for theme: AppTheme) -> Color {
        switch theme {
        case .universe: return .black
        case .deepSea: return Color(hex: "001020")
        case .starrySky: return Color(hex: "101025")
        case .forest: return Color(hex: "051510")
        case .nebula: return Color(hex: "200020")
        case .aurora: return Color(hex: "002020")
        case .sunset: return Color(hex: "301005")
        case .midnight: return Color(hex: "000520")
        case .oceanDepths: return Color(hex: "001020")
        case .cherryBlossom: return Color(hex: "200818")
        }
    }
}

// MARK: - Persistent Fluid Sphere Wrapper

struct PersistentFluidSphere: View, Equatable {
    @Binding var isInteracting: Bool
    @Binding var touchLocation: CGPoint
    let material: FluidSphereVisualizer.SphereMaterial
    let stability: Double
    let showCards: Bool
    
    static func == (lhs: PersistentFluidSphere, rhs: PersistentFluidSphere) -> Bool {
        // 只有这些属性改变时才重建视图
        return lhs.material == rhs.material &&
               lhs.stability == rhs.stability &&
               lhs.showCards == rhs.showCards &&
               lhs.isInteracting == rhs.isInteracting &&
               lhs.touchLocation == rhs.touchLocation
    }
    
    var body: some View {
        FluidSphereVisualizer(
            isInteracting: $isInteracting,
            touchLocation: touchLocation,
            material: material,
            stability: stability,
            isTransparent: true,
            isStatic: false
        )
        .offset(y: showCards ? -180 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showCards)
    }
}
