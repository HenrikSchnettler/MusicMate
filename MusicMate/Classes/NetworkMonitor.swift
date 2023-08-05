//
//  NetworkMonitor.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 05.08.23.
//

import Network
import Combine

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    var monitor: NWPathMonitor?
    var isMonitoring = false
    var didChange: ((NetworkStatus) -> Void)?

    @Published var networkStatus: NetworkStatus = .disconnected

    enum NetworkStatus {
        case wifi
        case cellular
        case disconnected
    }

    private init() {
        monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "Monitor")
        monitor?.start(queue: queue)
        startMonitoring()
    }

    func startMonitoring() {
        guard !isMonitoring else { return }

        monitor?.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if path.usesInterfaceType(.wifi) {
                    self.networkStatus = .wifi
                } else if path.usesInterfaceType(.cellular) {
                    self.networkStatus = .cellular
                } else {
                    self.networkStatus = .disconnected
                }
                self.didChange?(self.networkStatus)
            }
        }

        isMonitoring = true
    }

    func stopMonitoring() {
        guard isMonitoring, let monitor = monitor else { return }
        monitor.cancel()
        isMonitoring = false
        self.monitor = nil
    }
}
