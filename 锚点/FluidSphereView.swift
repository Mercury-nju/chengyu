import SwiftUI
import Combine
import UIKit

struct FluidSphereVisualizer: View {
    @Binding var isInteracting: Bool
    var touchLocation: CGPoint
    var material: SphereMaterial = .default
    var stability: Double = 50.0 // MOF: Stability Value (0-100)
    var isTransparent: Bool = false // New property to control background
    var isStatic: Bool = false // Disable position movement (for Calm/Splash views)
    var isFullyStatic: Bool = false // Disable all animations including breathing (for Splash only)
    
    // Use StateObject to persist simulation state across View updates
    @StateObject private var engine = FluidSphereEngine()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 1. Deep Void Background (Ensures glow pops)
                if !isTransparent {
                    Color.black.opacity(0.8).ignoresSafeArea()
                }
                
                // 2. The "Liquid Light" Engine
                Group {
                    if isFullyStatic {
                        // 静止模式：只渲染一次
                        Canvas { context, size in
                            renderSphere(context: &context, size: size)
                        }
                    } else {
                        // 动画模式：持续刷新
                        TimelineView(.animation) { timeline in
                            Canvas { context, size in
                                engine.update(date: timeline.date)
                                renderSphere(context: &context, size: size)
                            }
                        }
                    }
                }
            }
            .onAppear {
                engine.setup(in: geometry.size)
                // Only start engine if not fully static
                if !isFullyStatic {
                    engine.start()
                }
            }
            .onChange(of: isInteracting) { newValue in
                engine.isInteracting = newValue
            }
            .onChange(of: touchLocation) { newValue in
                engine.touchLocation = newValue
            }
            .onChange(of: stability) { newValue in
                engine.stability = newValue
            }
            .onChange(of: isStatic) { newValue in
                engine.isStatic = newValue
            }
            .onChange(of: isFullyStatic) { newValue in
                engine.isFullyStatic = newValue
                // Start or stop engine based on static state
                if newValue {
                    engine.stop()
                } else {
                    engine.start()
                }
            }
        }
    }
    
    // MARK: - Render Helper
    
    private func renderSphere(context: inout GraphicsContext, size: CGSize) {
        // A. Glow Core (The Light) - Additive Blending
        context.blendMode = material.blendMode
        context.addFilter(.blur(radius: material.blurRadius))
        
        let currentColors = material.colors
        let orbs = engine.orbs
        
        for orb in orbs {
            let path = Path(ellipseIn: CGRect(
                x: orb.position.x - orb.radius,
                y: orb.position.y - orb.radius,
                width: orb.radius * 2,
                height: orb.radius * 2
            ))
            let baseColor = currentColors[orb.colorIndex % currentColors.count]
            let finalColor = baseColor.opacity(0.6)
            
            context.fill(path, with: .color(finalColor))
        }
        
        // Reset Blend Mode for next layers
        context.blendMode = .normal
        context.addFilter(.blur(radius: 0))
        
        // B. Fluid Body Mask (Metaball Shape)
        context.drawLayer { ctx in
            ctx.addFilter(.alphaThreshold(min: 0.5, color: .white))
            ctx.addFilter(.blur(radius: 30))
            
            for orb in orbs {
                let path = Path(ellipseIn: CGRect(
                    x: orb.position.x - orb.radius * 0.8,
                    y: orb.position.y - orb.radius * 0.8,
                    width: orb.radius * 1.6,
                    height: orb.radius * 1.6
                ))
                ctx.fill(path, with: .color(.white))
            }
        }
        
        // C. Specular Highlights (The Membrane)
        context.blendMode = .overlay
        for orb in orbs {
            let highlightPath = Path(ellipseIn: CGRect(
                x: orb.position.x - orb.radius * 0.3,
                y: orb.position.y - orb.radius * 0.5,
                width: orb.radius * 0.5,
                height: orb.radius * 0.2
            ))
            context.fill(highlightPath, with: .color(.white.opacity(0.8)))
        }
    }
    
    enum SphereMaterial {
        case `default`
        
        // 免费材质
        case lava // 熔岩核心
        case ice  // 寒冰晶格
        case gold // 鎏金岁月
        
        // 会员材质
        case amber   // 琥珀之光
        case neon    // 赛博霓虹
        case nebula  // 星云漩涡
        case aurora  // 极光幻境
        case sakura  // 樱花之梦
        case ocean   // 深海秘境
        case sunset  // 落日余晖
        case forest  // 翡翠森林
        case galaxy  // 星河漫游
        case crystal // 水晶灵韵
        case ink     // 墨色深渊
        case void    // 虚空之境
        
        static func fromString(_ name: String) -> SphereMaterial {
            switch name {
            case "lava": return .lava
            case "ice": return .ice
            case "gold": return .gold
            case "amber": return .amber
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
        
        var colors: [Color] {
            switch self {
            case .default:
                return [
                    Color(red: 0.4, green: 0.8, blue: 1.0), // Cyan
                    Color(red: 0.8, green: 0.5, blue: 1.0), // Lavender
                    Color(red: 0.2, green: 0.4, blue: 1.0), // Royal Blue
                    Color(red: 1.0, green: 0.5, blue: 0.8)  // Hot Pink
                ]
            case .lava:
                return [
                    Color(red: 0.8, green: 0.1, blue: 0.0), // Dark Red
                    Color(red: 1.0, green: 0.3, blue: 0.0), // Orange
                    Color(red: 0.5, green: 0.0, blue: 0.0), // Deep Red
                    Color(red: 1.0, green: 0.6, blue: 0.1)  // Yellow-Orange
                ]
            case .ice:
                return [
                    Color(red: 0.8, green: 0.9, blue: 1.0), // White-Blue
                    Color(red: 0.0, green: 1.0, blue: 1.0), // Cyan
                    Color(red: 0.0, green: 0.5, blue: 1.0), // Blue
                    Color.white
                ]
            case .amber:
                return [
                    Color(red: 1.0, green: 0.6, blue: 0.0),  // 明亮的琥珀橙
                    Color(red: 0.9, green: 0.5, blue: 0.1),  // 深琥珀
                    Color(red: 1.0, green: 0.75, blue: 0.3), // 浅琥珀金
                    Color(red: 0.8, green: 0.4, blue: 0.0)   // 暖棕色
                ]
            case .gold:
                return [
                    Color(red: 1.0, green: 0.84, blue: 0.0), // Gold
                    Color(red: 0.85, green: 0.65, blue: 0.13), // Goldenrod
                    Color(red: 1.0, green: 0.9, blue: 0.5), // Light Gold
                    Color(red: 0.6, green: 0.4, blue: 0.0) // Dark Gold
                ]
            case .neon:
                return [
                    Color(red: 0.0, green: 1.0, blue: 0.0), // Lime
                    Color(red: 1.0, green: 0.0, blue: 1.0), // Magenta
                    Color(red: 0.0, green: 1.0, blue: 1.0), // Cyan
                    Color(red: 1.0, green: 1.0, blue: 0.0) // Yellow
                ]
            case .nebula:
                return [
                    Color(red: 0.4, green: 0.2, blue: 0.8),  // 明亮的紫色
                    Color(red: 0.6, green: 0.3, blue: 1.0),  // 亮紫罗兰
                    Color(red: 0.3, green: 0.5, blue: 0.9),  // 蓝紫色
                    Color(red: 0.8, green: 0.4, blue: 0.9)   // 粉紫色
                ]
            case .aurora:
                return [
                    Color(red: 0.0, green: 1.0, blue: 0.5), // Green
                    Color(red: 0.0, green: 0.8, blue: 1.0), // Cyan
                    Color(red: 0.5, green: 0.0, blue: 1.0), // Purple
                    Color(red: 1.0, green: 0.4, blue: 0.8)  // Pink
                ]
            case .sakura:
                return [
                    Color(red: 1.0, green: 0.7, blue: 0.8), // Light Pink
                    Color(red: 1.0, green: 0.4, blue: 0.6), // Pink
                    Color(red: 0.9, green: 0.5, blue: 0.7), // Rose
                    Color(red: 1.0, green: 0.9, blue: 0.95) // Pale Pink
                ]
            case .ocean:
                return [
                    Color(red: 0.0, green: 0.2, blue: 0.4), // Deep Blue
                    Color(red: 0.0, green: 0.4, blue: 0.6), // Ocean Blue
                    Color(red: 0.0, green: 0.6, blue: 0.8), // Turquoise
                    Color(red: 0.2, green: 0.8, blue: 0.9)  // Light Cyan
                ]
            case .sunset:
                return [
                    Color(red: 1.0, green: 0.3, blue: 0.2), // Red-Orange
                    Color(red: 1.0, green: 0.5, blue: 0.0), // Orange
                    Color(red: 1.0, green: 0.7, blue: 0.3), // Yellow-Orange
                    Color(red: 0.9, green: 0.4, blue: 0.6)  // Pink
                ]
            case .forest:
                return [
                    Color(red: 0.0, green: 0.5, blue: 0.2), // Forest Green
                    Color(red: 0.2, green: 0.7, blue: 0.3), // Green
                    Color(red: 0.4, green: 0.8, blue: 0.4), // Light Green
                    Color(red: 0.6, green: 0.9, blue: 0.5)  // Lime
                ]
            case .galaxy:
                return [
                    Color(red: 0.1, green: 0.0, blue: 0.3), // Deep Purple
                    Color(red: 0.3, green: 0.0, blue: 0.5), // Purple
                    Color(red: 0.5, green: 0.2, blue: 0.8), // Violet
                    Color(red: 0.8, green: 0.4, blue: 1.0)  // Light Purple
                ]
            case .crystal:
                return [
                    Color(red: 0.9, green: 0.95, blue: 1.0), // Ice White
                    Color(red: 0.7, green: 0.9, blue: 1.0),  // Light Blue
                    Color(red: 0.8, green: 0.85, blue: 0.95), // Pale Blue
                    Color.white
                ]
            case .ink:
                return [
                    Color(red: 0.1, green: 0.1, blue: 0.15), // Deep Ink
                    Color(red: 0.15, green: 0.15, blue: 0.2), // Dark Blue-Black
                    Color(red: 0.05, green: 0.05, blue: 0.1), // Almost Black
                    Color(red: 0.2, green: 0.2, blue: 0.25)  // Charcoal
                ]
            case .void:
                return [
                    Color(red: 0.05, green: 0.0, blue: 0.1),  // Deep Void Purple
                    Color(red: 0.1, green: 0.0, blue: 0.15),  // Dark Purple
                    Color(red: 0.0, green: 0.0, blue: 0.05),  // Near Black
                    Color(red: 0.15, green: 0.05, blue: 0.2)  // Void Purple
                ]
            }
        }
        
        var blendMode: GraphicsContext.BlendMode {
            switch self {
            case .ink, .void: return .normal // Ink and Void shouldn't glow additively
            default: return .plusLighter
            }
        }
        
        var blurRadius: CGFloat {
            switch self {
            case .ice: return 15     // 更锐利
            case .amber: return 18   // 琥珀：适中的柔和感
            case .nebula: return 22  // 星云：稍微柔和但清晰
            default: return 20
            }
        }
    }
    
    struct Orb: Identifiable {
        let id = UUID()
        var position: CGPoint
        var velocity: CGPoint
        var radius: CGFloat
        var colorIndex: Int
        var offset: CGFloat // Phase offset
    }
}

// MARK: - Simulation Engine

class FluidSphereEngine: ObservableObject {
    var orbs: [FluidSphereVisualizer.Orb] = []
    
    var isInteracting: Bool = false
    var touchLocation: CGPoint = .zero
    var stability: Double = 50.0 // MOF: Stability Value (0-100)
    var isStatic: Bool = false
    var isFullyStatic: Bool = false
    
    private var lastUpdateDate: Date?
    private var phase: Double = 0
    private var size: CGSize = .zero
    
    func setup(in size: CGSize) {
        self.size = size
        if orbs.isEmpty {
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            
            // Create a cluster of light orbs
            for i in 0..<6 {
                orbs.append(FluidSphereVisualizer.Orb(
                    position: center,
                    velocity: CGPoint(
                        x: CGFloat.random(in: -1...1),
                        y: CGFloat.random(in: -1...1)
                    ),
                    radius: CGFloat.random(in: 40...70), // Reduced from 80-120
                    colorIndex: i,
                    offset: CGFloat.random(in: 0...10)
                ))
            }
            // Manually notify view to render initial state
            objectWillChange.send()
        }
    }
    
    func start() {
        // No-op: Engine is now driven by TimelineView
        lastUpdateDate = nil
    }
    
    func stop() {
        // No-op: Engine is now driven by TimelineView
        lastUpdateDate = nil
    }
    
    func update(date: Date) {
        guard !orbs.isEmpty else { return }
        
        // Fully static mode: skip all updates
        if isFullyStatic { return }
        
        // Calculate Delta Time
        let deltaTime: TimeInterval
        if let lastDate = lastUpdateDate {
            deltaTime = date.timeIntervalSince(lastDate)
        } else {
            deltaTime = 1.0 / 60.0 // Default for first frame
        }
        lastUpdateDate = date
        
        // Cap delta time to prevent huge jumps if paused for too long
        let cappedDelta = min(deltaTime, 0.1)
        
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let target = isInteracting ? touchLocation : center
        
        // MOF Logic: Map Stability (0-100) to Dynamics
        let normalizedStability = stability / 100.0
        let chaosFactor = 1.0 - normalizedStability
        
        // Speed: 0% SV -> 2.5x speed, 100% SV -> 0.3x speed
        let speedMultiplier = 0.3 + (sqrt(chaosFactor) * 2.2)
        
        // Amplitude: 0% SV -> 1.5x amplitude, 100% SV -> 0.5x amplitude
        let amplitudeMultiplier = 0.5 + (chaosFactor * 1.0)
        
        // Update phase based on time (60fps baseline: 0.02 per frame ~= 1.2 per second)
        // So we multiply by 60 to normalize the speed to per-second units
        phase += cappedDelta * 1.2 * speedMultiplier
        
        for i in 0..<orbs.count {
            var orb = orbs[i]
            
            // Organic Movement Logic
            // 1. Attraction to center/target
            // Adjust attraction for delta time (approximate 60fps behavior: 0.05 per frame -> 3.0 per second)
            let dx = target.x - orb.position.x
            let dy = target.y - orb.position.y
            
            let attractionBase = isInteracting ? 0.08 : 0.05
            let attractionStrength = attractionBase * 60 * cappedDelta
            
            orb.position.x += dx * attractionStrength
            orb.position.y += dy * attractionStrength
            
            // 2. Perlin-like Noise Motion (using sin/cos)
            if !isStatic {
                let noiseX = CGFloat(cos(phase + Double(orb.offset)) * (2 * amplitudeMultiplier))
                let noiseY = CGFloat(sin((phase * 1.5) + Double(orb.offset)) * (2 * amplitudeMultiplier))
                orb.position.x += noiseX
                orb.position.y += noiseY
            }
            
            // 3. Breathing Radius
            orb.radius = 60 + CGFloat(sin((phase * 2) + Double(orb.offset)) * (5 * amplitudeMultiplier))
            
            orbs[i] = orb
        }
    }
}
