//
//  MusicKitManager.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 03.06.23.
//

import Foundation
import MusicKit
import StoreKit
import Combine

@MainActor
class MusicKitManager: ObservableObject {
    //reference to the singleton is reachable over the static constant of the class
    static let shared = MusicKitManager()
    
    //Keychain service in initalized
    private let keychainService = KeychainService()
    
    //The following variables notify the view if they update to it can refresh
    //@Published var authorizationStatus = SKCloudServiceAuthorizationStatus.notDetermined
    @Published var initalAuthentificationComplete = false
    @Published var isAuthorizedForMusicKit: Bool = false
    @Published var musicSubscription: MusicSubscription?
    
    //init of class
    private init() {
        Task{
            await self.performInitialAuthorization()
            self.initalAuthentificationComplete = true
        }
    }
    
    //Initial authorization
    private func performInitialAuthorization() async -> Void {
        await self.requestMusicAuthorization()
        self.getUserCapabilities()
    }
    
    //request apple music authorization
    private func requestMusicAuthorization() async {
        let authorizationStatus = await MusicAuthorization.request()
        if authorizationStatus == .authorized {
            self.isAuthorizedForMusicKit = true
        } else {
            self.isAuthorizedForMusicKit = false
        }
    }
    
    //task which subscribes to the subscription capabilities since its first calles and stays active
    private func getUserCapabilities() {
        Task{
            for await subscription in MusicSubscription.subscriptionUpdates {
                self.musicSubscription = subscription
            }
        }
    }
}
