import CoreHaptics
import Combine
#if canImport(UIKit)
import UIKit
#endif

class HapticManager: ObservableObject {
    static let shared = HapticManager()
    private var engine: CHHapticEngine?
    
    // Haptic enabled state
    @Published var isHapticEnabled: Bool = UserDefaults.standard.bool(forKey: "hapticEnabled") {
        didSet {
            UserDefaults.standard.set(isHapticEnabled, forKey: "hapticEnabled")
        }
    }
    
    init() {
        // Load saved state or default to true
        if UserDefaults.standard.object(forKey: "hapticEnabled") == nil {
            isHapticEnabled = true
            UserDefaults.standard.set(true, forKey: "hapticEnabled")
        }
        prepareHaptics()
    }
    
    func setHapticEnabled(_ enabled: Bool) {
        isHapticEnabled = enabled
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
    
    func playCalibrationHaptic() {
        guard isHapticEnabled, CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()
        
        // Sharp, crisp tap
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic: \(error.localizedDescription)")
        }
    }
    
    func playHeartbeat(intensity: Float) {
        #if canImport(UIKit)
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            let pattern = try createHeartbeatPattern(intensity: intensity)
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play heartbeat: \(error)")
        }
        #endif
    }
    
    func playChargingHaptic(intensity: Float) {
        #if canImport(UIKit)
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            // Create a continuous hum that increases in intensity
            let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
            let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensityParam, sharpnessParam], relativeTime: 0, duration: 0.1)
            
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play charging haptic: \(error)")
        }
        #endif
    }
    
    func playLockHaptic() {
        #if canImport(UIKit)
        // A crisp, mechanical "lock" sound/feeling
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
    
    func playLaunchSequence() {
        #if canImport(UIKit)
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            // Phase 1: The Void (Hum) - 0s to 1.5s
            let humParams = [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
            ]
            let humEvent = CHHapticEvent(eventType: .hapticContinuous, parameters: humParams, relativeTime: 0, duration: 1.5)
            
            // Phase 2: Signal (Static) - 1.5s to 3.0s
            let staticParams = [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
            ]
            let staticEvent = CHHapticEvent(eventType: .hapticContinuous, parameters: staticParams, relativeTime: 1.5, duration: 1.5)
            
            // Phase 3: The Sync (Heartbeat) - 3.0s
            // "Thump"
            let thumpParams = [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.2)
            ]
            let thumpEvent = CHHapticEvent(eventType: .hapticTransient, parameters: thumpParams, relativeTime: 3.0)
            
            // "Thud" (Echo)
            let thudParams = [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
            ]
            let thudEvent = CHHapticEvent(eventType: .hapticTransient, parameters: thudParams, relativeTime: 3.2)
            
            // Phase 4: The Gateway (Door Open) - 4.0s
            let doorParams = [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            ]
            let doorEvent = CHHapticEvent(eventType: .hapticTransient, parameters: doorParams, relativeTime: 4.0)
            
            let pattern = try CHHapticPattern(events: [humEvent, staticEvent, thumpEvent, thudEvent, doorEvent], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
            
        } catch {
            print("Failed to play launch sequence: \(error)")
        }
        #endif
    }

    private func createHeartbeatPattern(intensity: Float) throws -> CHHapticPattern {
        let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
        
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityParam, sharpnessParam], relativeTime: 0)
        
        return try CHHapticPattern(events: [event], parameters: [])
    }
    
    // Simple feedback for UI interactions
    func impact(style: Int) {
        #if canImport(UIKit)
        let feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle
        switch style {
        case 0: feedbackStyle = .light
        case 1: feedbackStyle = .medium
        case 2: feedbackStyle = .heavy
        default: feedbackStyle = .medium
        }
        let generator = UIImpactFeedbackGenerator(style: feedbackStyle)
        generator.impactOccurred()
        #endif
    }
    
    // Overload for easier usage if we can map enum directly, but Int is safer for cross-platform generic calls
    // Or we can keep the signature but make the argument generic or conditional.
    // For simplicity, let's change the signature to take an enum that we define ourselves, or just use Int/String.
    // Let's define a custom enum to avoid UIKit dependency in the signature.
    
    enum FeedbackStyle {
        case light, medium, heavy
    }
    
    func impact(style: FeedbackStyle) {
        guard isHapticEnabled else { return }
        #if canImport(UIKit)
        let uiStyle: UIImpactFeedbackGenerator.FeedbackStyle
        switch style {
        case .light: uiStyle = .light
        case .medium: uiStyle = .medium
        case .heavy: uiStyle = .heavy
        }
        let generator = UIImpactFeedbackGenerator(style: uiStyle)
        generator.impactOccurred()
        #endif
    }
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
        #endif
    }
    
    func playCrystallizeHaptic() {
        #if canImport(UIKit)
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            // A sharp, high-frequency "ping" followed by a resonant decay
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            let attack = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
            
            let decayParams = [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
            ]
            let decay = CHHapticEvent(eventType: .hapticContinuous, parameters: decayParams, relativeTime: 0.05, duration: 0.2)
            
            let pattern = try CHHapticPattern(events: [attack, decay], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play crystallize haptic: \(error)")
        }
        #endif
    }
    
    func playFusionRumble(intensity: Float) {
        #if canImport(UIKit)
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            // Continuous rumble, intensity controlled by parameter
            let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
            let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4) // Deep rumble
            
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensityParam, sharpnessParam], relativeTime: 0, duration: 0.1)
            
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            // Fallback or ignore
        }
        #endif
    }
    
    func playInstabilityKick() {
        #if canImport(UIKit)
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            // Sharp kick
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
            
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play instability kick: \(error)")
        }
        #endif
    }
    
    func playStickyDamping() {
        #if canImport(UIKit)
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            // Continuous, heavy, viscous feeling
            // Low sharpness (dull), High intensity (heavy)
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1)
            
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 0.1)
            
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play sticky haptic: \(error)")
        }
        #endif
    }
    
    func playShatterHaptic() {
        #if canImport(UIKit)
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            // Sharp break then chaos
            let sharp = CHHapticEvent(eventType: .hapticTransient, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            ], relativeTime: 0)
            
            let rumble = CHHapticEvent(eventType: .hapticContinuous, parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
            ], relativeTime: 0.05, duration: 0.3)
            
            let pattern = try CHHapticPattern(events: [sharp, rumble], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play shatter haptic: \(error)")
        }
        #endif
    }
}
