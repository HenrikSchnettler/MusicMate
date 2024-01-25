//
//  MockNetworkMonitor.swift
//  MusicMateTests
//
//  Created by Henrik Schnettler on 16.01.24.
//

import Foundation
import Network
import Combine

@testable import MusicMate

// Mock NetworkMonitor
class MockNetworkMonitor: NetworkMonitor {
    var mockNetworkStatus: NetworkMonitor.NetworkStatus = .disconnected

    override var networkStatus: NetworkMonitor.NetworkStatus {
        get {
            return mockNetworkStatus
        }
        set {
            mockNetworkStatus = newValue
            self.didChange?(mockNetworkStatus)
        }
    }
}
