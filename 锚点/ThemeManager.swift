import SwiftUI
import Combine

enum AppTheme: String, CaseIterable, Identifiable {
    case universe = "universe"
    case deepSea = "deepSea"
    case starrySky = "starrySky"
    case forest = "forest"
    case nebula = "nebula"
    case aurora = "aurora"
    case sunset = "sunset"
    case midnight = "midnight"
    case oceanDepths = "oceanDepths"
    case cherryBlossom = "cherryBlossom"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .universe: return L10n.isUSVersion ? "Universe" : "宇宙"
        case .deepSea: return L10n.isUSVersion ? "Deep Sea" : "深海"
        case .starrySky: return L10n.isUSVersion ? "Starry Sky" : "星空"
        case .forest: return L10n.isUSVersion ? "Forest" : "森林"
        case .nebula: return L10n.isUSVersion ? "Nebula" : "星云"
        case .aurora: return L10n.isUSVersion ? "Aurora" : "极光"
        case .sunset: return L10n.isUSVersion ? "Sunset" : "日落"
        case .midnight: return L10n.isUSVersion ? "Midnight" : "子夜"
        case .oceanDepths: return L10n.isUSVersion ? "Abyss" : "深渊"
        case .cherryBlossom: return L10n.isUSVersion ? "Cherry Blossom" : "落樱"
        }
    }
    
    var isPremium: Bool {
        switch self {
        case .universe: return false
        default: return true
        }
    }
    
    var backgroundView: AnyView {
        switch self {
        case .universe:
            return AnyView(
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(hex: "000000"),
                            Color(hex: "050510"),
                            Color(hex: "0A0A15")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    ThemeParticleView(type: .stars)
                }.ignoresSafeArea()
            )
        case .deepSea:
            return AnyView(
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(hex: "000510"),
                            Color(hex: "001530"),
                            Color(hex: "002040")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    ThemeParticleView(type: .bubbles)
                }.ignoresSafeArea()
            )
        case .starrySky:
            return AnyView(
                LinearGradient(
                    colors: [
                        Color(hex: "020205"),
                        Color(hex: "050515"),
                        Color(hex: "100520")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()
            )
        case .forest:
            return AnyView(
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(hex: "020502"),
                            Color(hex: "051505"),
                            Color(hex: "102010")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    ThemeParticleView(type: .fireflies)
                }.ignoresSafeArea()
            )
        case .nebula:
            return AnyView(
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(hex: "100010"),
                            Color(hex: "200020"),
                            Color(hex: "100030")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    ThemeParticleView(type: .nebulaClouds)
                }.ignoresSafeArea()
            )
        case .aurora:
            return AnyView(
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(hex: "001010"),
                            Color(hex: "002020"),
                            Color(hex: "001020")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    ThemeParticleView(type: .auroraWaves)
                }.ignoresSafeArea()
            )
        case .sunset:
            return AnyView(
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(hex: "200500"),
                            Color(hex: "301005"),
                            Color(hex: "100510")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    ThemeParticleView(type: .sunsetGlow)
                }.ignoresSafeArea()
            )
        case .midnight:
            return AnyView(
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(hex: "000010"),
                            Color(hex: "000520"),
                            Color(hex: "001040")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    ThemeParticleView(type: .moonlight)
                }.ignoresSafeArea()
            )
        case .oceanDepths:
            return AnyView(
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(hex: "000510"),
                            Color(hex: "001020"),
                            Color(hex: "002030")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    ThemeParticleView(type: .bioluminescence)
                }.ignoresSafeArea()
            )
        case .cherryBlossom:
            return AnyView(
                LinearGradient(
                    colors: [
                        Color(hex: "1A0510"),
                        Color(hex: "200818"),
                        Color(hex: "280A20")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()
            )
        }
    }
}

struct ThemeParticleView: View {
    enum ParticleType {
        case stars
        case bubbles
        case fireflies
        case nebulaClouds
        case auroraWaves
        case sunsetGlow
        case shootingStars
        case moonlight
        case bioluminescence
        case fallingPetals
        case energyBolts
    }
    
    let type: ParticleType
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                
                switch type {
                case .stars:
                    // Refined stars - more subtle and varied
                    for i in 0..<80 {
                        let x = (Double(i * 137) * 13.0).truncatingRemainder(dividingBy: size.width)
                        let y = (Double(i * 293) * 17.0).truncatingRemainder(dividingBy: size.height)
                        
                        // Slower, more subtle twinkling
                        let twinkleSpeed = 0.3 + Double(i % 3) * 0.1
                        let opacity = 0.2 + 0.4 * abs(sin(time * twinkleSpeed + Double(i)))
                        
                        // Varied sizes with more small stars
                        let sizeVariant = i % 10
                        let radius: Double
                        if sizeVariant < 6 {
                            radius = 0.5 + Double.random(in: 0...0.3) // Tiny stars
                        } else if sizeVariant < 9 {
                            radius = 0.8 + Double.random(in: 0...0.4) // Small stars
                        } else {
                            radius = 1.2 + Double.random(in: 0...0.5) // Medium stars
                        }
                        
                        context.opacity = opacity
                        
                        // Draw star with subtle glow
                        let starRect = CGRect(x: x - radius/2, y: y - radius/2, width: radius, height: radius)
                        context.fill(Path(ellipseIn: starRect), with: .color(.white))
                        
                        // Add soft glow for larger stars
                        if radius > 1.0 {
                            context.opacity = opacity * 0.3
                            let glowRect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                            context.fill(Path(ellipseIn: glowRect), with: .color(.white))
                        }
                    }
                    
                case .bubbles:
                    for i in 0..<30 {
                        let speed = 20.0 + Double(i % 5) * 5.0
                        let yOffset = (time * speed).truncatingRemainder(dividingBy: size.height + 50)
                        let y = size.height + 20 - yOffset
                        let xBase = (Double(i * 97) * 11.0).truncatingRemainder(dividingBy: size.width)
                        let xWobble = sin(time * 2 + Double(i)) * 5.0
                        let x = xBase + xWobble
                        let radius = 2.0 + Double(i % 3)
                        context.opacity = 0.1 + 0.2 * abs(sin(time + Double(i)))
                        context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: radius, height: radius)), with: .color(.white.opacity(0.3)))
                    }
                    
                case .fireflies:
                    for i in 0..<40 {
                        let t = time * 0.5 + Double(i) * 100
                        let x = (sin(t * 0.3) * 0.5 + 0.5) * size.width
                        let y = (cos(t * 0.2) * 0.5 + 0.5) * size.height
                        let radius = 1.5 + sin(t * 3) * 0.5
                        let opacity = 0.4 + 0.4 * sin(t * 2)
                        context.opacity = opacity
                        context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: radius, height: radius)), with: .color(Color(red: 0.8, green: 1.0, blue: 0.5)))
                    }
                    
                case .nebulaClouds:
                    // Flowing nebula dust particles - more mystical and ethereal
                    for i in 0..<60 {
                        let baseSpeed = 0.1 + Double(i % 5) * 0.05
                        let t = time * baseSpeed + Double(i) * 5.0
                        
                        // Flowing motion with variation
                        let flowX = sin(t * 0.2) * 0.4 + cos(t * 0.15) * 0.3
                        let flowY = sin(t * 0.18) * 0.4 + cos(t * 0.12) * 0.35
                        
                        let x = (0.5 + flowX) * size.width
                        let y = (0.5 + flowY) * size.height
                        
                        // Varied particle sizes
                        let baseSize = Double(i % 3) + 1.5
                        let radius = baseSize + sin(t * 2.0) * 0.8
                        
                        // Color variation - mix of purple, pink, and blue
                        let colorVariant = i % 3
                        let particleColor: Color
                        switch colorVariant {
                        case 0: particleColor = Color(red: 0.6, green: 0.3, blue: 0.8) // Purple
                        case 1: particleColor = Color(red: 0.8, green: 0.4, blue: 0.7) // Pink
                        default: particleColor = Color(red: 0.4, green: 0.5, blue: 0.9) // Blue
                        }
                        
                        // Pulsing opacity
                        let opacity = 0.15 + 0.25 * abs(sin(t * 1.5))
                        context.opacity = opacity
                        
                        // Draw particle with soft glow
                        let particleRect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                        context.fill(Path(ellipseIn: particleRect), with: .color(particleColor))
                        
                        // Add subtle glow halo
                        context.opacity = opacity * 0.3
                        let glowRect = CGRect(x: x - radius * 2, y: y - radius * 2, width: radius * 4, height: radius * 4)
                        context.fill(Path(ellipseIn: glowRect), with: .color(particleColor))
                    }
                    
                case .auroraWaves:
                    // Simulated waves
                    for i in 0..<3 {
                        let t = time * 0.2 + Double(i) * 2.0
                        var path = Path()
                        path.move(to: CGPoint(x: 0, y: size.height * 0.5))
                        for x in stride(from: 0, to: size.width, by: 10) {
                            let y = size.height * 0.5 + sin(x * 0.01 + t) * 50.0 + sin(x * 0.02 - t) * 30.0
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                        path.addLine(to: CGPoint(x: size.width, y: size.height))
                        path.addLine(to: CGPoint(x: 0, y: size.height))
                        path.closeSubpath()
                        context.opacity = 0.1
                        context.fill(path, with: .color(Color.green))
                    }
                    
                case .sunsetGlow:
                    // Subtle light rays and warm particles
                    // Light rays from horizon
                    for i in 0..<8 {
                        let angle = (Double(i) / 8.0) * .pi * 2.0
                        let rayLength = size.height * 1.5
                        let pulse = 0.5 + 0.5 * sin(time * 0.3 + Double(i))
                        
                        var path = Path()
                        let centerX = size.width * 0.5
                        let centerY = size.height * 1.2 // Below screen
                        
                        path.move(to: CGPoint(x: centerX, y: centerY))
                        
                        let spreadAngle = 0.15
                        let x1 = centerX + cos(angle - spreadAngle) * rayLength
                        let y1 = centerY - sin(angle - spreadAngle) * rayLength
                        let x2 = centerX + cos(angle + spreadAngle) * rayLength
                        let y2 = centerY - sin(angle + spreadAngle) * rayLength
                        
                        path.addLine(to: CGPoint(x: x1, y: y1))
                        path.addLine(to: CGPoint(x: x2, y: y2))
                        path.closeSubpath()
                        
                        context.opacity = 0.02 * pulse
                        let gradient = Gradient(colors: [
                            Color.orange.opacity(0.8),
                            Color.orange.opacity(0.0)
                        ])
                        context.fill(path, with: .linearGradient(
                            gradient,
                            startPoint: CGPoint(x: centerX, y: centerY),
                            endPoint: CGPoint(x: (x1 + x2) / 2, y: (y1 + y2) / 2)
                        ))
                    }
                    
                    // Warm floating particles (dust in light)
                    for i in 0..<30 {
                        let t = time * 0.2 + Double(i) * 3.0
                        let x = (sin(t * 0.4 + Double(i)) * 0.5 + 0.5) * size.width
                        let yProgress = (time * 0.05 + Double(i) * 0.1).truncatingRemainder(dividingBy: 1.0)
                        let y = size.height - (yProgress * size.height)
                        
                        let radius = 1.0 + Double(i % 3) * 0.5
                        let opacity = 0.1 + 0.15 * abs(sin(t * 2.0))
                        
                        context.opacity = opacity
                        let particleColor = Color(red: 1.0, green: 0.7 + Double(i % 3) * 0.1, blue: 0.3)
                        context.fill(
                            Path(ellipseIn: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)),
                            with: .color(particleColor)
                        )
                    }
                    
                case .shootingStars:
                    // Shooting stars with trails - different from static stars
                    for i in 0..<5 {
                        let speed = 0.8 + Double(i % 3) * 0.3
                        let progress = (time * speed + Double(i) * 20.0).truncatingRemainder(dividingBy: 1.0)
                        
                        // Diagonal trajectory
                        let startX = size.width * 0.2 + Double(i) * (size.width * 0.15)
                        let startY = -50.0
                        let endX = size.width * 0.8 + Double(i) * (size.width * 0.05)
                        let endY = size.height + 50.0
                        
                        let currentX = startX + (endX - startX) * progress
                        let currentY = startY + (endY - startY) * progress
                        
                        // Draw trail
                        let trailLength = 50.0
                        var path = Path()
                        path.move(to: CGPoint(x: currentX, y: currentY))
                        path.addLine(to: CGPoint(
                            x: currentX - (endX - startX) / abs(endX - startX) * trailLength,
                            y: currentY - trailLength
                        ))
                        
                        context.opacity = 0.6 * (1.0 - progress) // Fade as it goes
                        context.stroke(path, with: .color(.white), lineWidth: 2)
                        
                        // Bright head
                        context.opacity = 0.9 * (1.0 - progress)
                        context.fill(
                            Path(ellipseIn: CGRect(x: currentX - 3, y: currentY - 3, width: 6, height: 6)),
                            with: .color(.white)
                        )
                    }
                    
                case .moonlight:
                    // Soft moonlight effect with gentle particles
                    // Moon glow
                    let moonX = size.width * 0.8
                    let moonY = size.height * 0.2
                    
                    for i in 0..<5 {
                        let radius = 40.0 + Double(i) * 15.0
                        let opacity = 0.03 / (Double(i) + 1.0)
                        context.opacity = opacity
                        context.fill(
                            Path(ellipseIn: CGRect(x: moonX - radius, y: moonY - radius, width: radius * 2, height: radius * 2)),
                            with: .color(Color(red: 0.9, green: 0.95, blue: 1.0))
                        )
                    }
                    
                    // Moonlight particles
                    for i in 0..<40 {
                        let t = time * 0.1 + Double(i) * 5.0
                        let x = (sin(t * 0.3) * 0.5 + 0.5) * size.width
                        let y = (cos(t * 0.25) * 0.5 + 0.5) * size.height
                        let radius = 1.0 + sin(t * 2.0) * 0.5
                        let opacity = 0.1 + 0.15 * abs(sin(t * 1.5))
                        
                        context.opacity = opacity
                        context.fill(
                            Path(ellipseIn: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)),
                            with: .color(Color(red: 0.8, green: 0.9, blue: 1.0))
                        )
                    }
                    
                case .bioluminescence:
                    // Glowing ocean creatures
                    for i in 0..<50 {
                        let t = time * 0.15 + Double(i) * 8.0
                        let x = (sin(t * 0.25 + Double(i)) * 0.5 + 0.5) * size.width
                        let y = (cos(t * 0.2 + Double(i)) * 0.5 + 0.5) * size.height
                        
                        // Pulsing glow
                        let pulse = 0.4 + 0.6 * abs(sin(t * 2.0))
                        let baseRadius = 2.0 + Double(i % 4)
                        let radius = baseRadius * pulse
                        
                        // Color variation - cyan to blue
                        let colorVar = i % 3
                        let glowColor: Color
                        switch colorVar {
                        case 0: glowColor = Color(red: 0.0, green: 0.8, blue: 1.0) // Cyan
                        case 1: glowColor = Color(red: 0.2, green: 0.6, blue: 1.0) // Light blue
                        default: glowColor = Color(red: 0.4, green: 1.0, blue: 0.8) // Aqua
                        }
                        
                        context.opacity = 0.3 * pulse
                        
                        // Core
                        context.fill(
                            Path(ellipseIn: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)),
                            with: .color(glowColor)
                        )
                        
                        // Glow halo
                        context.opacity = 0.1 * pulse
                        let glowRadius = radius * 3
                        context.fill(
                            Path(ellipseIn: CGRect(x: x - glowRadius, y: y - glowRadius, width: glowRadius * 2, height: glowRadius * 2)),
                            with: .color(glowColor)
                        )
                    }
                    
                case .fallingPetals:
                    // Cherry blossom petals falling
                    for i in 0..<40 {
                        let speed = 15.0 + Double(i % 5) * 5.0
                        let yOffset = (time * speed).truncatingRemainder(dividingBy: size.height + 100)
                        let y = -50.0 + yOffset
                        
                        // Swaying motion
                        let sway = sin(time * 2.0 + Double(i)) * 30.0
                        let xBase = (Double(i * 73) * 11.0).truncatingRemainder(dividingBy: size.width)
                        let x = xBase + sway
                        
                        // Rotation
                        let rotation = time * 1.5 + Double(i)
                        
                        // Petal shape (simplified as ellipse)
                        let width = 4.0 + Double(i % 3)
                        let height = width * 1.5
                        
                        context.opacity = 0.3 + 0.2 * abs(sin(time + Double(i)))
                        
                        // Save and rotate context
                        context.translateBy(x: x, y: y)
                        context.rotate(by: Angle(radians: rotation))
                        
                        // Draw petal
                        let petalColor = Color(red: 1.0, green: 0.7 + Double(i % 3) * 0.1, blue: 0.8)
                        context.fill(
                            Path(ellipseIn: CGRect(x: -width/2, y: -height/2, width: width, height: height)),
                            with: .color(petalColor)
                        )
                        
                        // Restore context
                        context.rotate(by: Angle(radians: -rotation))
                        context.translateBy(x: -x, y: -y)
                    }
                    
                case .energyBolts:
                    // Electric energy bolts
                    for i in 0..<6 {
                        let interval = 3.0 // Seconds between strikes
                        let strikeProgress = (time + Double(i) * 0.5).truncatingRemainder(dividingBy: interval) / interval
                        
                        if strikeProgress < 0.3 { // Only show for brief moment
                            let startX = Double.random(in: 0...size.width)
                            let startY = 0.0
                            
                            var path = Path()
                            path.move(to: CGPoint(x: startX, y: startY))
                            
                            var currentX = startX
                            var currentY = startY
                            
                            // Create jagged lightning path
                            for _ in 0..<8 {
                                currentX += Double.random(in: -30...30)
                                currentY += size.height / 8.0
                                path.addLine(to: CGPoint(x: currentX, y: currentY))
                            }
                            
                            let flash = 1.0 - (strikeProgress / 0.3)
                            context.opacity = 0.4 * flash
                            
                            // Outer glow
                            context.stroke(path, with: .color(Color.purple.opacity(0.6)), lineWidth: 4)
                            
                            // Inner bright core
                            context.opacity = 0.8 * flash
                            context.stroke(path, with: .color(.white), lineWidth: 2)
                        }
                    }
                }
            }
        }
    }

}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: AppTheme = .universe {
        didSet {
            // Only save to UserDefaults if not in preview mode
            if !isPreviewMode {
                UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
            }
        }
    }
    
    @Published var isPreviewMode: Bool = false
    
    private var savedTheme: AppTheme = .universe
    
    private init() {
        if let savedThemeString = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = AppTheme(rawValue: savedThemeString) {
            self.savedTheme = theme
            self.currentTheme = theme
        }
    }
    
    func setTheme(_ theme: AppTheme, isPreview: Bool = false) {
        // CRITICAL: Set preview mode FIRST before changing theme
        // Otherwise didSet will trigger with isPreviewMode still false
        isPreviewMode = isPreview
        currentTheme = theme
        
        // Update savedTheme if this is not a preview
        if !isPreview {
            savedTheme = theme
        }
    }
    
    func clearPreview() {
        if isPreviewMode {
            // Always read the actual saved theme from UserDefaults instead of relying on cached value
            if let savedThemeString = UserDefaults.standard.string(forKey: "selectedTheme"),
               let theme = AppTheme(rawValue: savedThemeString) {
                currentTheme = theme
            } else {
                currentTheme = .universe // Default if nothing saved
            }
            isPreviewMode = false
        }
    }
    
    func commitPreview() {
        if isPreviewMode {
            savedTheme = currentTheme
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
            isPreviewMode = false
        }
    }
}
