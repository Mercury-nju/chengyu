import SwiftUI
import Combine

struct MindfulRevealSessionView: View {
    @Binding var unlockNext: Bool
    @Environment(\.presentationMode) var presentationMode
    
    // Core State
    @State private var isRunning = false
    @State private var isCompleted = false
    @State private var showCompletionUI = false
    
    // Physics State
    @State private var particles: [Particle] = []
    @State private var fusedCount: Int = 0
    @State private var totalParticles: Int = 60 // Reduced for performance
    @State private var stability: Double = 1.0 // 1.0 = Stable
    @State private var touchLocation: CGPoint = .zero
    @State private var lastTouchLocation: CGPoint = .zero
    @State private var isTouching = false
    @State private var time: Double = 0.0
    @State private var coreScale: CGFloat = 1.0 // Start visible - dot appears immediately
    @State private var lastCaptureSoundTime: Double = 0.0 // Throttle sound
    
    // Timer
    @State private var loopTimer: Timer?
    @State private var hapticTimer: Timer?
    
    // Constants
    let haloRadius: CGFloat = 100.0
    let orbitRadius: CGFloat = 60.0
    
    // View Dimensions
    @State private var viewSize: CGSize = .zero
    let padding: CGFloat = 20.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 1. Background: Pure Black
                Color.black.ignoresSafeArea()
                
                // 2. Particle System & Core (Canvas)
                Canvas { context, size in
                    // Draw Particles
                    for particle in particles {
                        var pColor: Color
                        var pSize: CGFloat = 4.0
                        
                        switch particle.state {
                        case .chaos:
                            pColor = particle.color
                        case .orbiting:
                            pColor = .cyan
                            pSize = 3.0
                        case .fusing:
                            pColor = .white
                            pSize = 2.0
                        }
                        
                        let rect = CGRect(x: particle.position.x - pSize/2, y: particle.position.y - pSize/2, width: pSize, height: pSize)
                        context.fill(Path(ellipseIn: rect), with: .color(pColor.opacity(0.8)))
                    }
                    
                    // Draw Core (Under Finger)
                    if (isTouching || isCompleted) && coreScale > 0 {
                        let center = isCompleted ? CGPoint(x: size.width/2, y: size.height/2) : touchLocation
                        
                        // Core Size grows with fused particles (made larger for visibility)
                        let progress = Double(fusedCount) / Double(totalParticles)
                        let coreRadius = (isCompleted ? 80.0 : (30.0 + progress * 40.0)) * coreScale
                        
                        // Core Style
                        if isCompleted {
                            // Perfect Crystal (3D Frozen Fluid Light)
                            let rect = CGRect(x: center.x - coreRadius, y: center.y - coreRadius, width: coreRadius*2, height: coreRadius*2)
                            
                            // 0. Background Atmosphere (Deep Purple/Blue Glow)
                            let bgRect = CGRect(x: center.x - 300, y: center.y - 300, width: 600, height: 600)
                            context.fill(Path(ellipseIn: bgRect), with: .radialGradient(Gradient(colors: [Color(red: 0.1, green: 0.0, blue: 0.3).opacity(0.4), .clear]), center: center, startRadius: 0, endRadius: 300))
                            
                            // 1. Main Body (Deep Cyan Glass)
                            context.fill(Path(ellipseIn: rect), with: .radialGradient(Gradient(colors: [Color.cyan.opacity(0.2), Color(red: 0.0, green: 0.2, blue: 0.4).opacity(0.9)]), center: center, startRadius: 10, endRadius: coreRadius))
                            
                            // 2. Inner Core (Energy Source)
                            let coreGlowRect = rect.insetBy(dx: coreRadius * 0.6, dy: coreRadius * 0.6)
                            context.fill(Path(ellipseIn: coreGlowRect), with: .radialGradient(Gradient(colors: [.white, .cyan.opacity(0.0)]), center: center, startRadius: 0, endRadius: coreRadius * 0.4))
                            
                            // 3. Rim Light (Edge Definition)
                            context.stroke(Path(ellipseIn: rect), with: .linearGradient(Gradient(colors: [.white.opacity(0.9), .white.opacity(0.1)]), startPoint: CGPoint(x: rect.minX, y: rect.minY), endPoint: CGPoint(x: rect.maxX, y: rect.maxY)), lineWidth: 1.5)
                            
                            // 4. Specular Highlight (Glossy Reflection)
                            let highlightRect = CGRect(x: center.x - coreRadius * 0.5, y: center.y - coreRadius * 0.6, width: coreRadius * 0.4, height: coreRadius * 0.25)
                            context.fill(Path(ellipseIn: highlightRect), with: .linearGradient(Gradient(colors: [.white.opacity(0.5), .white.opacity(0.0)]), startPoint: CGPoint(x: highlightRect.midX, y: highlightRect.minY), endPoint: CGPoint(x: highlightRect.midX, y: highlightRect.maxY)))
                            
                            // 5. Outer Breathing Glow
                            context.stroke(Path(ellipseIn: rect.insetBy(dx: -10, dy: -10)), with: .color(Color.cyan.opacity(0.15)), lineWidth: 20)
                            
                        } else {
                            // Molten Core
                            let rect = CGRect(x: center.x - coreRadius, y: center.y - coreRadius, width: coreRadius*2, height: coreRadius*2)
                            
                            // Halo
                            context.fill(Path(ellipseIn: rect.insetBy(dx: -20, dy: -20)), with: .color(.blue.opacity(0.2 * stability)))
                            
                            // Core Body
                            let coreColor = Color(red: 0.2, green: 0.8 + stability * 0.2, blue: 1.0)
                            context.fill(Path(ellipseIn: rect), with: .color(coreColor.opacity(0.8)))
                        }
                    }
                }
                .ignoresSafeArea()
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            handleTouch(location: value.location)
                        }
                        .onEnded { _ in
                            handleTouchEnd()
                        }
                )
                
                // 3. UI Overlay
                VStack {
                    if !isRunning && !isCompleted {
                        Text(L10n.mindfulRevealInstruction)
                            .font(Theme.fontBody())
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.top, 100)
                    }
                    Spacer()
                }
                
                // 4. Completion UI
                if showCompletionUI {
                    ZStack {
                        // Title
                        VStack {
                            Spacer()
                            Text(L10n.crystalComplete)
                                .font(.system(size: 20, weight: .medium, design: .serif))
                                .foregroundColor(Color(red: 0.9, green: 0.9, blue: 1.0))
                                .shadow(color: .white.opacity(0.5), radius: 8)
                                .padding(.bottom, 120)
                        }
                        
                        // Hint Text (Delayed)
                        if showTouchHint {
                            Text(L10n.tapCrystal)
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(.white.opacity(0.8))
                                .shadow(color: .white.opacity(0.3), radius: 5)
                                .offset(y: 120) // Below crystal
                                .transition(.opacity)
                        }
                        
                        // Tap Area (Covering Crystal)
                        Color.black.opacity(0.001) // Invisible tappable area
                            .frame(width: 200, height: 200)
                            .contentShape(Circle())
                            .onTapGesture {
                                handleCrystalTap()
                            }
                    }
                    .transition(.opacity)
                }
                
                // 5. Exit Explosion Overlay
                if isExiting {
                    ZStack {
                        // White/Cyan Light Curtain
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [.white, .cyan.opacity(0.5), .clear]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 100
                                )
                            )
                            .scaleEffect(explosionScale)
                            .opacity(explosionOpacity)
                            .blendMode(.screen)
                    }
                    .ignoresSafeArea()
                }
            }
            .onAppear {
                viewSize = geometry.size
                initParticles(size: geometry.size)
                startLoop()
                // Background noise removed for peaceful experience
            }
            .onDisappear {
                stopLoop()
                // Audio cleanup removed
            }
        }
    }
    
    // MARK: - Logic
    
    struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var velocity: CGPoint
        var color: Color
        var state: ParticleState
        var orbitAngle: Double = 0.0
        var orbitTime: Double = 0.0
        
        enum ParticleState {
            case chaos
            case orbiting
            case fusing
        }
    }
    
    private func initParticles(size: CGSize) {
        particles = []
        let colors: [Color] = [.red, .orange, .yellow]
        
        // Ensure valid ranges to prevent crash
        let safeWidth = max(size.width, padding * 2 + 1)
        let safeHeight = max(size.height, padding * 2 + 1)
        
        for _ in 0..<totalParticles {
            let x = CGFloat.random(in: padding...(safeWidth - padding))
            let y = CGFloat.random(in: padding...(safeHeight - padding))
            let vx = CGFloat.random(in: -2...2)
            let vy = CGFloat.random(in: -2...2)
            let color = colors.randomElement()!
            
            particles.append(Particle(
                position: CGPoint(x: x, y: y),
                velocity: CGPoint(x: vx, y: vy),
                color: color,
                state: .chaos
            ))
        }
    }
    
    
    private func handleTouch(location: CGPoint) {
        if !isTouching {
            isTouching = true
            isRunning = true
            // Background sounds removed
            // Reset core scale to make orb visible again
            withAnimation(.easeOut(duration: 0.2)) {
                coreScale = 1.0
            }
        }
        
        // Stability Check
        let distance = hypot(location.x - lastTouchLocation.x, location.y - lastTouchLocation.y)
        if distance > 8.0 { // Threshold for "slow movement"
            stability = max(0.0, stability - 0.1)
            if stability < 0.5 {
                // Throttled crack sound could go here
                HapticManager.shared.playInstabilityKick()
            }
        } else {
            stability = min(1.0, stability + 0.05)
        }
        
        touchLocation = location
        lastTouchLocation = location
    }
    
    private func handleTouchEnd() {
        // If completed, do not reset/scatter
        guard !isCompleted else { return }
        
        isTouching = false
        stability = 0.0
        // Sound effects removed for peaceful experience
        
        withAnimation(.easeOut(duration: 0.3)) {
            coreScale = 0.0
        }
        
        // Scatter all orbiting/fusing particles
        for i in 0..<particles.count {
            if particles[i].state == .orbiting || particles[i].state == .fusing {
                particles[i].state = .chaos
                
                // Calculate scatter velocity (away from center)
                let dx = particles[i].position.x - touchLocation.x
                let dy = particles[i].position.y - touchLocation.y
                let dist = max(1.0, hypot(dx, dy)) // Avoid divide by zero
                
                // Strong scatter force
                particles[i].velocity = CGPoint(
                    x: (dx / dist) * CGFloat.random(in: 5...10),
                    y: (dy / dist) * CGFloat.random(in: 5...10)
                )
            }
        }
    }
    
    private func startLoop() {
        loopTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            updatePhysics()
        }
        
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if isTouching && stability > 0.5 {
                // Rumble intensity based on orbiting count
                let orbitingCount = particles.filter { $0.state == .orbiting }.count
                let intensity = min(1.0, Float(orbitingCount) / 10.0) * Float(stability)
                if intensity > 0.1 {
                    HapticManager.shared.playFusionRumble(intensity: intensity)
                }
            }
        }
    }
    
    private func stopLoop() {
        loopTimer?.invalidate()
        hapticTimer?.invalidate()
        loopTimer = nil
        hapticTimer = nil
    }
    
    private func updatePhysics() {
        time += 0.02
        guard !isCompleted else { return }
        
        var remainingParticles: [Particle] = []
        let currentTime = Date().timeIntervalSince1970
        
        for var p in particles {
            
            if isTouching && stability > 0.3 {
                let dx = touchLocation.x - p.position.x
                let dy = touchLocation.y - p.position.y
                let dist = hypot(dx, dy)
                
                switch p.state {
                case .chaos:
                    // Attraction
                    if dist < haloRadius {
                        p.state = .orbiting
                        p.orbitAngle = atan2(dy, dx)
                        p.orbitTime = 0
                        
                        // Throttle Capture Sound (Max 10 per second)
                        if currentTime - lastCaptureSoundTime > 0.1 {
                            SoundManager.shared.playOrbitCapture()
                            lastCaptureSoundTime = currentTime
                        }
                    } else {
                        // Random walk
                        p.position.x += p.velocity.x
                        p.position.y += p.velocity.y
                        // Bounce
                        if p.position.x < 0 || p.position.x > UIScreen.main.bounds.width { p.velocity.x *= -1 }
                        if p.position.y < 0 || p.position.y > UIScreen.main.bounds.height { p.velocity.y *= -1 }
                    }
                    
                case .orbiting:
                    // Orbit Logic
                    p.orbitTime += 0.02
                    p.orbitAngle += 2.0 * 0.02 // Rotation speed
                    
                    // Target position on orbit ring
                    let targetX = touchLocation.x + cos(p.orbitAngle) * orbitRadius
                    let targetY = touchLocation.y + sin(p.orbitAngle) * orbitRadius
                    
                    // Smoothly move to orbit position
                    p.position.x += (targetX - p.position.x) * 0.1
                    p.position.y += (targetY - p.position.y) * 0.1
                    
                    // Fusion Check
                    if p.orbitTime > 2.5 { // 2.5s fusion duration
                        p.state = .fusing
                        // SoundManager.shared.playParticleFuse() // Reduce noise, maybe only on visual fuse
                    }
                    
                case .fusing:
                    // Move to center and disappear
                    p.position.x += (touchLocation.x - p.position.x) * 0.2
                    p.position.y += (touchLocation.y - p.position.y) * 0.2
                    
                    if hypot(touchLocation.x - p.position.x, touchLocation.y - p.position.y) < 5.0 {
                        // Fused!
                        fusedCount += 1
                        SoundManager.shared.playParticleFuse()
                        continue // Remove from array
                    }
                }
            } else {
                // Not touching or unstable -> Chaos
                p.state = .chaos
                p.position.x += p.velocity.x
                p.position.y += p.velocity.y
                
                // Friction/Drag to slow down scattered particles
                p.velocity.x *= 0.95
                p.velocity.y *= 0.95
                
                // Keep moving slightly
                if abs(p.velocity.x) < 0.5 { p.velocity.x = CGFloat.random(in: -1...1) }
                if abs(p.velocity.y) < 0.5 { p.velocity.y = CGFloat.random(in: -1...1) }
                
                // Bounce with padding
                if p.position.x < padding || p.position.x > viewSize.width - padding { p.velocity.x *= -1 }
                if p.position.y < padding || p.position.y > viewSize.height - padding { p.velocity.y *= -1 }
                
                // Clamp position to be safe
                p.position.x = max(padding, min(viewSize.width - padding, p.position.x))
                p.position.y = max(padding, min(viewSize.height - padding, p.position.y))
            }
            
            remainingParticles.append(p)
        }
        
        particles = remainingParticles
        
        // Completion
        if particles.isEmpty && fusedCount >= totalParticles {
            completeSession()
        }
    }
    
    @State private var showTouchHint = false
    @State private var isExiting = false
    @State private var explosionScale: CGFloat = 0.0
    @State private var explosionOpacity: Double = 0.0
    
    private func handleCrystalTap() {
        guard showCompletionUI && !isExiting else { return }
        
        isExiting = true
        HapticManager.shared.playFusionRumble(intensity: 1.0) // Strong feedback
        
        withAnimation(.easeIn(duration: 0.6)) {
            explosionScale = 20.0
            explosionOpacity = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func completeSession() {
        guard !isCompleted else { return }
        isCompleted = true
        stopLoop()
        
        // Completion sounds removed for peaceful experience
        HapticManager.shared.notification(type: .success)
        
        // Record flow completion
        StatusManager.shared.recordFlowCompletion()
        unlockNext = true
        
        withAnimation(.easeOut(duration: 1.0)) {
            showCompletionUI = true
            coreScale = 1.0 // Ensure crystal is visible
        }
        
        // Delayed Hint
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation {
                showTouchHint = true
            }
        }
    }
}
