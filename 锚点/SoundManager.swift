import AVFoundation
import SwiftUI
import Combine

@MainActor
class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private var backgroundPlayer: AVAudioPlayer?
    
    // Cache for frequent sounds
    private var cachedClickData: Data?
    
    // Sound enabled state
    @Published var isSoundEnabled: Bool = UserDefaults.standard.bool(forKey: "soundEnabled") {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: "soundEnabled")
            if !isSoundEnabled {
                stopAllSounds()
            } else {
                // 重新启动背景音乐
                startAmbientBackgroundMusic()
            }
        }
    }
    
    private init() {
        // Load saved state or default to true
        if UserDefaults.standard.object(forKey: "soundEnabled") == nil {
            isSoundEnabled = true
            UserDefaults.standard.set(true, forKey: "soundEnabled")
        }
        setupAudioSession()
        preloadClickSound()
    }
    
    func setSoundEnabled(_ enabled: Bool) {
        isSoundEnabled = enabled
    }
    
    private func preloadClickSound() {
        // Pre-generate click sound data
        let frequency = 800.0
        let duration = 0.025
        let volume: Float = 0.12
        let sampleRate = 44100.0
        let samples = Int(sampleRate * duration)
        
        var audioData = [Int16]()
        for i in 0..<samples {
            let sample = sin(2.0 * .pi * frequency * Double(i) / sampleRate)
            let envelope = min(1.0, Double(i) / (sampleRate * 0.05)) * min(1.0, Double(samples - i) / (sampleRate * 0.05))
            audioData.append(Int16(sample * Double(volume) * envelope * 32767.0))
        }
        
        cachedClickData = createWAVData(from: audioData, sampleRate: sampleRate)
    }

    // ... (rest of class)

    func playTypewriterClick() {
        guard isSoundEnabled, let data = cachedClickData else { return }
        
        do {
            let player = try AVAudioPlayer(data: data)
            player.play()
            
            // Use a unique but deterministic key to avoid dictionary explosion
            // Or just fire and forget if we don't need to track it?
            // We need to track it to stop it or hold a reference so it plays.
            let key = "click_\(UUID().uuidString)"
            audioPlayers[key] = player
            
            // Cleanup
            DispatchQueue.main.asyncAfter(deadline: .now() + player.duration + 0.1) { [weak self] in
                self?.audioPlayers.removeValue(forKey: key)
            }
        } catch {
            print("Failed to play click: \(error)")
        }
    }
    
    private func setupAudioSession(forMeditation: Bool = false) {
        #if os(iOS)
        do {
            if forMeditation {
                // For meditation: Use .playback to play even in Silent Mode
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
                print("✅ Audio session configured for meditation: .playback")
            } else {
                // For background/ambient: Use .ambient, respects Silent Mode
                try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
                print("✅ Audio session configured for ambient: .ambient")
            }
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ Failed to setup audio session: \(error.localizedDescription)")
        }
        #endif
    }
    
    func pauseForRecording() {
        stopAllSounds()
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session for recording: \(error.localizedDescription)")
        }
        #endif
    }
    
    func resumeAfterRecording() {
        setupAudioSession()
    }
    
    // MARK: - Launch Sequence Sounds
    
    func playHumSound() {
        playGeneratedTone(frequency: 60, duration: 1.5, volume: 0.3, key: "hum")
    }
    
    func playStaticSound() {
        playGeneratedNoise(duration: 1.5, volume: 0.2, key: "static")
    }
    
    func playHeartbeatSound(intensity: Float = 0.5) {
        playGeneratedTone(frequency: 40, duration: 0.3, volume: intensity * 0.4, key: "heartbeat")
    }
    
    func playDoorOpenSound() {
        playGeneratedSweep(startFreq: 200, endFreq: 800, duration: 0.8, volume: 0.5, key: "door")
    }
    
    // MARK: - Session Sounds
    
    func playBreathingSound(phase: String) {
        switch phase {
        case "inhale":
            playGeneratedTone(frequency: 220, duration: 4.0, volume: 0.2, key: "breath_in")
        case "hold":
            playGeneratedTone(frequency: 110, duration: 7.0, volume: 0.15, key: "breath_hold")
        case "exhale":
            playGeneratedTone(frequency: 165, duration: 8.0, volume: 0.2, key: "breath_out")
        default:
            break
        }
    }
    
    func playShatterSound() {
        playGeneratedNoise(duration: 0.5, volume: 0.6, key: "shatter")
    }
    
    func playCrystallizeSound() {
        playGeneratedSweep(startFreq: 400, endFreq: 1200, duration: 2.0, volume: 0.4, key: "crystallize")
    }
    
    func playChargingSound(progress: Float) {
        let frequency = 200 + (progress * 600) // 200Hz to 800Hz
        playGeneratedTone(frequency: Double(frequency), duration: 0.1, volume: 0.3, key: "charging")
    }
    
    func playLockSound() {
        playGeneratedTone(frequency: 800, duration: 0.2, volume: 0.5, key: "lock")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.playGeneratedTone(frequency: 600, duration: 0.2, volume: 0.5, key: "lock2")
        }
    }
    
    // MARK: - Liquid Glass Sounds
    
    // MARK: - Liquid Glass Sounds
    
    func playWaterFlow() {
        // Irregular low frequency noise (Brownian noise approx)
        // We'll use a low pitched noise with volume fluctuation
        playGeneratedNoise(duration: 60, volume: 0.15, key: "water_flow")
    }
    
    func stopWaterFlow() {
        stopSound(key: "water_flow")
    }
    
    func playCrystalResonance() {
        // Pure, low frequency resonance (Glass humming)
        // 180Hz pure sine wave
        playGeneratedTone(frequency: 180, duration: 180, volume: 0.2, key: "crystal_resonance")
    }
    
    func stopCrystalResonance() {
        stopSound(key: "crystal_resonance")
    }
    
    func playLiquidShatter() {
        // High frequency chaotic noise
        playGeneratedNoise(duration: 0.4, volume: 0.7, key: "liquid_shatter")
        // Add a high pitch sweep down
        playGeneratedSweep(startFreq: 2000, endFreq: 500, duration: 0.3, volume: 0.5, key: "shatter_sweep")
    }
    
    func playDataTransfer() {
        // High speed, high energy sweep up
        playGeneratedSweep(startFreq: 400, endFreq: 4000, duration: 0.5, volume: 0.4, key: "data_transfer")
        // Accompanied by a short static burst
        playGeneratedNoise(duration: 0.2, volume: 0.3, key: "data_static")
    }
    
    // MARK: - Flow Core Casting Sounds
    
    func playChaosNoise() {
        // High pitch, jittery noise (Red/Orange chaos)
        playGeneratedNoise(duration: 60, volume: 0.2, key: "chaos_noise")
        playGeneratedSweep(startFreq: 800, endFreq: 1200, duration: 0.1, volume: 0.1, key: "chaos_glitch") // Occasional glitch
    }
    
    func stopChaosNoise() {
        stopSound(key: "chaos_noise")
    }
    
    func playFusionHum() {
        // Deep, stabilizing drone (Blue/Cyan fusion)
        playGeneratedTone(frequency: 120, duration: 60, volume: 0.3, key: "fusion_hum")
        playGeneratedTone(frequency: 240, duration: 60, volume: 0.1, key: "fusion_harmonic")
    }
    
    func stopFusionHum() {
        stopSound(key: "fusion_hum")
        stopSound(key: "fusion_harmonic")
    }
    
    func playInstabilityCrack() {
        // Sharp fracture sound
        playGeneratedNoise(duration: 0.1, volume: 0.6, key: "crack_noise")
        playGeneratedSweep(startFreq: 2000, endFreq: 100, duration: 0.1, volume: 0.4, key: "crack_drop")
    }
    
    func playCastingSuccess() {
        // Grand metallic/glassy chime
        playGeneratedTone(frequency: 528, duration: 4.0, volume: 0.5, key: "casting_success_base")
        playGeneratedTone(frequency: 1056, duration: 4.0, volume: 0.3, key: "casting_success_high")
    }
    
    func playOrbitCapture() {
        // Subtle swoosh
        playGeneratedSweep(startFreq: 200, endFreq: 400, duration: 0.2, volume: 0.1, key: "orbit_swoosh_\(Date().timeIntervalSince1970)")
    }
    
    func playParticleFuse() {
        // Soft pop/droplet
        playGeneratedTone(frequency: 800, duration: 0.05, volume: 0.1, key: "fuse_pop_\(Date().timeIntervalSince1970)")
    }
    
    // MARK: - Emotional Photolysis Sounds
    
    func playShadowFriction() {
        // Rough, grinding noise (Shadow Core)
        playGeneratedNoise(duration: 60, volume: 0.3, key: "shadow_friction")
        playGeneratedTone(frequency: 50, duration: 60, volume: 0.4, key: "shadow_rumble")
    }
    
    func stopShadowFriction() {
        stopSound(key: "shadow_friction")
        stopSound(key: "shadow_rumble")
    }
    
    func playPhotolysisBeam() {
        // High energy beam
        playGeneratedTone(frequency: 880, duration: 10, volume: 0.2, key: "photolysis_beam")
        playGeneratedSweep(startFreq: 200, endFreq: 2000, duration: 2.0, volume: 0.1, key: "photolysis_sweep")
    }
    
    func playPurificationChime() {
        // Ethereal crystal sound
        playGeneratedTone(frequency: 963, duration: 6.0, volume: 0.4, key: "purification_chime") // 963Hz Solfeggio
    }
    
    // MARK: - Onboarding Sounds
    
    func playServerHum() {
        // Low frequency drone/hum (60Hz + harmonics)
        playGeneratedTone(frequency: 60, duration: 60, volume: 0.1, key: "server_hum_base")
        playGeneratedNoise(duration: 60, volume: 0.05, key: "server_hum_noise")
    }
    
    func stopServerHum() {
        stopSound(key: "server_hum_base")
        stopSound(key: "server_hum_noise")
    }
    

    
    func playTypewriterLoop() {
        // Start continuous typewriter clicking sound
        stopTypewriterLoop() // Stop any existing loop
        
        // Duck background sounds
        duckBackgroundSounds()
        
        // Create repeating timer for typewriter clicks
        let timer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { [weak self] _ in
            self?.playTypewriterClick()
        }
        
        // Store timer reference
        typewriterLoopTimer = timer
    }
    
    func stopTypewriterLoop() {
        // Stop the clicking timer
        typewriterLoopTimer?.invalidate()
        typewriterLoopTimer = nil
        
        // Restore background sounds
        restoreBackgroundSounds()
    }
    
    private var typewriterLoopTimer: Timer?
    
    func duckBackgroundSounds() {
        // Lower background sounds to 30% of their original volume
        audioPlayers["server_hum_base"]?.volume = 0.03
        audioPlayers["server_hum_noise"]?.volume = 0.015
        audioPlayers["bass_c2"]?.volume = 0.045
        audioPlayers["bass_fs2"]?.volume = 0.045
        audioPlayers["pure_432"]?.volume = 0.03
    }
    
    func restoreBackgroundSounds() {
        // Restore background sounds to normal volume
        audioPlayers["server_hum_base"]?.volume = 0.1
        audioPlayers["server_hum_noise"]?.volume = 0.05
        audioPlayers["bass_c2"]?.volume = 0.15
        audioPlayers["bass_fs2"]?.volume = 0.15
        audioPlayers["pure_432"]?.volume = 0.1
    }
    
    func playDiscordantBass() {
        // Dissonant low chord (e.g., C2 + F#2)
        playGeneratedTone(frequency: 65.4, duration: 10, volume: 0.15, key: "bass_c2")
        playGeneratedTone(frequency: 92.5, duration: 10, volume: 0.15, key: "bass_fs2")
    }
    
    func stopDiscordantBass() {
        stopSound(key: "bass_c2")
        stopSound(key: "bass_fs2")
    }
    
    func playPureTone432Hz() {
        // Healing frequency
        playGeneratedTone(frequency: 432, duration: 60, volume: 0.1, key: "pure_432")
    }
    
    func stopPureTone432Hz() {
        stopSound(key: "pure_432")
    }
    
    // MARK: - Mindful Reveal Sounds
    
    func playAmbientMusic() {
        // Simulate Alpha/Theta waves (Binaural beats base) - Low frequency drone
        // 100Hz + 105Hz = 5Hz beat (Theta)
        playGeneratedTone(frequency: 100, duration: 180, volume: 0.15, key: "ambient_base")
        playGeneratedTone(frequency: 105, duration: 180, volume: 0.15, key: "ambient_beat")
    }
    
    func stopAmbientMusic() {
        stopSound(key: "ambient_base")
        stopSound(key: "ambient_beat")
    }
    
    func playBellSound() {
        // Simulate Crystal Bowl / Bell
        // Fundamental + Harmonics with long decay
        let duration = 4.0
        playGeneratedBell(frequency: 440, duration: duration, volume: 0.4, key: "bell_fund")
        playGeneratedBell(frequency: 880, duration: duration, volume: 0.2, key: "bell_h1") // Octave
        playGeneratedBell(frequency: 1320, duration: duration, volume: 0.1, key: "bell_h2") // Fifth
    }
    
    func playGongSound() {
        // Deep, resonant gong sound for distraction notification
        let duration = 5.0
        // Low fundamental
        playGeneratedBell(frequency: 110, duration: duration, volume: 0.5, key: "gong_fund")
        // Harmonics
        playGeneratedBell(frequency: 220, duration: duration, volume: 0.25, key: "gong_h1")
        playGeneratedBell(frequency: 330, duration: duration, volume: 0.15, key: "gong_h2")
        // Initial impact noise
        playGeneratedNoise(duration: 0.5, volume: 0.3, key: "gong_impact")
    }
    
    // MARK: - White Noise Background
    
    func startWhiteNoise() {
        playGeneratedNoise(duration: 180, volume: 0.1, key: "whitenoise", loop: true)
    }
    
    func stopWhiteNoise() {
        stopSound(key: "whitenoise")
    }
    
    // MARK: - Sound Generation
    
    private func playGeneratedBell(frequency: Double, duration: Double, volume: Float, key: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let sampleRate = 44100.0
            let samples = Int(sampleRate * duration)
            
            var audioData = [Int16]()
            audioData.reserveCapacity(samples)
            
            for i in 0..<samples {
                let t = Double(i) / sampleRate
                let sample = sin(2.0 * .pi * frequency * t)
                
                // Exponential decay
                let decay = exp(-3.0 * t / duration)
                
                // Attack
                let attack = min(1.0, t / 0.05)
                
                audioData.append(Int16(sample * Double(volume) * decay * attack * 32767.0))
            }
            
            DispatchQueue.main.async {
                self.playPCMData(audioData, sampleRate: sampleRate, key: key)
            }
        }
    }
    
    private func playGeneratedTone(frequency: Double, duration: Double, volume: Float, key: String, loop: Bool = false) {
        DispatchQueue.global(qos: .userInitiated).async {
            let sampleRate = 44100.0
            let amplitude = volume
            let samples = Int(sampleRate * duration)
            
            var audioData = [Int16]()
            audioData.reserveCapacity(samples)
            
            for i in 0..<samples {
                let sample = sin(2.0 * .pi * frequency * Double(i) / sampleRate)
                // Apply envelope only if NOT looping, or carefully crossfade. 
                // For simple looping tones, we might want constant amplitude or seamless loop.
                // If looping, we skip the fade out at the end to avoid "pulsing"
                let envelope: Double
                if loop {
                     // Fade in only
                     envelope = min(1.0, Double(i) / (sampleRate * 0.05))
                } else {
                     envelope = min(1.0, Double(i) / (sampleRate * 0.05)) * min(1.0, Double(samples - i) / (sampleRate * 0.05))
                }
                
                audioData.append(Int16(sample * Double(amplitude) * envelope * 32767.0))
            }
            
            DispatchQueue.main.async {
                self.playPCMData(audioData, sampleRate: sampleRate, key: key, loop: loop)
            }
        }
    }
    
    private func playGeneratedNoise(duration: Double, volume: Float, key: String, loop: Bool = false) {
        DispatchQueue.global(qos: .userInitiated).async {
            let sampleRate = 44100.0
            let samples = Int(sampleRate * duration)
            
            var audioData = [Int16]()
            audioData.reserveCapacity(samples)
            
            for _ in 0..<samples {
                let sample = Double.random(in: -1.0...1.0)
                audioData.append(Int16(sample * Double(volume) * 32767.0))
            }
            
            DispatchQueue.main.async {
                self.playPCMData(audioData, sampleRate: sampleRate, key: key, loop: loop)
            }
        }
    }
    
    private func playGeneratedSweep(startFreq: Double, endFreq: Double, duration: Double, volume: Float, key: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let sampleRate = 44100.0
            let samples = Int(sampleRate * duration)
            
            var audioData = [Int16]()
            audioData.reserveCapacity(samples)
            
            for i in 0..<samples {
                let progress = Double(i) / Double(samples)
                let frequency = startFreq + (endFreq - startFreq) * progress
                let sample = sin(2.0 * .pi * frequency * Double(i) / sampleRate)
                let envelope = min(1.0, Double(i) / (sampleRate * 0.05)) * min(1.0, Double(samples - i) / (sampleRate * 0.05))
                audioData.append(Int16(sample * Double(volume) * envelope * 32767.0))
            }
            
            DispatchQueue.main.async {
                self.playPCMData(audioData, sampleRate: sampleRate, key: key)
            }
        }
    }
    
    private func playPCMData(_ data: [Int16], sampleRate: Double, key: String, loop: Bool = false) {
        // Create WAV data with header
        let wavData = createWAVData(from: data, sampleRate: sampleRate)
        
        do {
            let player = try AVAudioPlayer(data: wavData)
            player.numberOfLoops = loop ? -1 : 0
            player.prepareToPlay()
            player.play()
            
            audioPlayers[key] = player
            
            if !loop {
                DispatchQueue.main.asyncAfter(deadline: .now() + player.duration) {
                    self.audioPlayers.removeValue(forKey: key)
                }
            }
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
    
    private func createWAVData(from samples: [Int16], sampleRate: Double) -> Data {
        let numSamples = samples.count
        let numChannels = 1
        let bitDepth = 16
        
        let totalDataSize = numSamples * numChannels * bitDepth / 8
        let totalFileSize = 36 + totalDataSize
        
        var data = Data()
        
        // RIFF chunk
        data.append("RIFF".data(using: .ascii)!)
        data.append(intToByteArray(totalFileSize, bytes: 4))
        data.append("WAVE".data(using: .ascii)!)
        
        // fmt chunk
        data.append("fmt ".data(using: .ascii)!)
        data.append(intToByteArray(16, bytes: 4)) // Subchunk1Size
        data.append(intToByteArray(1, bytes: 2))  // AudioFormat (1 = PCM)
        data.append(intToByteArray(numChannels, bytes: 2))
        data.append(intToByteArray(Int(sampleRate), bytes: 4))
        data.append(intToByteArray(Int(sampleRate) * numChannels * bitDepth / 8, bytes: 4)) // ByteRate
        data.append(intToByteArray(numChannels * bitDepth / 8, bytes: 2)) // BlockAlign
        data.append(intToByteArray(bitDepth, bytes: 2))
        
        // data chunk
        data.append("data".data(using: .ascii)!)
        data.append(intToByteArray(totalDataSize, bytes: 4))
        
        // Audio samples
        for sample in samples {
            data.append(intToByteArray(Int(sample), bytes: 2))
        }
        
        return data
    }
    
    private func intToByteArray(_ value: Int, bytes: Int) -> Data {
        var val = value
        return Data(bytes: &val, count: bytes)
    }
    
    func stopSound(key: String) {
        audioPlayers[key]?.stop()
        audioPlayers.removeValue(forKey: key)
    }
    
    func stopAllSounds() {
        audioPlayers.values.forEach { $0.stop() }
        audioPlayers.removeAll()
    }
    // MARK: - Meditation Sounds (CALM Feature)
    
    // MARK: - Meditation Sounds (CALM Feature)
    
    // Helper method to find sound files in various locations
    private func findSoundURL(for filename: String) -> URL? {
        let bundle = Bundle.main
        let nsName = filename as NSString
        
        // Strategy 1: Exact match (Root or flattened)
        if let url = bundle.url(forResource: filename, withExtension: nil) {
            print("✅ [SoundManager] Found by exact match: \(filename)")
            return url
        }
        
        // Strategy 2: Separate extension
        let name = nsName.deletingPathExtension
        let ext = nsName.pathExtension
        if let url = bundle.url(forResource: name, withExtension: ext) {
            print("✅ [SoundManager] Found by name+ext: \(name).\(ext)")
            return url
        }
        
        // Strategy 3: If filename has path components, try to respect them (Folder Reference)
        if filename.contains("/") {
            let lastComponent = nsName.lastPathComponent
            let subdir = nsName.deletingLastPathComponent
            
            // Try with extension in name
            if let url = bundle.url(forResource: lastComponent, withExtension: nil, subdirectory: subdir) {
                print("✅ [SoundManager] Found in subdir (full name): \(subdir)/\(lastComponent)")
                return url
            }
            
            // Try separating extension
            let nameWithoutExt = (lastComponent as NSString).deletingPathExtension
            let fileExt = (lastComponent as NSString).pathExtension
            if let url = bundle.url(forResource: nameWithoutExt, withExtension: fileExt, subdirectory: subdir) {
                print("✅ [SoundManager] Found in subdir (split): \(subdir)/\(nameWithoutExt).\(fileExt)")
                return url
            }
        }
        
        // Strategy 4: Flattened lookup (ignore directory prefix in input) - CRITICAL for Groups
        let lastComponent = nsName.lastPathComponent
        if let url = bundle.url(forResource: lastComponent, withExtension: nil) {
            print("✅ [SoundManager] Found flattened (full name): \(lastComponent)")
            return url
        }
        
        // Strategy 5: Flattened lookup with separated extension
        let nameWithoutExt = (lastComponent as NSString).deletingPathExtension
        let fileExt = (lastComponent as NSString).pathExtension
        if let url = bundle.url(forResource: nameWithoutExt, withExtension: fileExt) {
            print("✅ [SoundManager] Found flattened (split): \(nameWithoutExt).\(fileExt)")
            return url
        }
        
        // Strategy 6: Search in common subdirectories (fallback)
        let commonSubdirs = ["会员音乐", "冥想音乐", "Sounds", "Audio"]
        for subdir in commonSubdirs {
            if let url = bundle.url(forResource: lastComponent, withExtension: nil, subdirectory: subdir) {
                print("✅ [SoundManager] Found in common subdir: \(subdir)/\(lastComponent)")
                return url
            }
            if let url = bundle.url(forResource: nameWithoutExt, withExtension: fileExt, subdirectory: subdir) {
                print("✅ [SoundManager] Found in common subdir (split): \(subdir)/\(nameWithoutExt).\(fileExt)")
                return url
            }
        }
        
        return nil
    }
    
    func playMeditationMusic(named filename: String) {
        print("🎵 [SoundManager] playMeditationMusic called with: \(filename)")
        
        guard isSoundEnabled else {
            print("⚠️ [SoundManager] Sound is disabled, skipping playback")
            return
        }
        
        // Configure audio session for meditation (plays even in Silent Mode)
        setupAudioSession(forMeditation: true)
        
        // Stop background music when playing meditation music
        stopAmbientBackgroundMusic()
        
        // Stop any existing meditation sounds
        stopMeditationSounds()
        
        // Find the sound file
        guard let url = findSoundURL(for: filename) else {
            print("❌ [SoundManager] Could not find sound file: \(filename)")
            return
        }
        
        print("✅ [SoundManager] Found file at: \(url.path)")
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1 // Infinite loop
            player.prepareToPlay()
            player.play()
            player.volume = 0.5 // Default volume
            
            audioPlayers["meditation_active_track"] = player
            print("✅ [SoundManager] Successfully started playing: \(filename)")
        } catch {
            print("❌ [SoundManager] Failed to play meditation music: \(error)")
        }
    }
    
    func stopMeditationSounds() {
        stopSound(key: "meditation_active_track")
        // Restore ambient audio session for background music
        setupAudioSession(forMeditation: false)
    }
    
    func setMeditationVolume(_ volume: Float) {
        if let player = audioPlayers["meditation_active_track"] {
            player.volume = volume
        }
    }
    
    // MARK: - Ambient Background Music
    
    /// Start playing ambient background music (Soul track)
    func startAmbientBackgroundMusic() {
        guard isSoundEnabled else { return }
        
        // Don't start if already playing
        if audioPlayers["ambient_background"] != nil {
            return
        }
        
        // Try loading the file (extension is part of filename)
        guard let url = Bundle.main.url(forResource: "灵魂", withExtension: "mp3") else {
            print("❌ Could not find ambient background music file: 灵魂.mp3")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1 // Infinite loop
            player.prepareToPlay()
            player.volume = 0.25 // Subtle background volume
            player.play()
            
            audioPlayers["ambient_background"] = player
            print("🎵 Started ambient background music")
        } catch {
            print("❌ Failed to play ambient background music: \(error)")
        }
    }
    
    /// Stop ambient background music
    func stopAmbientBackgroundMusic() {
        if let player = audioPlayers["ambient_background"] {
            player.stop()
            audioPlayers.removeValue(forKey: "ambient_background")
            print("🔇 Stopped ambient background music")
        }
    }
    
    /// Set ambient background music volume
    func setAmbientVolume(_ volume: Float) {
        if let player = audioPlayers["ambient_background"] {
            player.volume = volume
        }
    }
    
    /// Check if ambient music is playing
    var isAmbientMusicPlaying: Bool {
        return audioPlayers["ambient_background"]?.isPlaying ?? false
    }
}

