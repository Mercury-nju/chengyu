import SwiftUI

struct FocusReadSessionView: View {
    @Binding var unlockNext: Bool
    @State private var touchLocation: CGPoint = .zero
    @State private var isTouching = false
    @State private var lastDragTime: Date = Date()
    @State private var lastDragLocation: CGPoint = .zero
    @State private var isTooFast: Bool = false
    
    // Data Tracking
    @State private var totalReadingTime: TimeInterval = 0
    @State private var effectiveReadingTime: TimeInterval = 0
    
    // Reading Progress State
    @State private var completedLinesHeight: CGFloat = 0.0 // Height of fully read lines
    @State private var currentLineX: CGFloat = 0.0 // Horizontal progress on current line
    @State private var lineHeight: CGFloat = 30.0 // Estimated, will measure
    @State private var contentHeight: CGFloat = 1.0
    @State private var isReadingComplete = false
    
    // Sealing & Enlightenment State
    @State private var isSealing = false
    @State private var sealingProgress: CGFloat = 0.0
    @State private var isEnlightened = false
    @State private var showFlash = false // New state for flash transition
    @State private var timer: Timer?
    
    @Environment(\.presentationMode) var presentationMode
    
    let sampleText = L10n.flowReadingSample
    
    var body: some View {
        ZStack {
            // Background
            Group {
                if isEnlightened {
                    // Paper Mode Background
                    Color(red: 0.96, green: 0.93, blue: 0.88) // Warm off-white paper color
                } else {
                    Color.black
                }
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.0), value: isEnlightened)
            
            if isEnlightened {
                // Enlightenment Mode: Full Text + Insights
                enlightenedView
            } else {
                // Exploration Mode: Spotlight & Progressive Reading
                GeometryReader { geometry in
                    ZStack(alignment: .topLeading) {
                        // 1. Base Layer: Dim Text (Unread)
                        textLayer
                            .foregroundColor(Color.gray.opacity(0.3))
                        
                        // 2. Read Layer: Pale Yellow (Granular Reveal)
                        textLayer
                            .foregroundColor(Color(red: 1.0, green: 0.95, blue: 0.8))
                            .mask(
                                ZStack(alignment: .topLeading) {
                                    // Fully read lines
                                    Rectangle()
                                        .fill(Color.white)
                                        .frame(height: completedLinesHeight)
                                        .frame(maxWidth: .infinity)
                                    
                                    // Current line progress
                                    Rectangle()
                                        .fill(Color.white)
                                        .frame(width: currentLineX, height: lineHeight)
                                        .offset(y: completedLinesHeight)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            )
                        
                        // 3. Spotlight Layer: Bright White (Current Focus)
                        if isTouching {
                            textLayer
                                .foregroundColor(.white)
                                .shadow(color: .white.opacity(0.6), radius: 8, x: 0, y: 0) // Subtle glow
                                .mask(
                                    // Enhanced Flashlight Effect (Reduced Size)
                                    RadialGradient(
                                        gradient: Gradient(colors: [Color.white, Color.white.opacity(0.0)]),
                                        center: UnitPoint(
                                            x: touchLocation.x / geometry.size.width,
                                            y: touchLocation.y / geometry.size.height
                                        ),
                                        startRadius: 15, // Larger core
                                        endRadius: 80    // Much larger radius for comfort
                                    )
                                    .opacity(0.8)
                                )
                        }
                    }
                    .coordinateSpace(name: "ReadArea") // Define local coordinate space
                    .background(
                        // Measure Line Height & Content
                        ZStack {
                            // Measure total height
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear { contentHeight = geo.size.height }
                                    .onChange(of: geo.size.height) { contentHeight = $0 }
                            }
                            
                            // Measure single line height
                            Text("Test")
                                .font(Theme.fontBody())
                                .lineSpacing(12)
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .onAppear {
                                                // Approximate line height with spacing
                                                lineHeight = geo.size.height + 12
                                            }
                                    }
                                )
                                .hidden()
                        }
                    )
                    .padding(40)
                    // Gesture Area
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .named("ReadArea")) // Use local space
                            .onChanged { value in
                                handleDrag(value: value, geometry: geometry)
                            }
                            .onEnded { _ in
                                withAnimation {
                                    isTouching = false
                                }
                            }
                    )
                }
                
                // Completion Interaction (Only appears when fully read)
                if isReadingComplete {
                    sealingInteractionView
                }
                
                // Instruction Overlay
                if !isTouching && completedLinesHeight < 50 && !isReadingComplete {
                    VStack {
                        Spacer()
                        Text(L10n.holdAndSlide)
                            .font(Theme.fontCaption())
                            .foregroundColor(Theme.secondaryText)
                            .padding(.bottom, 50)
                    }
                    .transition(.opacity)
                }
            }
            
            // Flash Overlay
            if showFlash {
                Color.white
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(100) // Ensure it's on top
            }
        }
        #if os(iOS)
        .navigationBarHidden(true)
        #endif
    }
    
    // MARK: - Subviews
    
    private var textLayer: some View {
        Text(sampleText)
            .font(Theme.fontBody())
            .lineSpacing(12)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true) // Ensure consistent layout
    }
    
    private var enlightenedView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(sampleText)
                .font(Theme.fontBody())
                .foregroundColor(.black.opacity(0.8)) // Dark ink color for paper background
                .lineSpacing(12)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Text(L10n.finishReading)
                    .font(Theme.fontBody())
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .cornerRadius(12)
            }
        }
        .padding(40)
        .transition(.opacity)
    }
    
    private var sealingInteractionView: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                ZStack {
                    // Breathing Glow
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 40, height: 40)
                        .scaleEffect(isSealing ? 1.5 : 1.0)
                        .opacity(isSealing ? 0.8 : 0.3)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isSealing)
                    
                    // The Period Target
                    Circle()
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                }
                .frame(width: 60, height: 60)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !isSealing {
                                startSealing()
                            }
                        }
                        .onEnded { _ in
                            cancelSealing()
                        }
                )
                .padding(.trailing, 30)
                .padding(.bottom, 80)
            }
        }
        .transition(.opacity)
    }
    
    // MARK: - Logic
    
    private func handleDrag(value: DragGesture.Value, geometry: GeometryProxy) {
        let location = value.location
        isTouching = true
        touchLocation = location
        
        // Smart Grid Logic (Z-Pattern Enforcement)
        
        // 1. Determine Rows
        // We treat the text as a visual grid of lines.
        let touchRow = Int(location.y / lineHeight)
        let activeRow = Int(completedLinesHeight / lineHeight)
        
        // 2. Interaction Logic
        if touchRow == activeRow {
            // Case A: Reading the Current Line
            // Allow moving forward freely
            if location.x > currentLineX {
                currentLineX = location.x
            }
            
            // Check for Line Completion
            // If near the end, mark as complete
            if currentLineX > geometry.size.width - 30 {
                completedLinesHeight += lineHeight
                currentLineX = 0 // Reset for next line
                HapticManager.shared.impact(style: .light)
            }
            
        } else if touchRow == activeRow + 1 {
            // Case B: Moving to Next Line
            // CRITICAL: Prevent "Zipping" (dragging straight down the right edge).
            // We only allow starting the next line if the user enters from the LEFT side.
            
            let isStartingFromLeft = location.x < geometry.size.width * 0.6
            
            if isStartingFromLeft {
                // Auto-complete previous line (if not already)
                completedLinesHeight += lineHeight
                currentLineX = location.x // Start reading new line
                HapticManager.shared.impact(style: .light)
            } else {
                // User is touching the right side of the next line without reading it.
                // Ignore to prevent accidental completion.
                // This forces the user to move their finger back to the left (Z-pattern).
            }
            
        } else if touchRow == activeRow + 2 {
            // Case C: Paragraph Skip (Empty Line)
            // If the user skips a line, check if the skipped line is likely empty (or user is fast).
            // We allow it if they start from left.
            
            let isStartingFromLeft = location.x < geometry.size.width * 0.6
            
            if isStartingFromLeft {
                // Complete active row AND the skipped row
                completedLinesHeight += lineHeight * 2
                currentLineX = location.x
                HapticManager.shared.impact(style: .medium)
            }
        }
        
        // Check Session Completion
        if completedLinesHeight >= contentHeight - 50 {
            if !isReadingComplete {
                withAnimation {
                    isReadingComplete = true
                    HapticManager.shared.impact(style: .medium)
                }
            }
        }
        
        // Haptics for movement
        let currentTime = Date()
        if currentTime.timeIntervalSince(lastDragTime) > 0.05 {
            lastDragTime = currentTime
        }
    }
    
    private func startSealing() {
        guard timer == nil else { return }
        isSealing = true
        sealingProgress = 0.0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [self] _ in
            DispatchQueue.main.async {
                sealingProgress += 0.02
                
                HapticManager.shared.playChargingHaptic(intensity: Float(sealingProgress))
                // Sound removed for peaceful completion
                
                if sealingProgress >= 1.0 {
                    completeSealing()
                }
            }
        }
    }
    
    private func cancelSealing() {
        isSealing = false
        sealingProgress = 0.0
        timer?.invalidate()
        timer = nil
    }
    
    private func completeSealing() {
        timer?.invalidate()
        timer = nil
        
        // Sound removed for peaceful completion
        HapticManager.shared.playLockHaptic()
        
        // Record flow completion
        StatusManager.shared.recordFlowCompletion()
        
        unlockNext = true
        
        // Smoother Flash Transition Sequence
        withAnimation(.easeIn(duration: 0.8)) {
            showFlash = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isEnlightened = true
            isSealing = false
            
            withAnimation(.easeOut(duration: 1.2)) {
                showFlash = false
            }
        }
    }
}
