import SwiftUI

struct SubscriptionAlertOverlay: View {
    let musicName: String
    let onUpgrade: () -> Void
    let onDismiss: () -> Void
    
    @State private var appearAnimation = false
    
    var body: some View {
        ZStack {
            // 1. Backdrop
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            // 2. Alert Card
            VStack(spacing: 24) {
                // Text Content with glowing PLUS
                VStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Text(L10n.lumeaExclusive + " ")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(L10n.plusExclusive)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color(hex: "FFD700").opacity(0.8), radius: 8, x: 0, y: 0)
                            .shadow(color: Color(hex: "FFA500").opacity(0.6), radius: 12, x: 0, y: 0)
                        
                        Text(L10n.exclusiveMusic + "\(musicName)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .multilineTextAlignment(.center)
                    
                    Text(L10n.unlockSoundscape)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 16)
                }
                
                // Buttons
                VStack(spacing: 16) {
                    // Upgrade Button (Glowing Orange)
                    Button(action: onUpgrade) {
                        Text(L10n.upgradeNow)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                ZStack {
                                    // Base Gradient
                                    LinearGradient(
                                        colors: [Color(hex: "FF8C00"), Color(hex: "FF4500")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    
                                    // Shine effect
                                    LinearGradient(
                                        colors: [.white.opacity(0.2), .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                }
                                .cornerRadius(25)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: Color(hex: "FF4500").opacity(0.5), radius: 15, x: 0, y: 5)
                    }
                    
                    // Continue Button (Transparent)
                    Button(action: onDismiss) {
                        Text(L10n.continueListening)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.vertical, 8)
                    }
                }
                .padding(.top, 8)
            }
            .padding(32)
            .background(
                ZStack {
                    // Glass Background
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .opacity(0.9)
                    
                    // Dark Tint
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color.black.opacity(0.4))
                    
                    // Border Glow
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.15), .white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .frame(maxWidth: 340)
            .scaleEffect(appearAnimation ? 1.0 : 0.9)
            .opacity(appearAnimation ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                appearAnimation = true
            }
        }
    }
}

// Note: Color.init(hex:) is defined in Theme.swift
