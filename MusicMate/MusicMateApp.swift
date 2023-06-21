//
//  MusicMateApp.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 20.04.23.
//

import SwiftUI

@main
struct MusicMateApp: App {
    let persistenceController = PersistenceController.shared
    //reference to the singleton instance of MusicKitManager class
    @StateObject private var musicKitManager = MusicKitManager.shared

    var body: some Scene {
        WindowGroup {
            if musicKitManager.initalAuthentificationComplete{
                //initial authentification is complete after start of the app
                if musicKitManager.appleMusicAccessGrantedByUser{
                    //user gave permission to access apple music so MainView can be shown
                    MainView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .onAppear(){
                        }
                }
                else{
                    //user didnt gave permission so he cant access functionality of the app. He should be notified that he needs to give access for the app to work. The app could close after that.
                    ViewOfShame()
                }
            }
            else{
                //if initial authentification isnt made yet MainView shouldnt be visible instead a loading screen
                LoadingView()
            }
        }
    }
}
