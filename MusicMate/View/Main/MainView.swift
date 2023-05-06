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
    
    var localizedString: String {
        switch self {
            case .home:
                return NSLocalizedString("appname", comment: "")
        }
    }
}


struct MainView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    //Holds the current tab selection (Home by default)
    @State var selection: Tabs = .home
    
    //Holds the current state if the UserInfoSheet is shown (false by default)
    @State var showUserInfoSheet: Bool = false
    
    init() {
        //Logic which fires if the user enters the app
    }
    
    var body : some View{
        NavigationView{
            TabView(selection: $selection){
                    //Overview Tab
                    HomeView()
                    .tag(Tabs.home)
                    .onAppear(){
                        
                    }
                
                    .tabItem {
                        Text("overview")
                        Image(systemName: "house")
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
