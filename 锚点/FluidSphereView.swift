import SwiftUI
import Combine
import UIKit

struct FluidSphereView: View {
    @Binding var isInteracting: Bool
    var touchLocation: CGPoint
    var material: SphereMaterial = .default
    var stability: Double = 50.0 // MOF: Stability Value (0-100)
    var isTransparent: Bool = false // New property to control background
    var isStatic: Bool = false // New property to disable movement (for Splash/Calm views)
    
    @State private var time: Double = 0
    @State private var orbs: [Orb] = []
    
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
    
    let timer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()
    
    // Use phase accumulation to prevent jumps when speed changes
    @State private var phase: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 1. Deep Void Background (Ensures glow pops)
                if !isTransparent {
                    Color.black.opacity(0.8).ignoresSafeArea()
                }
                
                // 2. The "Liquid Light" Engine
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        let center = CGPoint(x: size.width / 2, y: size.height / 2)
                        
                        // A. Glow Core (The Light) - Additive Blending
                        context.blendMode = material.blendMode
                        context.addFilter(.blur(radius: material.blurRadius)) // Heavy blur for "cloud" look
                        
                        let currentColors = material.colors
                        
                        for orb in orbs {
                            let path = Path(ellipseIn: CGRect(
                                x: orb.position.x - orb.radius,
                                y: orb.position.y - orb.radius,
                                width: orb.radius * 2,
                                height: orb.radius * 2
                            ))
                            let baseColor = currentColors[orb.colorIndex % currentColors.count]
                            // CRDS: Desaturate if decay multiplier is high (Impure state)
                            let decayMultiplier = StatusManager.shared.decayMultiplier
                            let saturationFactor = max(0.0, 1.0 - ((decayMultiplier - 1.0) / 5.0)) // 1.0 -> 0.0
                            
                            let finalColor: Color
                            if decayMultiplier > 1.5 {
                                let uiColor = UIColor(baseColor)
                                var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                                uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
                                finalColor = Color(hue: h, saturation: s * saturationFactor, brightness: b, opacity: 0.6)
                            } else {
                                finalColor = baseColor.opacity(0.6)
                            }
                            
                            context.fill(path, with: .color(finalColor))
                        }
                        
                        // Reset Blend Mode for next layers
                        context.blendMode = .normal
                        context.addFilter(.blur(radius: 0)) // Reset blur
                        
                        // B. Fluid Body Mask (Metaball Shape)
                        // We draw the shape into a new layer to use as a mask or container
                        context.drawLayer { ctx in
                            ctx.addFilter(.alphaThreshold(min: 0.5, color: .white))
                            ctx.addFilter(.blur(radius: 30))
                            
                            for orb in orbs {
                                let path = Path(ellipseIn: CGRect(
                                    x: orb.position.x - orb.radius * 0.8, // Slightly smaller for the "solid" core
                                    y: orb.position.y - orb.radius * 0.8,
                                    width: orb.radius * 1.6,
                                    height: orb.radius * 1.6
                                ))
                                ctx.fill(path, with: .color(.white))
                            }
                        }
                        
                        // C. Specular Highlights (The Membrane)
                        // Sharp, small reflections to simulate surface tension
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
                }
            }
            .onAppear {
                setupOrbs(in: geometry.size)
            }
            .onReceive(timer) { _ in
                updateOrbs(in: geometry.size)
            }
        }
    }
    
    private func setupOrbs(in size: CGSize) {
        orbs.removeAll() // Fix: Clear existing orbs to prevent accumulation on re-appear
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        
        // Create a cluster of light orbs
        for i in 0..<6 {
            orbs.append(Orb(
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
    }
    
    private func updateOrbs(in size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let target = isInteracting ? touchLocation : center
        
        // MOF Logic: Map Stability (0-100) to Dynamics
        // 0% Stability -> High Chaos (Speed 3.0x, Amplitude 1.5x)
        // 100% Stability -> Calm (Speed 0.2x, Amplitude 0.5x)
        let normalizedStability = stability / 100.0
        let chaosFactor = 1.0 - normalizedStability
        
        // CRDS: Decay Multiplier amplifies chaos
        // 1.0x -> Normal
        // 7.5x -> Extreme Agitation
        let decayMultiplier = StatusManager.shared.decayMultiplier
        let agitation = (decayMultiplier - 1.0) / 6.5 // Normalize 1.0-7.5 to 0.0-1.0
        
        let speedMultiplier = 0.2 + (chaosFactor * 2.8) + (agitation * 4.0) // Boost speed significantly
        let amplitudeMultiplier = 0.5 + (chaosFactor * 1.0) + (agitation * 2.0) // Boost amplitude
        
        // Update phase based on current speed
        phase += 0.02 * speedMultiplier
        
        for i in 0..<orbs.count {
            var orb = orbs[i]
            
            // Organic Movement Logic
            // 1. Attraction to center/target
            let dx = target.x - orb.position.x
            let dy = target.y - orb.position.y
            
            // Variable attraction based on index for "layering" effect
            let attractionStrength = isInteracting ? 0.08 : 0.05
            orb.position.x += dx * attractionStrength
            orb.position.y += dy * attractionStrength
            
            // 2. Perlin-like Noise Motion (using sin/cos)
            // Skip movement if in static mode (for Splash/Calm views)
            if !isStatic {
                // Use accumulated phase instead of time * speedMultiplier
                let noiseX = CGFloat(cos(phase + Double(orb.offset)) * (2 * amplitudeMultiplier))
                let noiseY = CGFloat(sin((phase * 1.5) + Double(orb.offset)) * (2 * amplitudeMultiplier))
                orb.position.x += noiseX
                orb.position.y += noiseY
            }
            
            // 3. Breathing Radius
            // Use accumulated phase
            orb.radius = 60 + CGFloat(sin((phase * 2) + Double(orb.offset)) * (5 * amplitudeMultiplier))
            
            orbs[i] = orb
        }
    }
}
