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
    // Detects the lifecycle phase of the current scene, e.g., whether the app is in the background or foreground.
    @Environment(\.scenePhase) var scenePhase
    // Provides information about the current appearance (light or dark) mode of the app.
    @Environment(\.colorScheme) var colorScheme
    // Reference to the MusicKitManager to interact with Apple's MusicKit API.
    @EnvironmentObject var musicKitManager: MusicKitManager
    // State variable that holds the user's personal music station.
    @State var personalStation: Station?
    // Reference to the audio player which can stream music previews.
    @StateObject var audioPlayer = AudioPlayer(player: AVQueuePlayer())
    
    // State variable that determines whether the sheet should be shown.
    @State private var showSheet = true
    
    // Defines the default selection for the destination in the app.
    @State var destinationSelection: DestinationItem = DestinationItem(id: nil, name: NSLocalizedString("Library", comment: ""),isLibrary: true)
    
    // Defines the background view based on the current state of the audio player.
    @ViewBuilder
    private var backgroundView: some View {
        // If there's no audio queued up, show a linear gradient as the background.
        if audioPlayer.queueCount == 0 {
            LinearGradient(gradient: Gradient(colors: [Color.themeAccent, Color.themeTertiary, Color.themeSecondary]), startPoint: .leading, endPoint: .trailing)
        }
        // If there's audio in the queue, show the artwork for the current song.
        else if let staticArtwork = audioPlayer.queue.first?.AppleMusicExtendedAlbum?.attributes.artwork.url, audioPlayer.queueCount > 0 {
            AsyncImage(url: URL(string: String(staticArtwork).replacingOccurrences(of: "{w}", with: "150").replacingOccurrences(of: "{h}", with: "40").replacingOccurrences(of: "{f}", with: "png"))) { image in
                image.shadow(radius: 8)
            } placeholder: {
                // Placeholder while the artwork image is loading.
            }
            .frame(width: 150, height: 40)
        }
    }
    
    var body: some View {
        GeometryReader { wholeViewGeometry in
            VStack {
                Group {
                    // If there's audio in the queue, display the card stack view.
                    if audioPlayer.queueCount > 0 {
                        CardStackView(destinationSelection: $destinationSelection)
                            .environmentObject(audioPlayer)
                            .onAppear {
                                // Actions to be performed when CardStackView appears.
                            }
                    }
                    // If the personal station hasn't loaded yet, show a skeleton loading animation.
                    else {
                        SkeletonCardView()
                    }
                }
                .frame(height: wholeViewGeometry.size.height * 0.81) // Sets the height of the content to be 81% of the available screen height.
                
                Spacer() // Fills the remaining space in the VStack.
            }
            .sheet(isPresented: $showSheet) {
                SwipeHistoryView(destinationSelection: $destinationSelection)
                    .environmentObject(audioPlayer)
                    // Define behavior and appearance properties for the sheet.
                    .presentationDetents([.fraction(0.175), .medium, .large])
                    .interactiveDismissDisabled(true)
                    .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.175)))
                    .presentationCornerRadius(21)
                    .presentationDragIndicator(.hidden)
            }
            .cornerRadius(0)
            
            .onDisappear {
                // Pause the audio when this view disappears.
                if audioPlayer.queueCount > 0 {
                    audioPlayer.pause()
                }
            }
            .onChange(of: scenePhase) { newScenePhase in
                // React to changes in the app's lifecycle.
                switch newScenePhase {
                case .active:
                    print("App is active")
                case .inactive:
                    print("App is inactive")
                case .background:
                    // Pause the player when the app goes into the background.
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
