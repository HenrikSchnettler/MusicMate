//
//  NetworkMonitor.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 05.08.23.
//

import Network
import Combine

//A class responsible for monitoring the network status.
class NetworkMonitor: ObservableObject {

    // A shared instance of the NetworkMonitor class to avoid multiple instances of network monitoring.
    static let shared = NetworkMonitor()

    // A monitor that checks the status of the network.
    var monitor: NWPathMonitor?

    // A flag to keep track if monitoring is ongoing.
    var isMonitoring = false

    // A callback closure that gets triggered every time the network status changes.
    var didChange: ((NetworkStatus) -> Void)?

    // The current status of the network.
    @Published var networkStatus: NetworkStatus = .disconnected

    // Enumeration for the various network statuses.
    enum NetworkStatus {
        case wifi
        case cellular
        case disconnected
    }

    // Private initializer to ensure only one instance of NetworkMonitor is created.
    private init() {
        // Initialize the NWPathMonitor
        monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "Monitor")
        
        // Start the network monitor on the created dispatch queue.
        monitor?.start(queue: queue)
        startMonitoring()
    }

    /// Start monitoring network changes.
    func startMonitoring() {
        // Ensure monitoring isn't already active.
        guard !isMonitoring else { return }

        // Whenever there's a change in network path, this block will be triggered.
        monitor?.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                // Determine network status based on the updated path.
                if path.usesInterfaceType(.wifi) {
                    self.networkStatus = .wifi
                } else if path.usesInterfaceType(.cellular) {
                    self.networkStatus = .cellular
                } else {
                    self.networkStatus = .disconnected
                }

                // Call the `didChange` closure with the new network status.
                self.didChange?(self.networkStatus)
            }
        }

        isMonitoring = true
    }

    // Stop monitoring network changes.
    func stopMonitoring() {
        // Ensure monitoring is active and there's an active monitor instance.
        guard isMonitoring, let monitor = monitor else { return }

        // Cancel the network monitor.
        monitor.cancel()
        isMonitoring = false

        // Nullify the monitor to release resources.
        self.monitor = nil
    }
}

