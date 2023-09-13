//
//  ContentView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 20.04.23.
//

import SwiftUI
import CoreData

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
    
    @Environment(\.managedObjectContext) private var viewContext  // Core Data context for any database operations.
    
    // Tracks which tab is currently selected. Default is the home tab.
    @State var selection: Tabs = .home
    
    // Reference to the network monitor to check the network status.
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    // State variable to track if the user info sheet should be presented.
    @State var showUserInfoSheet: Bool = false
    
    init() {
        // Initialization logic that is executed when an instance of MainView is created. Currently, it's empty.
    }
    
    var body: some View {
        NavigationView{
            Group{
                // Display OfflineView if there's no network connection.
                if networkMonitor.networkStatus == .disconnected
                {
                    OfflineView()
                        .tag(Tabs.home)
                        .onAppear(){
                            // Actions to be performed when OfflineView appears.
                        }
                }
                // If there's a network connection, display ExploreNowView.
                else {
                    ExploreNowView()
                        .tag(Tabs.home)
                        .onAppear(){
                            // Actions to be performed when ExploreNowView appears.
                        }
                }
            }
            .navigationBarTitle(selection.localizedString.capitalized, displayMode: .automatic) // Set the navigation bar title based on the currently selected tab.
            .navigationBarItems(trailing:
                HStack{
                    // Trailing navigation bar items. Currently, it's empty.
                }
            )
            .font(Font.headline) // Set the default font for elements in this view.
            .accentColor(Color.themeAccent) // Set the accent color for the view.
        }
        .sheet(isPresented: $showUserInfoSheet, content: {
            // Content to be shown in the sheet when `showUserInfoSheet` is true. Currently, it's empty.
        })
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .preferredColorScheme(.dark)
    }
}
