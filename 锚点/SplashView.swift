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
                FluidSphereVisualizer(
                    isInteracting: .constant(false),
                    touchLocation: .zero,
                    material: targetMaterial,
                    stability: 75.0, // Calm, stable state
                    isTransparent: true,
                    isStatic: true,
                    isFullyStatic: true // Completely static, no internal animations
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
        
        // Immediately show the sphere with fade in (sphere remains still)
        withAnimation(.easeIn(duration: 0.5)) {
            sphereOpacity = 0.9
            // breathScale remains 1.0 - no breathing animation
        }
        
        // Haptic feedback at start
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            HapticManager.shared.impact(style: .light)
        }
        
        // After sphere is visible, trigger ripple effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("💫 Splash: Triggering ripple")
            
            // Trigger ripple without breathing animation
            withAnimation(.easeOut(duration: 1.2)) {
                rippleScale = 2.5
                rippleOpacity = 1.0
            }
            
            // Fade out ripple and then fade out splash immediately after
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeOut(duration: 0.6)) {
                    rippleOpacity = 0.0
                }
                
                // Start fading out splash right after ripple completes (total ~2.2s)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    print("👋 Splash: Fading out")
                    withAnimation(.easeOut(duration: 0.5)) {
                        viewOpacity = 0.0
                    }
                    
                    // Deactivate splash
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        print("✅ Splash: Deactivating (isActive = false)")
                        isActive = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    /// Get the target material (user's choice or default)
    private var targetMaterial: FluidSphereVisualizer.SphereMaterial {
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
