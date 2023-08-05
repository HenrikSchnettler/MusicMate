//
//  ContentView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 20.04.23.
//

import SwiftUI
import CoreData

//Returns the localized value for Tabname
enum Tabs: String{
    case home = "appname"
    case explorelater = "Explore Later"
    
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
    
    @Environment(\.managedObjectContext) private var viewContext
    //Holds the current tab selection (Home by default)
    @State var selection: Tabs = .home
    //NetworkMonitor object
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    //Holds the current state if the UserInfoSheet is shown (false by default)
    @State var showUserInfoSheet: Bool = false
    
    init() {
        //Logic which fires if the user enters the app
    }
    
    var body : some View{
        NavigationView{
            TabView(selection: $selection){
                //Overview Tab
                if networkMonitor.networkStatus == .disconnected
                {
                    OfflineView()
                        .tag(Tabs.home)
                        .onAppear(){
                            
                        }
                        .tabItem {
                            Text("Explore Now")
                            Image(systemName: "play.square.stack")
                            Color.themeAccent
                        }
                }
                else{
                    ExploreNowView()
                        .tag(Tabs.home)
                        .onAppear(){
                            
                        }
                        .tabItem {
                            Text("Explore Now")
                            Image(systemName: "play.square.stack")
                            Color.themeAccent
                        }
                }
                
                //Tab for the explore Playlist
                ExploreLaterView()
                    .tag(Tabs.explorelater)
                    .onAppear(){
                    
                    }
            
                    .tabItem {
                        Text("Explore Later")
                        Image(systemName: "list.bullet.rectangle.fill")
                        Color.themeAccent
                    }
            }
            .onAppear(){
                
            }
            .navigationBarTitle(selection.localizedString.capitalized, displayMode: .automatic)
            .navigationBarItems(trailing:
                                    ZStack{
                                        Button(action: {
                                            showUserInfoSheet.toggle()
                                        }, label: {
                                            ZStack{
                                                Circle()
                                                    .foregroundColor(Color.themeForeground )
                                                    .frame(width: 42, height: 42, alignment: .center)
                                                Text("HS")
                                                    .foregroundColor(Color.themeBackground)
                                            }
                                        })
                                        
                                    }
            )
            .font(Font.headline)
            .accentColor(Color.themeAccent)
        
        }
        .sheet(isPresented: $showUserInfoSheet, content: {
            
            
        })
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .preferredColorScheme(.dark)
    }
}
