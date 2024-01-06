//
//  MusicMateApp.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 20.04.23.
//

import SwiftUI
import MusicKit

@main
struct MusicMateApp: App {
    let persistenceController = PersistenceController.shared
    //reference to the singleton instance of MusicKitManager class
    @StateObject private var musicKitManager = MusicKitManager.shared
    //reference to the singleton instance of networkMonitor class
    @StateObject private var networkMonitor = NetworkMonitor.shared

    var body: some Scene {
        WindowGroup {
            if musicKitManager.initalAuthentificationComplete && musicKitManager.musicSubscription != nil{
                //initial authentification is complete after start of the app
                if musicKitManager.isAuthorizedForMusicKit{
                    if(musicKitManager.musicSubscription?.canPlayCatalogContent ?? false)
                    {
                        //user gave permission to access apple music so MainView can be shown
                        MainView()
                            .environmentObject(musicKitManager)
                            .environmentObject(networkMonitor)
                            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                            .onAppear(){
                            }
                    }
                    else if(!(musicKitManager.musicSubscription?.canPlayCatalogContent ?? false) && musicKitManager.musicSubscription?.canBecomeSubscriber ?? false)
                    {
                        //if user is logged in into his icloud account give him a offer to subscribe to apple music for the app to function proberly
                        SubscriptionOfferView()
                    }
                    else{
                        //When user isnt logged in into an icloud acount he should be notified
                        LoginInfoView()
                    }
                }
                else{
                    //user didnt gave permission so he cant access functionality of the app. He should be notified that he needs to give access for the app to work. The app could close after that.
                    ViewOfShame()
                        .environmentObject(musicKitManager)
                }
            }
            else{
                //if initial authentification isnt made yet MainView shouldnt be visible instead a loading screen
                LoadingView()
                    .environmentObject(musicKitManager)
            }
        }
    }
}
