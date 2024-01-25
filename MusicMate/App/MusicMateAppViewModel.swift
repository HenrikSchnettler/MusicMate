//
//  MusicMateAppViewModel.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 16.01.24.
//

import Foundation
import Combine

@MainActor // Ensures that all updates to this class are performed on the main UI thread to prevent UI-related issues.
class MusicMateAppViewModel: ObservableObject {
    // NetworkMonitor instance for monitoring network connectivity status.
    var networkMonitor: NetworkMonitor

    // MusicKitManager instance for managing interactions with the MusicKit service.
    var musicKitManager: MusicKitManager

    // A set to hold AnyCancellable tokens for Combine subscriptions, preventing premature deallocation.
    private var cancellables = Set<AnyCancellable>()
    
    @Published var setupComplete: Bool = false  // Tracks whether initial app setup and authentication are complete.
    @Published var userIsAuthorized: Bool = false  // Tracks whether the user is authorized to access MusicKit services.
    @Published var userCanPlayContent: Bool = false  // Indicates if the user can play content from the music catalog.
    @Published var userIsEligableForOffer: Bool = false  // Indicates eligibility for a subscription offer to the music service.
    
    // Initializes the ViewModel with required services.
    init(networkMonitor: NetworkMonitor, musicKitManager: MusicKitManager = .shared) {
        self.networkMonitor = networkMonitor
        self.musicKitManager = musicKitManager
        
        // Sets up Combine subscriptions to monitor changes in authentication and subscription status.
        setupSubscriptions()
    }
    
    // Sets up Combine subscriptions to react to changes from the MusicKitManager.
    private func setupSubscriptions() {
        // Subscription to track completion of initial authentication with MusicKit.
        musicKitManager.$initalAuthentificationComplete
            .receive(on: DispatchQueue.main)  // Ensures the subscription callback is executed on the main thread.
            .sink { [weak self] complete in
                self?.updateStates()  // Updates the ViewModel's state based on changes.
            }
            .store(in: &cancellables)  // Stores the subscription to prevent deallocation.

        // Subscription to track changes in the music subscription status.
        musicKitManager.$musicSubscription
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateStates()
            }
            .store(in: &cancellables)

        // Subscription to track changes in the authorization status for using MusicKit.
        musicKitManager.$isAuthorizedForMusicKit
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateStates()
            }
            .store(in: &cancellables)
    }

    // Updates the state properties of the ViewModel based on the latest data from MusicKitManager.
    private func updateStates() {
        // Update setupComplete based on initial authentication and subscription presence.
        setupComplete = musicKitManager.initalAuthentificationComplete && musicKitManager.musicSubscription != nil
        
        // Update userIsAuthorized based on MusicKit authorization status.
        userIsAuthorized = musicKitManager.isAuthorizedForMusicKit
        
        // Update userCanPlayContent based on the user's ability to play catalog content.
        userCanPlayContent = musicKitManager.musicSubscription?.canPlayCatalogContent ?? false
        
        // Update userIsEligableForOffer based on the user's eligibility for a subscription offer.
        userIsEligableForOffer = !(musicKitManager.musicSubscription?.canPlayCatalogContent ?? false) && musicKitManager.musicSubscription?.canBecomeSubscriber ?? false
    }
}
