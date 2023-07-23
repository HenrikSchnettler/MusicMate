//
//  MotionManager.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 12.07.23.
//

import CoreMotion
import Combine

class MotionManager: ObservableObject {
    private let motionManager: CMMotionManager
    private var timer: Timer? = nil
    private let updateInterval: TimeInterval = 0.1

    @Published var roll: Double = 0
    @Published var pitch: Double = 0
    @Published var yaw: Double = 0
    
    @Published var gyroscopeAvailability: Bool = true
    
    init() {
        motionManager = CMMotionManager()
        motionManager.deviceMotionUpdateInterval = updateInterval
    }
    
    func startUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.startDeviceMotionUpdates(to: .main) { (data, error) in
                guard let data = data else {
                    return
                }
                DispatchQueue.main.async {
                    self.roll = data.attitude.roll
                    self.pitch = data.attitude.pitch
                    self.yaw = data.attitude.yaw
                }
            }
        } else {
            gyroscopeAvailability = false
        }
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}
