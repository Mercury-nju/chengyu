import SwiftUI
import Combine

struct OnboardingView: View {
    @Binding var isCompleted: Bool
    
    // State
    @State private var sceneIndex = 0
    @State private var displayedText = ""
    @State private var showSource = false
    @State private var showAction = false
    @State private var noiseTime: Double = 0.0
    @State private var sphereScale: CGFloat = 0.0
    
    // Timer
    @State private var timer: Timer?
    @State private var noiseTimer: Timer?
    
    // Content
    let scene1Text = L10n.onboardingScene1
    let scene2Text = L10n.onboardingScene2
    let scene3Text = L10n.onboardingScene3
    
    var body: some View {
        ZStack {
            // Backgrounds
            if sceneIndex == 0 {
                // Scene 1: Green Matrix Noise
                Color.black.ignoresSafeArea()
                NoiseView(color: .green, time: noiseTime, intensity: 0.3)
                    .opacity(0.4)
            } else if sceneIndex == 1 {
                // Scene 2: Orange Warning Noise
                Color.black.ignoresSafeArea()
                NoiseView(color: .orange, time: noiseTime, intensity: 0.6)
                    .opacity(0.6)
            } else if sceneIndex == 2 {
                // Scene 3: Permission (Dark Blue/Grey)
                Color.black.ignoresSafeArea()
                NoiseView(color: .blue, time: noiseTime, intensity: 0.2)
                    .opacity(0.3)
            } else {
                // Scene 4: Aurora Ascent
                LinearGradient(
                    colors: [Color(red: 0.1, green: 0.0, blue: 0.3), Color.black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .transition(.opacity)
            }
            
            // Content
            VStack {
                Spacer()
                
                // Fluid Sphere (Scene 4 only)
                if sceneIndex == 3 {
                    VisualFluidSphere()
                        .scaleEffect(sphereScale)
                        .onAppear {
                            withAnimation(.spring(response: 1.5, dampingFraction: 0.7)) {
                                sphereScale = 1.0
                            }
                        }
                }
                
                Spacer()
                
                // Typewriter Text
                Text(displayedText)
                    .font(sceneIndex == 0 ? .system(.body, design: .monospaced) : Theme.fontBody())
                    .fontWeight(sceneIndex == 1 ? .bold : .regular)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .padding(.horizontal, 30)
                    .fixedSize(horizontal: false, vertical: true)
                    .id("text_\(sceneIndex)") // Force redraw on scene change
                
                // Source Citation (Scene 1)
                if sceneIndex == 0 && showSource {
                    Text(L10n.onboardingSource)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.green)
                        .padding(.top, 20)
                        .transition(.opacity)
                }
                
                Spacer()
                
                // Actions
                if showAction {
                    if sceneIndex < 3 {
                        Button(action: {
                            if sceneIndex == 2 {
                                // Request Screen Time permission
                                requestScreenTimeAuthorization()
                            } else {
                                nextScene()
                            }
                        }) {
                            if sceneIndex == 2 {
                                // Permission Button
                                Text(L10n.grantAccess)
                                    .font(Theme.fontBody())
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.white)
                                    .cornerRadius(20)
                            } else {
                                Image(systemName: sceneIndex == 1 ? "questionmark" : "arrow.right")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Circle().fill(.white.opacity(0.1)))
                            }
                        }
                        .transition(.scale)
                    } else {
                        Button(action: finishOnboarding) {
                            Text(L10n.letsBegin)
                                .font(Theme.fontBody())
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.2))
                                        .overlay(Capsule().stroke(Color.white.opacity(0.5), lineWidth: 1))
                                )
                        }
                        .transition(.opacity)
                    }
                }
                
                Spacer().frame(height: 50)
            }
        }
        .onAppear {
            startScene(index: 0)
            startNoise()
        }
        .onDisappear {
            stopAllSounds()
        }
    }
    
    // MARK: - Logic
    
    private func startScene(index: Int) {
        sceneIndex = index
        displayedText = ""
        showAction = false
        showSource = false
        
        let fullText: String
        switch index {
        case 0:
            fullText = scene1Text
            // No background sound
        case 1:
            fullText = scene2Text
            // No background sound
        case 2:
            // CRDS Permission Step
            fullText = L10n.onboardingScene3Permission
            // No background sound
        case 3:
            fullText = scene3Text
            // No background sound
        default: return
        }
        
        // Typewriter Effect
        var charIndex = 0
        let chars = Array(fullText)
        timer?.invalidate()
        
        // Only typewriter clicks, no background sounds
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { t in
            if charIndex < chars.count {
                displayedText.append(chars[charIndex])
                // Play click sound for every 2nd character to reduce audio load
                if charIndex % 2 == 0 {
                    SoundManager.shared.playTypewriterClick()
                }
                charIndex += 1
            } else {
                t.invalidate()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        showAction = true
                        if index == 0 { showSource = true }
                    }
                }
            }
        }
    }
    
    private func nextScene() {
        withAnimation(.easeInOut(duration: 1.0)) {
            startScene(index: sceneIndex + 1)
        }
    }
    
    private func requestScreenTimeAuthorization() {
        Task {
            do {
                try await ScreenTimeMonitor.shared.requestAuthorization()
                // Authorization successful, proceed to next scene
                await MainActor.run {
                    nextScene()
                }
            } catch {
                // Authorization failed or cancelled
                // Still proceed to next scene (user can enable later in settings)
                await MainActor.run {
                    nextScene()
                }
            }
        }
    }
    
    private func finishOnboarding() {
        // Reset Serenity Guide for new users so they see it on Home
        UserDefaults.standard.set(false, forKey: "hasSeenSerenityGuide")
        
        withAnimation(.easeInOut(duration: 0.5)) {
            isCompleted = true
        }
        stopAllSounds()
    }
    
    private func startNoise() {
        noiseTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            noiseTime += 0.05
        }
    }
    
    private func stopAllSounds() {
        // No background sounds to stop
        timer?.invalidate()
        noiseTimer?.invalidate()
    }
    
    // MARK: - Components
    
    struct NoiseView: View {
        var color: Color
        var time: Double
        var intensity: Double
        
        var body: some View {
            Canvas { context, size in
                let w = size.width
                let h = size.height
                
                for _ in 0..<Int(100 * intensity) {
                    let x = Double.random(in: 0...w)
                    let y = Double.random(in: 0...h)
                    let rect = CGRect(x: x, y: y, width: 2, height: 2)
                    context.fill(Path(rect), with: .color(color.opacity(Double.random(in: 0.2...0.8))))
                }
            }
        }
    }
    
    struct VisualFluidSphere: View {
        @State private var time: Double = 0.0
        
        var body: some View {
            ZStack {
                // Simplified visual sphere
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white.opacity(0.1), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 10)
                
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    .frame(width: 180, height: 180)
                    .overlay(
                        Circle()
                            .stroke(Color.cyan.opacity(0.5), lineWidth: 2)
                            .offset(x: sin(time)*2, y: cos(time)*2)
                            .blur(radius: 2)
                    )
            }
            .onAppear {
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                    time += .pi * 2
                }
            }
        }
    }
}
