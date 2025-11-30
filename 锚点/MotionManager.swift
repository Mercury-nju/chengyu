import CoreMotion
import SwiftUI
import Combine

class MotionManager: ObservableObject {
    private var motionManager: CMMotionManager
    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0
    
    init() {
        self.motionManager = CMMotionManager()
        self.motionManager.deviceMotionUpdateInterval = 1.0 / 60.0 // 60 Hz
        startUpdates()
    }
    
    func startUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (data, error) in
                guard let data = data else { return }
                withAnimation(.linear(duration: 0.1)) {
                    self?.pitch = data.attitude.pitch
                    self?.roll = data.attitude.roll
                }
            }
        }
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    deinit {
        stopUpdates()
    }
}
