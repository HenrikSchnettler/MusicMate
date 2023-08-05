//
//  HomeView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 27.04.23.
//

import SwiftUI
import MusicKit
import AVFoundation
import AVKit

struct ExploreNowView: View {
    //describes the state the app is in
    @Environment(\.scenePhase) var scenePhase
    //describes the current color sheme of the app
    @Environment(\.colorScheme) var colorScheme
    //MusicKitManager object
    @EnvironmentObject var musicKitManager: MusicKitManager
    //the personal station of the user
    @State var personalStation: Station?
    //object of class which connects to the player which can stream the preview of the songs
    @StateObject var audioPlayer = AudioPlayer(player: AVQueuePlayer())
    
    @State private var showSheet = false
    
    let confirmDestinations = ["Library"]
    @State var destinationSelection = "Library"
    
    @ViewBuilder
    private var backgroundView: some View {
        if audioPlayer.queueCount == 0 {
            LinearGradient(gradient: Gradient(colors: [Color.themeAccent, Color.themeTertiary, Color.themeSecondary]), startPoint: .leading, endPoint: .trailing)
        } else if let staticArtwork = audioPlayer.queue.first?.AppleMusicExtendedAlbum?.attributes.artwork.url, audioPlayer.queueCount > 0 {
            AsyncImage(url: URL(string: String(staticArtwork).replacingOccurrences(of: "{w}", with: "150").replacingOccurrences(of: "{h}", with: "40").replacingOccurrences(of: "{f}", with: "png"))) { image in
                // This closure is called once the image is downloaded.
                image
                    .shadow(radius: 8)
            } placeholder: {
                
            }
            .frame(width: 150, height: 40)
        }
    }
    
    var body: some View {
        GeometryReader { wholeViewGeometry in
            VStack{
                Group{
                    if audioPlayer.queueCount > 0
                    {
                        CardStackView(destinationSelection: $destinationSelection)
                            .environmentObject(audioPlayer)
                            .onAppear {
                                
                            }
                    }
                    else{
                        //if personal station isnt loaded yet there should be a loading animation
                        SkeletonCardView()
                    }
                }
                //Spacer()
                /*
                 HStack(){
                 Picker(selection: $selection, label: Text("Target:")) {
                 ForEach(confirmDestinations, id: \.self) {
                 Text($0)
                 }
                 }
                 .accentColor(Color.white)
                 .frame(width: 150, height: 40)
                 .cornerRadius(16)
                 .background(
                 RoundedRectangle(cornerRadius: 16)
                 .stroke(Color.white.opacity(0.3), lineWidth: 4)
                 )
                 .background(
                 backgroundView
                 .overlay(
                 VisualEffectView(effect: UIBlurEffect(style: .light))
                 .cornerRadius(16)
                 )
                 .cornerRadius(16)
                 )
                 .shadow(radius: 40)
                 //Spacer()
                 }
                 .padding(.bottom)
                 */
                
                Picker(selection: $destinationSelection, label: Text("Target:")) {
                    ForEach(confirmDestinations, id: \.self) {
                        Text($0)
                    }
                }
                //.accentColor(Color.white)
                .frame(width: 150, height: 40)
                .background(
                    Color(UIColor.secondarySystemBackground)
                )
                .cornerRadius(16)
                .shadow(radius: 10)
                
                RoundedRectangle(cornerRadius: 5)
                    .fill(.gray)
                    .frame(width: 75, height: 5)
                    .padding(.top,10)
                    .padding(.bottom,10)
                    .gesture(
                        DragGesture(minimumDistance: 30, coordinateSpace: .local)
                            .onEnded { value in
                                if value.translation.height < 0 {
                                    self.showSheet = true
                                }
                            }
                    )
                    .onTapGesture {
                        self.showSheet = true
                    }
            }
            .sheet(isPresented: $showSheet) {
                Text("test")
            }
            
            .onDisappear{
                if audioPlayer.queueCount > 0
                {
                    audioPlayer.pause()
                }
            }
            .onChange(of: scenePhase) { newScenePhase in
                switch newScenePhase {
                case .active:
                    print("App is active")
                case .inactive:
                    print("App is inactive")
                case .background:
                    //player should pause when the app goes into background so it doesnt go off directly if the user goes back again in the app
                    audioPlayer.pause()
                @unknown default:
                    print("Unknown state")
                }
            }
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreNowView()
    }
}
