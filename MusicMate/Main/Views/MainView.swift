//
//  ContentView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 20.04.23.
//

import SwiftUI
import CoreData

// Enum representing the tabs in the app. Each tab's rawValue is a string key that can be localized.
enum Tabs: String{
    case home = "appname"
    case explorelater = "Explore Later"
    
    // Retrieve the localized string for each tab. This is useful for supporting multiple languages.
    var localizedString: String {
        switch self {
            case .home:
                return NSLocalizedString("appname", comment: "")
            case .explorelater:
                return NSLocalizedString("Explore Later", comment: "")
        }
    }
}

struct MainView: View {
    // 'vm' is an instance of MainViewModel, used to manage the data and logic for the main interface.
    @StateObject var vm: MainViewModel
    
    // 'audioPlayer' is an instance of AudioPlayer, responsible for managing audio playback within the app.
    @StateObject var audioPlayer: AudioPlayer
    
    // The initializer for MainView, requiring instances of MainViewModel and AudioPlayer.
    
    var body: some View {
        NavigationView {
            // Group acts as a container that doesn’t add any additional UI elements but groups the content.
            Group {
                // Displays OfflineView when there's no network connection.
                if !vm.isConnectedToNetwork {
                    OfflineView()
                        .tag(Tabs.home)
                } else {
                    // ExploreNowView is presented when there's network connectivity.
                    ExploreNowView(vm: ExploreNowViewModel(audioPlayer: audioPlayer, musicKitManager: MusicKitManager.shared))
                        .tag(Tabs.home) // Similarly, assigns a tag for navigation or tabbed interface.
                }
            }
            .navigationBarTitle(vm.selection.localizedString.capitalized, displayMode: .automatic) // Sets the navigation bar title dynamically based on the viewModel's selection.
            .font(Font.headline) // Applies a headline font style to the text within this navigation view.
            .accentColor(Color.themeAccent) // Sets the accent color for this view.
        }
    }
}
