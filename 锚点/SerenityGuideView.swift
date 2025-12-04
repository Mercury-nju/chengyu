import SwiftUI

struct SerenityGuideView: View {
    @Binding var currentStep: Int
    let targetFrames: [Int: CGRect] // Step Index -> Frame
    let onDismiss: () -> Void
    
    // Animation State
    @State private var animatedText: String = ""
    @State private var isTextComplete: Bool = false
    @State private var showHint: Bool = false
    @State private var contentOpacity: Double = 1.0
    
    // Guide Content Data
    private let guideSteps: [(text: String, title: String)] = [
        (L10n.guideStep0, ""),
        (L10n.guideStep1, ""),
        (L10n.guideStep2, ""),
        (L10n.guideStep3, ""),
        (L10n.guideStep4, "")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 1. Dimmed Background with Spotlight Cutout
                Color.black.opacity(0.85)
                    .mask(
                        ZStack {
                            Rectangle()
                                .fill(Color.white)
                            
                            // Cutout for current target
                            if currentStep < 5, let frame = targetFrames[currentStep] {
                                RoundedRectangle(cornerRadius: 32) // Match card corner radius
                                    .fill(Color.black)
                                    .frame(width: frame.width + 10, height: frame.height + 10) // Tighter padding
                                    .position(x: frame.midX, y: frame.midY)
                                    .blur(radius: 5) // Sharper edge
                            }
                        }
                        .compositingGroup()
                        .luminanceToAlpha()
                    )
                    .ignoresSafeArea()
                    .onTapGesture {
                        nextStep()
                    }
                
                // 2. Spotlight Border (Optional visual cue)
                if currentStep < 5, let frame = targetFrames[currentStep] {
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        .frame(width: frame.width + 16, height: frame.height + 16)
                        .position(x: frame.midX, y: frame.midY)
                        .animation(.spring(), value: currentStep)
                }
                
                // 3. Text Bubble
                if currentStep < guideSteps.count {
                    let frame = targetFrames[currentStep] ?? CGRect(x: geometry.size.width/2, y: geometry.size.height/2, width: 0, height: 0)
                    
                    VStack {
                        if currentStep == 0 {
                            // Sphere: Text below the sphere in the black area
                            Spacer()
                            guideTextView
                                .padding(.bottom, 80)
                        } else if currentStep == 4 {
                            // Conclusion: Text at Center
                            Spacer()
                            guideTextView
                            Spacer()
                        } else {
                            // Cards: Text positioned above the highlighted card
                            Spacer()
                            guideTextView
                                .padding(.bottom, geometry.size.height - frame.minY + 40)
                        }
                    }
                }
            }
            .onAppear {
                startTypewriter()
            }
            .onChange(of: currentStep) { _ in
                resetAndStartTypewriter()
            }
        }
    }
    
    private func startTypewriter() {
        let fullText = guideSteps[currentStep].text
        animatedText = ""
        isTextComplete = false
        showHint = false
        contentOpacity = 1.0
        
        // Cancel any existing timer if we had one (though we use a block-based one here, invalidating old one is tricky without reference. 
        // Better to rely on view identity change or just simple logic)
        
        // Typewriter Effect
        var charIndex = 0
        // Add a small delay to ensure view is ready and transition is done
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            Timer.scheduledTimer(withTimeInterval: 0.025, repeats: true) { timer in
                // Guard against step change during animation
                guard self.currentStep < self.guideSteps.count, 
                      fullText == self.guideSteps[self.currentStep].text else {
                    timer.invalidate()
                    return
                }
                
                if charIndex < fullText.count {
                    let index = fullText.index(fullText.startIndex, offsetBy: charIndex)
                    animatedText.append(fullText[index])
                    charIndex += 1
                    
                    // Play typewriter sound every 5 characters
                    if charIndex % 5 == 0 {
                        SoundManager.shared.playTypewriterClick()
                    }
                } else {
                    timer.invalidate()
                    isTextComplete = true
                    
                    // Show hint after 1 second delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation {
                            showHint = true
                        }
                    }
                }
            }
        }
    }
    
    private func resetAndStartTypewriter() {
        startTypewriter()
    }
    
    // Extracted View for Text Content to reuse
    private var guideTextView: some View {
        VStack(alignment: .center, spacing: 16) {
            Text(animatedText)
                .font(.system(size: 16, weight: .light, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(6)
                .frame(maxWidth: 300)
                .opacity(contentOpacity)
            
            if showHint {
                Text(currentStep == guideSteps.count - 1 ? L10n.tapToBegin : L10n.tapToContinue)
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(.white.opacity(0.6))
                    .transition(.opacity)
                    .padding(.top, 8)
                    .opacity(contentOpacity)
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
        .padding(.horizontal, 30)
        .id(currentStep)
    }
    
    private func nextStep() {
        if currentStep == 0 {
            // Special transition for Step 1
            withAnimation(.easeOut(duration: 0.5)) {
                contentOpacity = 0.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if currentStep < 4 {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        currentStep += 1
                        contentOpacity = 1.0 // Reset for next step (though next step uses different view logic maybe?)
                    }
                }
            }
        } else {
            if currentStep < 4 {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    currentStep += 1
                }
            } else {
                withAnimation {
                    onDismiss()
                }
            }
        }
    }
}
