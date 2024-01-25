//
//  MainViewModel.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 08.01.24.
//

import Foundation
import Combine

class MainViewModel: ObservableObject {
    // Published property 'selection' holds the current tab selection, defaulting to 'home'.
    @Published var selection: Tabs = .home
    
    @Published var isConnectedToNetwork: Bool = true
    
    // A set to hold AnyCancellable tokens for Combine subscriptions, preventing premature deallocation.
    private var cancellables = Set<AnyCancellable>()

    // 'networkMonitor' is a private instance of NetworkMonitor, used to observe network connectivity changes.
    private var networkMonitor: NetworkMonitor
    
    // Initializer for MainViewModel, requiring an instance of NetworkMonitor.
    init(networkMonitor: NetworkMonitor) {
        self.networkMonitor = networkMonitor
        setupNetworkMonitor()
    }
    
    // Setting up the subscription for binding.
    private func setupNetworkMonitor() {
        // Subscribe to changes in the network status.
        networkMonitor.$networkStatus
            .receive(on: RunLoop.main)
            .map { status in
                // Transform network status to a boolean indicating connectivity.
                return status != .disconnected
            }
            .assign(to: \.isConnectedToNetwork, on: self)
            .store(in: &cancellables)
    }
}
