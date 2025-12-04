import SwiftUI
import Combine

struct VoiceLogSessionView: View { // Keeping name to avoid breaking RehabView references
    @StateObject private var audioRecorder = AudioRecorder()
    @Environment(\.presentationMode) var presentationMode
    
    // State
    @State private var sessionState: SessionState = .idle
    @State private var coreName: String = ""
    @State private var showNameInput = false
    @State private var photolysisProgress: Double = 0.0
    
    // Visuals
    @State private var coreScale: CGFloat = 0.5
    @State private var coreRoughness: Double = 0.0
    @State private var time: Double = 0.0
    @State private var beamOpacity: Double = 0.0
    @State private var particles: [DissolveParticle] = []
    
    // Timer
    @State private var timer: Timer?
    
    // Completion Animation State
    @State private var showCompletionText = false
    @State private var completionTextScale: CGFloat = 0.8
    @State private var completionTextOpacity: Double = 0.0
    @State private var showEmbers = false
    @State private var emberParticles: [EmberParticle] = []
    
    enum SessionState {
        case idle
        case recording
        case naming
        case observing
        case photolysis
        case completed
    }
    
    struct EmberParticle {
        var position: CGPoint
        var velocity: CGPoint
        var opacity: Double
        var size: CGFloat
    }
    
    var body: some View {
        ZStack {
            // 1. Background
            if sessionState == .completed {
                // Void Background
                RadialGradient(
                    gradient: Gradient(colors: [Color(red: 0.05, green: 0.0, blue: 0.1), .black]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 500
                )
                .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
            }
            
            // 2. Fluid Beam (Photolysis)
            if sessionState == .photolysis {
                PhotolysisBeam()
                    .opacity(beamOpacity)
            }
            
            // 3. Visuals (Breathing Dot OR Shadow Core)
            if sessionState == .idle || sessionState == .recording {
                // Breathing Dot (Recording)
                Circle()
                    .fill(Color.white)
                    .frame(width: 40, height: 40)
                    .scaleEffect(1.0 + CGFloat(audioRecorder.amplitude) * 0.5) // Pulse with voice
                    .opacity(0.8 + Double(audioRecorder.amplitude) * 0.2)
                    .shadow(color: .white, radius: 10 + CGFloat(audioRecorder.amplitude) * 10)
                    .animation(.linear(duration: 0.1), value: audioRecorder.amplitude)
                
            } else if sessionState != .idle && sessionState != .completed {
                // Shadow Core (After Recording)
                Canvas { context, size in
                    let center = CGPoint(x: size.width/2, y: size.height/2)
                    
                    // Draw Dissolving Particles
                    for p in particles {
                        let rect = CGRect(x: p.position.x, y: p.position.y, width: p.size, height: p.size)
                        context.fill(Path(ellipseIn: rect), with: .color(Color.gray.opacity(p.opacity)))
                    }
                    
                    // Draw Core (if not fully dissolved)
                    if photolysisProgress < 1.0 {
                        let radius = 100.0 * coreScale * (1.0 - photolysisProgress)
                        if radius > 0 {
                            var path = Path()
                            let points = 30
                            let angleStep = (Double.pi * 2) / Double(points)
                            
                            for i in 0..<points {
                                let angle = Double(i) * angleStep + time
                                // Noise/Roughness
                                let noise = Double.random(in: 0.8...1.2) * (1.0 + coreRoughness * 0.5)
                                let r = radius * noise
                                let x = center.x + cos(angle) * r
                                let y = center.y + sin(angle) * r
                                
                                if i == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                            path.closeSubpath()
                            
                            // Fill: Dark, Rough
                            context.fill(path, with: .color(Color(red: 0.1, green: 0.05, blue: 0.05).opacity(0.9)))
                            // Stroke: Irregular
                            context.stroke(path, with: .color(Color.gray.opacity(0.3)), lineWidth: 2)
                        }
                    }
                }
                .frame(height: 400)
            }
            
            // 4. Completion Visuals (Embers)
            if showEmbers {
                Canvas { context, size in
                    for p in emberParticles {
                        let rect = CGRect(x: p.position.x, y: p.position.y, width: p.size, height: p.size)
                        context.fill(Path(ellipseIn: rect), with: .color(Color.cyan.opacity(p.opacity)))
                    }
                }
                .ignoresSafeArea()
            }
            
            // 5. UI Layer
            VStack {
                // Top Guidance
                Group {
                    switch sessionState {
                    case .idle:
                        Text(L10n.tapToRecord)
                    case .recording:
                        Text(timeString(from: audioRecorder.recordingDuration))
                            .font(.system(.title, design: .monospaced))
                    case .naming:
                        Text(L10n.nameThisCore)
                    case .observing:
                        VStack(spacing: 12) {
                            ForEach(L10n.observeCore.components(separatedBy: "\n"), id: \.self) { line in
                                Text(line)
                            }
                        }
                        .multilineTextAlignment(.center)
                    case .photolysis:
                        Text(L10n.photolyzing)
                    case .completed:
                        if showCompletionText {
                            Text(L10n.returnToCalm)
                                .font(.system(size: 24, weight: .thin, design: .serif))
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(color: .white.opacity(0.5), radius: 10)
                                .scaleEffect(completionTextScale)
                                .opacity(completionTextOpacity)
                        }
                    }
                }
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .padding(.top, 60)
                .opacity(sessionState == .completed && !showCompletionText ? 0.0 : 0.8) // Hide default text in completed
                
                Spacer()
                
                // Naming Input
                if showNameInput {
                    VStack {
                        TextField(L10n.corePlaceholder, text: $coreName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .background(Color.black)
                        
                        Button(L10n.confirm) {
                            withAnimation {
                                showNameInput = false
                                sessionState = .observing
                            }
                        }
                        .padding()
                        .foregroundColor(coreName.isEmpty ? .gray : .white)
                        .background(Capsule().stroke(coreName.isEmpty ? Color.gray : Color.white))
                        .disabled(coreName.isEmpty)
                    }
                    .padding()
                    .transition(.move(edge: .bottom))
                }
                
                // Controls
                if !showNameInput {
                    switch sessionState {
                    case .idle:
                        Button(action: startRecording) {
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 80, height: 80)
                                .overlay(Circle().fill(Color.white).frame(width: 60, height: 60))
                        }
                    case .recording:
                        Button(action: stopRecording) {
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 80, height: 80)
                                .overlay(RoundedRectangle(cornerRadius: 4).fill(Color.white).frame(width: 40, height: 40))
                        }
                    case .observing:
                        Button(action: startPhotolysis) {
                            Text(L10n.startPhotolysis)
                                .font(Theme.fontBody())
                                .foregroundColor(.black)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(Capsule().fill(Color.white))
                        }
                    case .completed:
                        EmptyView() // No buttons, auto exit
                    default:
                        EmptyView()
                    }
                }
                
                Spacer().frame(height: 50)
            }
        }
        .onAppear {
            startLoop()
            audioRecorder.checkPermission()
        }
        .onDisappear {
            stopLoop()
            SoundManager.shared.stopShadowFriction()
        }
        .onChange(of: audioRecorder.amplitude) { amp in
            if sessionState == .recording {
                // Amplitude drives core size and roughness
                withAnimation(.linear(duration: 0.1)) {
                    coreScale = 0.5 + CGFloat(amp) * 0.5
                    coreRoughness = Double(amp)
                }
            }
        }
    }
    
    // MARK: - Logic
    
    private func startRecording() {
        sessionState = .recording
        audioRecorder.startRecording()
        // 移除录音时的背景音效，保持安静
    }
    
    private func stopRecording() {
        audioRecorder.stopRecording()
        // 不需要停止音效，因为没有播放
        
        withAnimation {
            sessionState = .naming
            showNameInput = true
            coreScale = 0.8 // Fixed size for observation
            coreRoughness = 0.2 // Settled
        }
    }
    
    private func startPhotolysis() {
        withAnimation {
            sessionState = .photolysis
            beamOpacity = 1.0
        }
        
        // 移除光解音效，保持安静
        
        // Animation Sequence
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { t in
            photolysisProgress += 0.01
            
            // Spawn particles
            if photolysisProgress < 1.0 {
                for _ in 0..<5 {
                    particles.append(DissolveParticle(
                        position: CGPoint(x: UIScreen.main.bounds.width/2 + CGFloat.random(in: -50...50),
                                          y: UIScreen.main.bounds.height/2 + CGFloat.random(in: -50...50)),
                        velocity: CGPoint(x: CGFloat.random(in: -2...2), y: CGFloat.random(in: -5...(-1))),
                        size: CGFloat.random(in: 2...5),
                        opacity: 1.0
                    ))
                }
            }
            
            if photolysisProgress >= 1.0 && particles.isEmpty {
                t.invalidate()
                completeSession()
            }
        }
    }
    
    private func completeSession() {
        withAnimation(.easeInOut(duration: 1.0)) {
            sessionState = .completed
            beamOpacity = 0.0
        }
        // 移除完成音效，保持安静
        StatusManager.shared.recordEmotionalLog(name: coreName, duration: audioRecorder.recordingDuration)
        
        // 1. Wait 1s, then show text
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeIn(duration: 1.0)) {
                showCompletionText = true
                completionTextOpacity = 1.0
            }
            
            // Scale up and fade out over 1.5s
            withAnimation(.linear(duration: 2.5)) {
                completionTextScale = 1.2
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 1.0)) {
                    completionTextOpacity = 0.0
                }
                
                // 2. Flash Embers (Broken Traces)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showEmbers = true
                    // Create embers
                    for _ in 0..<20 {
                        emberParticles.append(EmberParticle(
                            position: CGPoint(x: UIScreen.main.bounds.width/2 + CGFloat.random(in: -20...20),
                                              y: UIScreen.main.bounds.height/2 + CGFloat.random(in: -20...20)),
                            velocity: CGPoint(x: CGFloat.random(in: -1...1), y: CGFloat.random(in: -1...1)),
                            opacity: 1.0,
                            size: CGFloat.random(in: 1...3)
                        ))
                    }
                    
                    // Fade out embers quickly
                    withAnimation(.easeOut(duration: 0.5)) {
                        // Logic handled in loop, but we can trigger exit
                    }
                    
                    // 3. Exit
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func startLoop() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            time += 0.05
            
            // Update Dissolve Particles
            var aliveParticles: [DissolveParticle] = []
            for var p in particles {
                p.position.x += p.velocity.x
                p.position.y += p.velocity.y
                p.opacity -= 0.02
                if p.opacity > 0 {
                    aliveParticles.append(p)
                }
            }
            particles = aliveParticles
            
            // Update Ember Particles
            if showEmbers {
                var aliveEmbers: [EmberParticle] = []
                for var p in emberParticles {
                    p.position.x += p.velocity.x
                    p.position.y += p.velocity.y
                    p.opacity -= 0.05 // Fast fade
                    if p.opacity > 0 {
                        aliveEmbers.append(p)
                    }
                }
                emberParticles = aliveEmbers
                if emberParticles.isEmpty {
                    showEmbers = false
                }
            }
        }
    }
    
    private func stopLoop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    struct DissolveParticle {
        var position: CGPoint
        var velocity: CGPoint
        var size: CGFloat
        var opacity: Double
    }
    
    struct PhotolysisBeam: View {
        var body: some View {
            LinearGradient(
                colors: [.cyan.opacity(0.8), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: 100)
            .mask(Rectangle())
            .blur(radius: 20)
        }
    }
}
