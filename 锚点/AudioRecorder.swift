import SwiftUI
import AVFoundation
import Combine

class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var amplitude: Float = 0.0
    @Published var recordingDuration: TimeInterval = 0
    @Published var hasPermission = false
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    private var recordingURL: URL?
    
    override init() {
        super.init()
        // checkPermission() // Moved to onAppear to prevent initialization hang
    }
    
    func checkPermission() {
        #if os(iOS)
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                self?.hasPermission = granted
            }
        }
        #endif
    }
    

    func startRecording() {
        guard hasPermission else {
            checkPermission()
            return
        }
        
        // 1. Immediate UI Feedback (Optimistic)
        self.isRecording = true
        self.recordingDuration = 0
        self.amplitude = 0
        
        // Start timer immediately for duration and metering
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.recordingDuration += 0.05
            
            if let recorder = self.audioRecorder {
                recorder.updateMeters()
                // Normalize -160...0 to 0...1
                let power = recorder.averagePower(forChannel: 0)
                self.amplitude = max(0, min(1, (power + 50) / 50)) // Focus on top 50dB
            }
        }
        
        // 2. Background Work
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Stop sounds on main thread to ensure thread safety
            DispatchQueue.main.sync {
                SoundManager.shared.stopAllSounds()
            }
            
            #if os(iOS)
            let audioSession = AVAudioSession.sharedInstance()
            
            do {
                // Deactivate current session (Ambient)
                try audioSession.setActive(false)
                
                // Configure new session (PlayAndRecord)
                try audioSession.setCategory(.playAndRecord, mode: .default)
                try audioSession.setActive(true)
                
                // Create recording URL
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let url = documentsPath.appendingPathComponent("voice_\(Date().timeIntervalSince1970).wav")
                
                // Configure recorder - Use LinearPCM for better Simulator compatibility
                let settings: [String: Any] = [
                    AVFormatIDKey: Int(kAudioFormatLinearPCM),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 1,
                    AVLinearPCMBitDepthKey: 16,
                    AVLinearPCMIsBigEndianKey: false,
                    AVLinearPCMIsFloatKey: false,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
                
                let recorder = try AVAudioRecorder(url: url, settings: settings)
                recorder.delegate = self
                recorder.isMeteringEnabled = true // Enable Metering
                recorder.prepareToRecord()
                
                if recorder.record() {
                    DispatchQueue.main.async {
                        self.recordingURL = url
                        self.audioRecorder = recorder
                    }
                } else {
                    print("Failed to start recording: recorder.record() returned false")
                    // Revert UI on failure
                    DispatchQueue.main.async {
                        self.isRecording = false
                        self.timer?.invalidate()
                        self.timer = nil
                    }
                }
                
            } catch {
                print("Failed to start recording: \(error.localizedDescription)")
                // Revert UI on failure
                DispatchQueue.main.async {
                    self.isRecording = false
                    self.timer?.invalidate()
                    self.timer = nil
                }
            }
            #endif
        }
    }
    
    func stopRecording() -> URL? {
        #if os(iOS)
        audioRecorder?.stop()
        timer?.invalidate()
        timer = nil
        isRecording = false
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            // Resume SoundManager session
            DispatchQueue.main.async {
                SoundManager.shared.resumeAfterRecording()
            }
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
        
        return recordingURL
        #else
        return nil
        #endif
    }
    
    func playRecording(url: URL) {
        #if os(iOS)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Failed to play recording: \(error.localizedDescription)")
        }
        #endif
    }
    
    deinit {
        timer?.invalidate()
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording failed")
        }
    }
}
