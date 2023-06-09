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
    let musicKitManager = MusicKitManager()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear(){
                    //every time the app is started full authorization should be made
                    musicKitManager.performFullAuthorization()
                }
        }
    }
}
