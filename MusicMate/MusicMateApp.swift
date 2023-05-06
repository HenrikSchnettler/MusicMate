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

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
