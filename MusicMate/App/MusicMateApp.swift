//
//  MusicMateApp.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 20.04.23.
//

import SwiftUI
import MusicKit
import AVFoundation
import AVKit

// MusicMateApp is the root structure of the SwiftUI application, conforming to the App protocol.
// It defines the entry point of the application and sets up the initial view hierarchy.
@main
struct MusicMateApp: App {
    // Shared instance of PersistenceController for core data management across the app.
    let persistenceController = PersistenceController.shared
    
    // StateObject 'vm' is an instance of MusicMateAppViewModel used to manage app-wide state like user authentication.
    @StateObject private var vm = MusicMateAppViewModel(networkMonitor: NetworkMonitor(), musicKitManager: MusicKitManager.shared)
    
    var body: some Scene {
        WindowGroup {
            if vm.setupComplete {
                // Checks if the initial setup/authentication process is complete.
                if vm.userIsAuthorized {
                    // Further checks if the user authorized to play apple music catalog content.
                    if(vm.userCanPlayContent) {
                        // If the user has granted permission to access Apple Music, the MainView is presented.
                        MainView(vm: MainViewModel(networkMonitor: vm.networkMonitor), audioPlayer: AudioPlayer(player: AVQueuePlayer()))
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                            // Provides the MainView with access to the managed object context for CoreData operations.
                    } else if(vm.userIsEligableForOffer) {
                        // Presents a subscription offer view if the user is eligible for an Apple Music subscription offer.
                        SubscriptionOfferView()
                    } else {
                        // Presents a login information view if the user is not logged into an iCloud account.
                        LoginInfoView()
                    }
                } else {
                    // Presents a view if the user hasn't granted necessary permissions.
                    ViewOfShame()
                }
            } else {
                // Displays a loading view while the app is completing its initial setup/authentication process.
                LoadingView()
            }
        }
    }
}
