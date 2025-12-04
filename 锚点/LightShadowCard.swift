import SwiftUI

struct LightShadowCard: View {
    let title: String
    let subtitle: String
    let iconType: IconType
    let color: Color
    var isCompleted: Bool = false
    var isLocked: Bool = false // New: Locked state
    var isActive: Bool = false // New: Active state (next to be done)
    let action: () -> Void
    
    @State private var shakeOffset: CGFloat = 0 // For shake animation
    
    enum IconType {
        case ripple // Touch Anchor
        case eye // Flow Core
        case purification // Emotional Photolysis
    }
    
    var body: some View {
        Button(action: {
            if isLocked {
                triggerShake()
            } else {
                action()
            }
        }) {
            HStack(spacing: 20) {
                // 1. Icon
                CardIcon(type: iconType, color: isCompleted ? .white : (isLocked ? .gray : color))
                    .saturation(isCompleted ? 0 : (isLocked ? 0 : 1))
                    .opacity(isLocked ? 0.5 : 1.0)
                
                // 2. Text
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(isLocked ? .gray : .white)
                        .shadow(color: isLocked ? .clear : .white.opacity(0.6), radius: 8, x: 0, y: 0)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .thin))
                        .foregroundColor(isLocked ? .gray.opacity(0.6) : .white.opacity(0.8))
                }
                
                Spacer()
                
                // 3. Light Point (Replaces Arrow)
                if isCompleted {
                    // Glowing Light Point for completed state
                    ZStack {
                        // Glow
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 20, height: 20)
                            .blur(radius: 8)
                        
                        // Core
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                            .shadow(color: .white, radius: 5)
                    }
                    .frame(width: 40, height: 40)
                } else {
                    LightPointView(color: color, isActive: isActive, isLocked: isLocked)
                }
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 24)
            .background(
                ZStack {
                    // Glass Background
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .opacity(isLocked ? 0.2 : 0.3) // Increased locked opacity
                    
                    // Dark Tint
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.black.opacity(isLocked ? 0.6 : 0.4))
                    
                    // Glowing Border
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(
                            isLocked ?
                            // Locked Border: Subtle Gray
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            :
                            // Active/Completed Border: Colored
                            LinearGradient(
                                colors: [
                                    color.opacity(0.8),
                                    color.opacity(0.5),
                                    color.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                        .shadow(color: isLocked ? .clear : color.opacity(0.3), radius: 8, x: 0, y: 0)
                }
            )
            .scaleEffect(isCompleted ? 0.98 : 1.0)
            .offset(x: shakeOffset) // Apply shake
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCompleted)
        }
        .buttonStyle(CardScaleButtonStyle())
        .disabled(false) // We handle "disabled" manually to allow shake
    }
    
    private func triggerShake() {
        let duration = 0.4
        let shakes = 4
        
        withAnimation(.default) {
            self.shakeOffset = 10
        }
        
        // Simple shake logic
        for i in 0..<shakes {
            let delay = Double(i) * (duration / Double(shakes))
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.linear(duration: duration / Double(shakes))) {
                    self.shakeOffset = (i % 2 == 0 ? -10 : 10)
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.default) {
                self.shakeOffset = 0
            }
        }
    }
}

struct LightPointView: View {
    let color: Color
    let isActive: Bool
    let isLocked: Bool
    
    @State private var pulse: Bool = false
    
    var body: some View {
        ZStack {
            if isActive {
                // Pulsing Halo / Wave
                Circle()
                    .stroke(color.opacity(0.5), lineWidth: 1)
                    .frame(width: 40, height: 40)
                    .scaleEffect(pulse ? 1.5 : 0.5)
                    .opacity(pulse ? 0 : 1)
                    .animation(
                        Animation.easeOut(duration: 2.0).repeatForever(autoreverses: false),
                        value: pulse
                    )
                
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 1)
                    .frame(width: 40, height: 40)
                    .scaleEffect(pulse ? 1.2 : 0.5)
                    .opacity(pulse ? 0 : 1)
                    .animation(
                        Animation.easeOut(duration: 2.0).delay(0.5).repeatForever(autoreverses: false),
                        value: pulse
                    )
            }
            
            // Core Point
            Circle()
                .fill(isLocked ? Color.gray.opacity(0.3) : color)
                .frame(width: 8, height: 8)
                .shadow(color: isLocked ? .clear : color, radius: 5)
        }
        .frame(width: 40, height: 40)
        .onAppear {
            if isActive {
                pulse = true
            }
        }
        .onChange(of: isActive) { newValue in
            pulse = newValue
        }
    }
}

struct CardIcon: View {
    let type: LightShadowCard.IconType
    let color: Color
    
    var body: some View {
        ZStack {
            // Glow
            Circle()
                .fill(color.opacity(0.3))
                .frame(width: 44, height: 44)
                .blur(radius: 10)
            
            switch type {
            case .ripple:
                // Abstract Ripple
                ZStack {
                    Circle()
                        .stroke(color, lineWidth: 1.5)
                        .frame(width: 12, height: 12)
                    Circle()
                        .stroke(color.opacity(0.7), lineWidth: 1)
                        .frame(width: 24, height: 24)
                    Circle()
                        .stroke(color.opacity(0.4), lineWidth: 1)
                        .frame(width: 36, height: 36)
                        .mask(Circle().strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5, 5])))
                }
            case .eye:
                // Abstract Eye/Vortex
                ZStack {
                    Circle()
                        .fill(color)
                        .frame(width: 6, height: 6)
                    Circle()
                        .stroke(color.opacity(0.8), lineWidth: 1.5)
                        .frame(width: 20, height: 12)
                    Circle()
                        .stroke(color.opacity(0.5), lineWidth: 1)
                        .frame(width: 32, height: 32)
                        .rotationEffect(.degrees(45))
                }
            case .purification:
                // Abstract Purification (Upward lines)
                HStack(spacing: 4) {
                    Capsule()
                        .fill(LinearGradient(colors: [color.opacity(0), color], startPoint: .bottom, endPoint: .top))
                        .frame(width: 2, height: 16)
                        .offset(y: 4)
                    Capsule()
                        .fill(LinearGradient(colors: [color.opacity(0), color], startPoint: .bottom, endPoint: .top))
                        .frame(width: 2, height: 24)
                        .offset(y: -2)
                    Capsule()
                        .fill(LinearGradient(colors: [color.opacity(0), color], startPoint: .bottom, endPoint: .top))
                        .frame(width: 2, height: 12)
                        .offset(y: 6)
                }
            }
        }
        .frame(width: 44, height: 44)
    }
}

struct CardScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
