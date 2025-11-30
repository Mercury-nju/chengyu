import SwiftUI
import AVFoundation

struct CalmView: View {
    @State private var meditationState: MeditationState = .idle
    @State private var selectedDuration: TimeInterval = 300 // Default 5 mins
    @State private var remainingTime: TimeInterval = 300
    @State private var selectedSound: MeditationSound = .ethereal // Default Ethereal
    // Animation States
    @State private var coreScale: CGFloat = 0.1 // Start small for entry
    @State private var glowOpacity: Double = 0.3
    @State private var breathingScale: CGFloat = 1.0 // Breathing rhythm scale
    @State private var uiOpacity: Double = 0.0
    @State private var isBreathing: Bool = false
    @State private var breathingTimer: Timer?
    
    // Interaction States
    @State private var isLongPressing: Bool = false
    @State private var longPressProgress: CGFloat = 0.0
    
    // Timer
    @State private var timer: Timer?
    @State private var hintTimer: Timer?
    @State private var longPressTimer: Timer?
    
    // Double-tap hint
    @State private var lastTapTime: Date?
    @State private var showExitHint: Bool = false
    @State private var showSubscriptionAlert: Bool = false
    @State private var showSubscriptionView: Bool = false
    
    enum MeditationState {
        case idle
        case meditating
        case paused
        case completed
    }
    
    enum MeditationSound: String, CaseIterable, Identifiable {
        // 免费音乐
        case relax
        case morning
        case soul
        case modernClassical
        case ethereal
        case soothing
        case beat
        case lightRain
        
        // 会员音乐
        case atmosphere
        case calm
        case tranquil
        case pleasant
        case forest
        case valley
        case sunshine
        case healing
        
        var id: String { self.rawValue }
        
        var displayName: String {
            switch self {
            case .relax: return L10n.musicRelax
            case .morning: return L10n.musicMorning
            case .soul: return L10n.musicSoul
            case .modernClassical: return L10n.musicClassical
            case .ethereal: return L10n.musicEthereal
            case .soothing: return L10n.musicSoothing
            case .beat: return L10n.musicBeat
            case .lightRain: return L10n.musicRain
            case .atmosphere: return L10n.musicAtmosphere
            case .calm: return L10n.musicCalm
            case .tranquil: return L10n.musicTranquil
            case .pleasant: return L10n.musicPleasant
            case .forest: return L10n.musicForest
            case .valley: return L10n.musicValley
            case .sunshine: return L10n.musicSunshine
            case .healing: return L10n.musicHealing
            }
        }
        
        var isPremium: Bool {
            switch self {
            case .atmosphere, .calm, .tranquil, .pleasant, .forest, .valley, .sunshine, .healing:
                return true
            default:
                return false
            }
        }
        
        var filename: String {
            switch self {
            // 免费音乐
            case .relax: return "放松.mp3"
            case .morning: return "清晨.mp3"
            case .soul: return "灵魂.mp3"
            case .modernClassical: return "现代古典.mp3"
            case .ethereal: return "空灵.mp3"
            case .soothing: return "舒缓.mp3"
            case .beat: return "节拍.mp3"
            case .lightRain: return "轻雨.wav"
            
            // 会员音乐（从会员音乐文件夹）
            case .atmosphere: return "会员音乐/氛围.mp3"
            case .calm: return "会员音乐/冷静.mp3"
            case .tranquil: return "会员音乐/宁静.mp3"
            case .pleasant: return "会员音乐/惬意.mp3"
            case .forest: return "会员音乐/森林.mp3"
            case .valley: return "会员音乐/山谷.mp3"
            case .sunshine: return "会员音乐/阳光.mp3"
            case .healing: return "会员音乐/治愈.mp3"
            }
        }
        
        var icon: String {
            switch self {
            // 免费音乐
            case .relax: return "leaf.fill"
            case .morning: return "sun.max.fill"
            case .soul: return "heart.fill"
            case .modernClassical: return "music.note"
            case .ethereal: return "wind"
            case .soothing: return "drop.fill"
            case .beat: return "waveform"
            case .lightRain: return "cloud.rain.fill"
            
            // 会员音乐
            case .atmosphere: return "sparkles"
            case .calm: return "moon.stars.fill"
            case .tranquil: return "water.waves"
            case .pleasant: return "sun.haze.fill"
            case .forest: return "tree.fill"
            case .valley: return "mountain.2.fill"
            case .sunshine: return "sun.and.horizon.fill"
            case .healing: return "heart.circle.fill"
            }
        }
    }
    
    @State private var activePanel: ActivePanel = .none
    
    enum ActivePanel {
        case none
        case duration
        case music
    }
    
    var body: some View {
        ZStack {
            // 1. Pure Black Background
            ThemeManager.shared.currentTheme.backgroundView
            
            // 2. The Visual Anchor (Center) with Hint
            VStack(spacing: 0) {
                ZStack {
                    // Outer Glow (Breathing Brightness)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 250, height: 250)
                        .blur(radius: 80)
                        .opacity(glowOpacity)
                    
                    // Inner Core (Perfect Sphere)
                    FluidSphereView(
                        isInteracting: .constant(false),
                        touchLocation: .zero,
                        material: currentMaterial, // Sync with Flow State
                        stability: 100.0,
                        isTransparent: true, // Remove background card
                        isStatic: true // Keep sphere static during meditation
                    )
                    .frame(width: 280, height: 280)
                    .opacity(0.9)
                }
                .scaleEffect(coreScale * breathingScale) // Combine base scale with breathing
                
                // Gentle Hint below sphere (Idle State only)
                if meditationState == .idle {
                    Text(L10n.tapSphereToMeditate)
                        .font(.system(size: 13, weight: .light, design: .rounded))
                        .foregroundColor(.white.opacity(0.3))
                        .tracking(1.5)
                        .padding(.top, 40)
                        .opacity(uiOpacity)
                        .transition(.opacity)
                }
            }
            .offset(y: meditationState == .idle ? -80 : 0) // Move up slightly more in idle
            
            // 3. Interaction Layer (Background Tap)
            Color.black.opacity(0.001)
                .onTapGesture {
                    if activePanel != .none {
                        // 关闭面板前检查会员音乐订阅
                        checkPremiumMusicBeforeClosing()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            activePanel = .none
                        }
                    } else if meditationState == .idle {
                        // Optional: Tap sphere to start? Or just rely on strips?
                        // User request says "Meditation starts -> strips fade out". 
                        // Usually there's a "Start" button or tapping the sphere starts it.
                        // Let's keep tap sphere to start for now, but only if no panel is open.
                        startMeditation()
                    } else if meditationState == .meditating {
                        handleTap()
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if meditationState == .meditating && !isLongPressing {
                                isLongPressing = true
                                startLongPressTimer()
                            }
                        }
                        .onEnded { _ in
                            if meditationState == .meditating {
                                cancelLongPress()
                            }
                        }
                )
            
            // 4. Light Shadow Atmosphere Strips (Idle State)
            if meditationState == .idle {
                VStack(spacing: 24) { // "Ample vertical spacing"
                    Spacer()
                    
                    // Duration Strip
                    AtmosphereStrip(
                        title: L10n.selectDuration,
                        value: "\(Int(selectedDuration/60)) \(L10n.minutes)",
                        isActive: activePanel == .duration
                    ) {
                        openPanel(.duration)
                    }
                    
                    // Music Strip
                    AtmosphereStrip(
                        title: L10n.selectMusic,
                        value: selectedSound.displayName,
                        isActive: activePanel == .music
                    ) {
                        openPanel(.music)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 60)
                .opacity(uiOpacity)
                .transition(.opacity)
            }
            
            // 5. Meditating UI (Minimalist)
            if meditationState == .meditating || meditationState == .paused {
                VStack {
                    // Countdown (Top Right, Subtle)
                    HStack {
                        Spacer()
                        Text(formatTime(remainingTime))
                            .font(.system(size: 14, weight: .light, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.top, 60)
                            .padding(.trailing, 30)
                    }
                    
                    Spacer()
                    

                }
            }
            
            // 6. Pause Overlay
            if meditationState == .paused {
                Image(systemName: "pause.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.5))
                    .allowsHitTesting(false)
            }
            
            // 7. Exit Hint
            VStack {
                if showExitHint {
                    Text(L10n.isUSVersion ? "Hold 2s to exit meditation" : "长按2秒退出冥想")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.top, 60)
                        .transition(.opacity)
                }
                Spacer()
            }
            .allowsHitTesting(false)
            
            // 8. Completion View
            if meditationState == .completed {
                VStack(spacing: 20) {
                    Text("+\(Int(min(selectedDuration/60, 30)))% SV")
                        .font(.system(size: 32, weight: .light, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .white, radius: 10)
                    
                    Button(action: {
                        resetToIdle()
                    }) {
                        Text(L10n.completed)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 30)
                            .padding(.vertical, 10)
                            .background(Capsule().stroke(Color.white.opacity(0.3)))
                    }
                }
                .transition(.opacity)
                .zIndex(100)
            }
            
            // 9. Selection Panels (Overlay)
            if activePanel != .none {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // 关闭面板前检查会员音乐订阅
                        checkPremiumMusicBeforeClosing()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            activePanel = .none
                        }
                    }
                    .transition(.opacity)
                
                VStack {
                    Spacer()
                    
                    if activePanel == .duration {
                        SelectionPanel(title: "选择时长") {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 20) {
                                ForEach([300.0, 600.0, 1200.0, 1800.0], id: \.self) { duration in
                                    VStack(spacing: 8) {
                                        Image(systemName: "clock.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(selectedDuration == duration ? .white : .white.opacity(0.5))
                                        
                                        Text("\(Int(duration/60)) \(L10n.minutes)")
                                            .font(.system(size: 12))
                                            .foregroundColor(selectedDuration == duration ? .white : .white.opacity(0.5))
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(selectedDuration == duration ? Color.white.opacity(0.1) : Color.clear)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(selectedDuration == duration ? Color.white.opacity(0.3) : Color.clear, lineWidth: 1)
                                    )
                                    .onTapGesture {
                                        selectDuration(duration)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else if activePanel == .music {
                        SelectionPanel(title: L10n.selectMusic) {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 20) {
                                ForEach(MeditationSound.allCases) { sound in
                                    MusicOptionView(
                                        sound: sound,
                                        isSelected: selectedSound == sound,
                                        onSelect: {
                                            selectSound(sound)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .transition(.move(edge: .bottom))
                .zIndex(200)
            }
            // 10. Custom Subscription Alert Overlay
            if showSubscriptionAlert {
                SubscriptionAlertOverlay(
                    musicName: selectedSound.displayName,
                    onUpgrade: {
                        // 跳转到订阅页面
                        showSubscriptionAlert = false
                        showSubscriptionView = true
                    },
                    onDismiss: {
                        showSubscriptionAlert = false
                    }
                )
                .zIndex(300)
                .transition(.opacity)
            }
        }
        .sheet(isPresented: $showSubscriptionView) {
            SubscriptionView()
        }
        .onAppear {
            // 不停止背景音乐，让它继续播放
            // 如果用户选择了冥想音乐，会在 playSound 中自动切换
            animateEntry()
        }
        .onDisappear {
            stopMeditation(isDisappearing: true)
            hintTimer?.invalidate()
            longPressTimer?.invalidate()
            // 离开冥想页面时，如果没有在播放冥想音乐，恢复背景音乐
            if meditationState == .idle {
                SoundManager.shared.startAmbientBackgroundMusic()
            }
        }
    }
    
    // MARK: - Helper Views
    
    struct MusicOptionView: View {
        let sound: MeditationSound
        let isSelected: Bool
        let onSelect: () -> Void
        @ObservedObject private var subscriptionManager = SubscriptionManager.shared
        
        var body: some View {
            Button(action: {
                print("🎵 [MusicOptionView] Button tapped: \(sound.rawValue)")
                print("🎵 [MusicOptionView] isPremium: \(sound.isPremium)")
                
                // 允许试听所有音乐
                print("🎵 [MusicOptionView] Calling onSelect()")
                onSelect()
            }) {
                ZStack {
                    VStack(spacing: 8) {
                        ZStack {
                            Image(systemName: sound.icon)
                                .font(.system(size: 24))
                                .foregroundColor(isSelected ? .white : .white.opacity(0.5))
                            
                            // 锁定图标（会员音乐且未订阅）
                            if sound.isPremium && !subscriptionManager.isPremium {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.6))
                                    .offset(x: 15, y: -15)
                                    .shadow(color: .black.opacity(0.3), radius: 2)
                            }
                        }
                        
                        Text(sound.displayName)
                            .font(.system(size: 12))
                            .foregroundColor(isSelected ? .white : .white.opacity(0.5))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isSelected ? Color.white.opacity(0.1) : Color.clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.white.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
                    .opacity(sound.isPremium && !subscriptionManager.isPremium ? 0.6 : 1.0)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    struct AtmosphereStrip: View {
        let title: String
        let value: String
        let isActive: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack {
                    Text(title)
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                    
                    Text(value)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.6), radius: 8)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(
                    ZStack {
                        // Frosted Glass
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .opacity(0.3)
                        
                        // Glow Border
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.2),
                                        .white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                            .shadow(color: .white.opacity(0.1), radius: 4)
                    }
                )
                .scaleEffect(isActive ? 0.98 : 1.0)
            }
            .buttonStyle(StripButtonStyle())
        }
    }
    
    struct StripButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white.opacity(configuration.isPressed ? 0.1 : 0.0))
                )
        }
    }
    
    struct SelectionPanel<Content: View>: View {
        let title: String
        let content: () -> Content
        
        var body: some View {
            VStack(spacing: 0) {
                // Handle
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.bottom, 20)
                
                ScrollView {
                    content()
                        .padding(.bottom, 40)
                }
                .frame(maxHeight: 400)
            }
            .background(
                ZStack {
                    Color.black.opacity(0.8)
                    Rectangle().fill(.ultraThinMaterial).opacity(0.5)
                }
                .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
                .ignoresSafeArea()
            )
        }
    }
    
    
    // MARK: - Logic & Animations
    
    func animateEntry() {
        // Animate core scale from small to normal
        withAnimation(.spring(response: 1.2, dampingFraction: 0.7)) {
            coreScale = 1.0
            uiOpacity = 1.0
        }
        
        // Start breathing animation
        startBreathing()
    }
    
    func openPanel(_ panel: ActivePanel) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            activePanel = panel
        }
        triggerFeedback()
    }
    
    func startBreathing() {
        stopBreathingAnimation()
        isBreathing = true
        runBreathingCycle()
    }
    
    func runBreathingCycle() {
        guard isBreathing else { return }
        
        // Simple breathing rhythm: 4s inhale, 4s exhale
        let inhaleDuration: Double = 4.0
        let exhaleDuration: Double = 4.0
        
        // Inhale
        withAnimation(.easeInOut(duration: inhaleDuration)) {
            breathingScale = 1.2
            glowOpacity = 0.8
        }
        
        // Exhale after inhale completes
        breathingTimer = Timer.scheduledTimer(withTimeInterval: inhaleDuration, repeats: false) { _ in
            guard self.isBreathing else { return }
            
            withAnimation(.easeInOut(duration: exhaleDuration)) {
                self.breathingScale = 1.0
                self.glowOpacity = 0.3
            }
        }
        
        // Schedule next cycle
        let totalDuration = inhaleDuration + exhaleDuration
        breathingTimer = Timer.scheduledTimer(withTimeInterval: totalDuration, repeats: false) { _ in
            self.runBreathingCycle()
        }
    }
    
    func stopBreathingAnimation() {
        isBreathing = false
        breathingTimer?.invalidate()
        breathingTimer = nil
        
        // Reset visual state
        withAnimation(.easeOut(duration: 0.5)) {
            breathingScale = 1.0
            glowOpacity = 0.3
        }
    }
    
    func selectDuration(_ duration: TimeInterval) {
        selectedDuration = duration
        remainingTime = duration
        triggerFeedback()
    }
    
    func selectSound(_ sound: MeditationSound) {
        print("🎵 [CalmView] selectSound called with: \(sound.rawValue)")
        
        // 允许选择和试听所有音乐（包括会员音乐）
        print("🎵 [CalmView] 选择音乐: \(sound.rawValue) - \(sound.filename)")
        selectedSound = sound
        print("🎵 [CalmView] Calling playSound...")
        playSound(sound)
        print("🎵 [CalmView] Calling triggerFeedback...")
        triggerFeedback()
        
        // 不自动关闭面板，让用户手动下滑关闭
        print("🎵 [CalmView] selectSound completed (panel stays open)")
    }
    
    func triggerFeedback() {
        // Subtle flash of the core
        let currentGlow = glowOpacity
        withAnimation(.easeOut(duration: 0.2)) {
            glowOpacity = 0.8
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
            glowOpacity = currentGlow
        }
    }
    
    func handleTap() {
        if meditationState == .idle {
            startMeditation()
        } else if meditationState == .meditating {
            // Detect double-tap
            let now = Date()
            if let lastTap = lastTapTime, now.timeIntervalSince(lastTap) < 0.3 {
                // Double-tap detected
                showExitHintTemporarily()
            }
            lastTapTime = now
        }
    }
    
    func startMeditation() {
        withAnimation(.easeInOut(duration: 1.0)) {
            meditationState = .meditating
            uiOpacity = 0.0 // Fade out options
            coreScale = 1.2 // Slightly larger for immersion
        }
        
        // 播放选中的音乐
        playSound(selectedSound)
        
        // Deepen breathing rhythm (Using selected method)
        startBreathing()
        
        startTimer()
    }
    
    func showExitHintTemporarily() {
        // Cancel existing timer if any
        hintTimer?.invalidate()
        
        // Show hint
        withAnimation(.easeIn(duration: 0.3)) {
            showExitHint = true
        }
        
        // Hide after 1 second
        hintTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            withAnimation(.easeOut(duration: 0.3)) {
                showExitHint = false
            }
        }
    }
    
    func startLongPressTimer() {
        longPressProgress = 0.0
        longPressTimer?.invalidate()
        
        let startTime = Date()
        longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [self] _ in
            let elapsed = Date().timeIntervalSince(startTime)
            longPressProgress = min(CGFloat(elapsed / 2.0), 1.0)
            
            if longPressProgress >= 1.0 {
                longPressTimer?.invalidate()
                longPressTimer = nil
                isLongPressing = false
                stopMeditation()
            }
        }
    }
    
    func cancelLongPress() {
        longPressTimer?.invalidate()
        longPressTimer = nil
        withAnimation {
            isLongPressing = false
            longPressProgress = 0.0
        }
    }
    
    func stopMeditation(isDisappearing: Bool = false) {
        withAnimation {
            meditationState = .idle
        }
        
        timer?.invalidate()
        timer = nil
        longPressTimer?.invalidate()
        longPressTimer = nil
        hintTimer?.invalidate()
        hintTimer = nil
        
        isLongPressing = false
        longPressProgress = 0.0
        showExitHint = false
        
        if isDisappearing {
            SoundManager.shared.stopMeditationSounds()
        } else {
            resetToIdle()
        }
    }
    
    func completeMeditation() {
        // Smooth transition to completion state
        withAnimation(.easeOut(duration: 0.8)) {
            meditationState = .completed
        }
        timer?.invalidate()
        // Sound removed for peaceful completion
        StatusManager.shared.recordMeditationSession(duration: selectedDuration)
    }
    
    func resetToIdle() {
        timer?.invalidate()
        remainingTime = selectedDuration
        withAnimation {
            meditationState = .idle
            uiOpacity = 1.0
            coreScale = 1.0
            glowOpacity = 0.3
            breathingScale = 1.0 // Reset breathing scale
        }
        startBreathing()
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                completeMeditation()
            }
        }
    }
    
    // MARK: - Audio & Helpers
    
    func playSound(_ sound: MeditationSound) {
        print("🎵 CalmView.playSound: \(sound.filename)")
        SoundManager.shared.playMeditationMusic(named: sound.filename)
        SoundManager.shared.setMeditationVolume(0.5)
    }
    
    func checkPremiumMusicBeforeClosing() {
        // 如果选中的是会员音乐且用户未订阅，显示提示
        if selectedSound.isPremium && !SubscriptionManager.shared.isPremium {
            showSubscriptionAlert = true
            // 恢复到默认的免费音乐
            selectedSound = .ethereal
            playSound(selectedSound)
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func getSoundIcon(_ sound: MeditationSound) -> String {
        return sound.icon
    }
    
    // MARK: - Helpers
    
    private var currentMaterial: FluidSphereView.SphereMaterial {
        let savedMaterial = StatusManager.shared.sphereMaterial
        switch savedMaterial {
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
        case "ink": return .ink
        case "void": return .void
        default: return .default
        }
    }
}

// MARK: - Rounded Corner Shape

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
