import SwiftUI
import Combine

struct TouchAnchorSessionView: View {
    @Binding var unlockNext: Bool
    @Environment(\.presentationMode) var presentationMode
    
    // Interaction State
    @State private var isHolding = false
    @State private var holdProgress: Double = 0.0
    @State private var isCompleted = false
    
    // Animation States
    @State private var turbulence: Double = 1.0 // 1.0 = Chaos, 0.0 = Calm
    @State private var breathingPhase: Double = 0.0 // 0 to 2pi
    @State private var time: Double = 0.0
    
    // Success Sequence (simplified)
    @State private var isFrozen: Bool = false // Absolute stillness
    
    // Breathing Guidance
    @State private var currentGuidanceIndex: Int = -1
    @State private var guidanceOpacity: Double = 0.0
    @State private var guidanceTimer: Timer?
    
    // Timer
    @State private var timer: Timer?
    @State private var animationTimer: Timer?
    let targetDuration: TimeInterval = 60.0 // 1 minute session
    
    var body: some View {
        ZStack {
            // 1. Background: Pure Black
            Color.black.ignoresSafeArea()
            
            // 2. Floor Caustics (Subtle grounding)
            ZStack {
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [.white.opacity(0.1), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 200, height: 40)
                    .offset(y: 120)
                    .blur(radius: 10)
                    .opacity(0.5 + sin(time) * 0.1) // Subtle pulse
            }
            
            // 3. The Sphere
            ZStack {
                    // A. Chromatic Aberration (The Soul)
                    // Idle: Random flickering. Active: Rhythmic breathing. Frozen: Zero.
                    if !isFrozen {
                        Group {
                            Circle()
                                .stroke(Color(red: 0, green: 1, blue: 1).opacity(0.4), lineWidth: 20)
                                .frame(width: 180, height: 180)
                                .blur(radius: 20)
                                .offset(
                                    x: turbulence * CGFloat.random(in: -3...3) + (1.0 - turbulence) * CGFloat(sin(breathingPhase) * 2),
                                    y: turbulence * CGFloat.random(in: -3...3)
                                )
                            
                            Circle()
                                .stroke(Color(red: 1, green: 0, blue: 1).opacity(0.4), lineWidth: 20)
                                .frame(width: 180, height: 180)
                                .blur(radius: 20)
                                .offset(
                                    x: turbulence * CGFloat.random(in: -3...3) - (1.0 - turbulence) * CGFloat(sin(breathingPhase) * 2),
                                    y: turbulence * CGFloat.random(in: -3...3)
                                )
                        }
                        .blendMode(.screen)
                    }
                    
                    // B. The Glass Body (Organic, Soft)
                    // No hard strokes. Defined by gradients.
                    if !isFrozen {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [.white.opacity(0.05), .clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 200, height: 200)
                            .blur(radius: 5)
                    } else {
                        // Frozen 状态：完全移除中心高光，只保留外圈
                        Circle()
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            .frame(width: 200, height: 200)
                    }
                    
                    // C. Internal Ripples (The Breath)
                    // Only visible when calm (turbulence low)
                    if turbulence < 0.5 && !isFrozen {
                        ForEach(0..<3) { i in
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                .frame(width: 100 + CGFloat(i * 30))
                                .scaleEffect(1.0 + CGFloat(sin(breathingPhase - Double(i) * 0.5)) * 0.1)
                                .opacity(0.5 + sin(breathingPhase - Double(i) * 0.5) * 0.3)
                                .blur(radius: 2)
                        }
                    }
                    
                    // D. Specular Highlights (Removed as per user request)
                    // Circle()
                    //     .trim(from: 0.6, to: 0.8)
                    //     ...
                    
                    // E. Progress (Subtle Ring)
                    if isHolding && !isFrozen {
                        Circle()
                            .trim(from: 0, to: CGFloat(holdProgress))
                            .stroke(
                                LinearGradient(colors: [.white, .white.opacity(0)], startPoint: .top, endPoint: .bottom),
                                style: StrokeStyle(lineWidth: 1, lineCap: .round)
                            )
                            .frame(width: 210, height: 210)
                            .rotationEffect(.degrees(-90))
                            .opacity(0.5)
                    }
            }
            
            // 4. Breathing Guidance Text
            if isHolding && !isCompleted && currentGuidanceIndex >= 0 && currentGuidanceIndex < guidanceTexts.count {
                VStack {
                    Spacer().frame(height: 100)
                    Text(guidanceTexts[currentGuidanceIndex])
                        .font(.system(size: 18, weight: .light, design: .rounded))
                        .foregroundColor(.white.opacity(guidanceOpacity * 0.7))
                        .tracking(2)
                    Spacer()
                }
                .transition(.opacity)
            }
            
            // 5. Text (Refracted)
            if !isCompleted {
                VStack {
                    Spacer().frame(height: 260)
                    if isHolding {
                        Text(timeString(from: holdProgress * targetDuration))
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                    } else {
                        Text(L10n.tapCrystal)
                            .font(.system(size: 13, weight: .light, design: .rounded))
                            .foregroundColor(.white.opacity(0.3))
                            .tracking(1.5)
                    }
                }
            }
        }
        .contentShape(Rectangle()) // Make entire ZStack tappable
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in if !isHolding && !isCompleted { startHolding() } }
                .onEnded { _ in 
                    if !isCompleted {
                        stopHolding()
                    }
                }
        )
        .onAppear {
            startAnimation()
            // No sound before holding starts
        }
        .onDisappear {
            stopHolding()
            stopAnimation()
            stopGuidance()
            SoundManager.shared.stopMeditationSounds()
        }
    }
    
    // MARK: - Guidance Texts
    
    private var guidanceTexts: [String] {
        if L10n.isUSVersion {
            return [
                "Feel, light enters",
                "Let mind, descend",
                "Absorb light, to touch.",
                "Breathe out, deeply.",
                "Gather, all things",
                "Release, clarity.",
                "Let go, skylight."
            ]
        } else {
            return [
                "感受，光入",
                "让心，沉降",
                "吸纳光，至触。",
                "缓吐息，深沉。",
                "聚，万象",
                "放，空明。",
                "释放，天光。"
            ]
        }
    }
    
    // MARK: - Logic
    
    private func startAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            time += 0.02
            
            if isHolding && !isFrozen {
                // Tame turbulence
                if turbulence > 0 {
                    turbulence = max(0, turbulence - 0.04) // 500ms to calm (0.02 * 25 frames)
                }
                
                // Breathing Rhythm (5-6s cycle -> ~0.17 Hz)
                // 2pi / 6s ~= 1.0 per second
                breathingPhase += 0.02 // Slow breath
            } else if !isFrozen {
                // Return to chaos
                if turbulence < 1.0 {
                    turbulence = min(1.0, turbulence + 0.05)
                }
            }
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func startHolding() {
        isHolding = true
        holdProgress = 0.0
        
        // Play ethereal meditation music
        SoundManager.shared.playMeditationMusic(named: "空灵.mp3")
        
        // Start breathing guidance
        startGuidance()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            holdProgress += 0.05 / targetDuration
            HapticManager.shared.playStickyDamping()
            
            if holdProgress >= 1.0 {
                completeSession()
            }
        }
    }
    
    private func stopHolding() {
        guard isHolding, !isCompleted else { return }
        
        isHolding = false
        timer?.invalidate()
        timer = nil
        
        stopGuidance()
        SoundManager.shared.stopMeditationSounds()
        
        // Reset visual state handled by animation loop (turbulence increases)
    }
    
    private func completeSession() {
        isCompleted = true
        timer?.invalidate()
        timer = nil
        
        // 停止音乐和引导
        SoundManager.shared.stopMeditationSounds()
        stopGuidance()
        
        // 触觉反馈
        HapticManager.shared.notification(type: .success)
        
        // 记录完成
        StatusManager.shared.recordAnchorSession(duration: targetDuration)
        unlockNext = true
        
        // 简短延迟后直接退出，不需要复杂的视觉效果
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func timeString(from time: TimeInterval) -> String {
        let remaining = max(0, targetDuration - time)
        let seconds = Int(remaining)
        let fraction = Int((remaining - Double(seconds)) * 100)
        return String(format: "%02d:%02d", seconds, fraction)
    }
    
    // MARK: - Breathing Guidance
    
    private func startGuidance() {
        stopGuidance() // Clear any existing guidance
        currentGuidanceIndex = -1
        guidanceOpacity = 0.0
        
        // First guidance appears after 2s
        guidanceTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            self.showNextGuidance()
        }
    }
    
    private func showNextGuidance() {
        guard isHolding, !isCompleted else { return }
        
        currentGuidanceIndex += 1
        
        // Check if we've shown all guidance texts
        if currentGuidanceIndex >= guidanceTexts.count {
            return
        }
        
        // Fade in
        withAnimation(.easeIn(duration: 1.0)) {
            guidanceOpacity = 1.0
        }
        
        // Determine duration based on index
        // First text (index 0): 4s visible
        // Subsequent texts alternate: 6s (even index), 4s (odd index)
        let visibleDuration: TimeInterval
        if currentGuidanceIndex == 0 {
            visibleDuration = 4.0
        } else if currentGuidanceIndex % 2 == 0 {
            visibleDuration = 6.0
        } else {
            visibleDuration = 4.0
        }
        
        // Schedule fade out and next guidance using Timer
        let totalDuration = visibleDuration + 1.0 + 1.0 // visible + fade out + gap
        guidanceTimer = Timer.scheduledTimer(withTimeInterval: visibleDuration, repeats: false) { _ in
            guard self.isHolding, !self.isCompleted else { return }
            
            withAnimation(.easeOut(duration: 1.0)) {
                self.guidanceOpacity = 0.0
            }
            
            // Schedule next guidance
            self.guidanceTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                self.showNextGuidance()
            }
        }
    }
    
    private func stopGuidance() {
        guidanceTimer?.invalidate()
        guidanceTimer = nil
        currentGuidanceIndex = -1
        withAnimation(.easeOut(duration: 0.3)) {
            guidanceOpacity = 0.0
        }
    }
}
