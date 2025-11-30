import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool
    
    // Animation States
    @State private var sphereOpacity: Double = 0.0
    @State private var breathScale: CGFloat = 1.0
    @State private var rippleScale: CGFloat = 0.0
    @State private var rippleOpacity: Double = 0.0
    @State private var viewOpacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // Pure Black Background
            Color.black.ignoresSafeArea()
            
            ZStack {
                // Ripple Effect (3 concentric circles)
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 280, height: 280)
                        .scaleEffect(rippleScale)
                        .opacity(rippleOpacity * (1.0 - Double(index) * 0.3))
                        .animation(
                            .easeOut(duration: 1.0)
                                .delay(Double(index) * 0.15),
                            value: rippleScale
                        )
                }
                
                // The Breathing Sphere
                FluidSphereView(
                    isInteracting: .constant(false),
                    touchLocation: .zero,
                    material: targetMaterial,
                    stability: 75.0, // Calm, stable state
                    isTransparent: true,
                    isStatic: true // Keep sphere static, only breathing animation
                )
                .frame(width: 280, height: 280)
                .scaleEffect(breathScale)
                .opacity(sphereOpacity)
                
            }
        }
        .opacity(viewOpacity)
        .onAppear {
            startSmoothAnimation()
        }
    }
    
    // MARK: - Animation Logic
    
    private func startSmoothAnimation() {
        print("🎬 Splash: Animation started")
        
        // Immediately show the sphere with fade in and scale up (slower)
        withAnimation(.easeIn(duration: 0.5)) {
            sphereOpacity = 0.9
            breathScale = 1.0 // Start at normal size
        }
        
        // Haptic feedback at start
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            HapticManager.shared.impact(style: .light)
        }
        
        // Start breathing animation after sphere is visible (0.5s - 1.8s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("🫁 Splash: Starting breath animation")
            // Inhale (slow and smooth)
            withAnimation(.easeInOut(duration: 0.7)) {
                breathScale = 1.1
            }
            
            // Exhale + Ripple
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                print("💨 Splash: Exhale + Ripple")
                // Exhale back to normal
                withAnimation(.easeOut(duration: 0.6)) {
                    breathScale = 1.0
                }
                
                // Trigger ripple
                withAnimation(.easeOut(duration: 1.2)) {
                    rippleScale = 2.5
                    rippleOpacity = 1.0
                }
                
                // Fade out ripple
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.easeOut(duration: 0.6)) {
                        rippleOpacity = 0.0
                    }
                }
            }
        }
        
        // Fade out entire splash (3.5s - 4.5s) - Extended duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            print("👋 Splash: Fading out")
            withAnimation(.easeOut(duration: 1.0)) {
                viewOpacity = 0.0
            }
            
            // Deactivate splash
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                print("✅ Splash: Deactivating (isActive = false)")
                isActive = false
            }
        }
    }
    
    // MARK: - Helpers
    
    /// Get the target material (user's choice or default)
    private var targetMaterial: FluidSphereView.SphereMaterial {
        let savedMaterial = StatusManager.shared.sphereMaterial
        switch savedMaterial {
        case "lava": return .lava
        case "ice": return .ice
        case "ink": return .ink
        case "gold": return .gold
        case "neon": return .neon
        case "void": return .void
        default: return .default
        }
    }
}
