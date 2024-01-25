//
//  ExploreNowViewModel.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 16.01.24.
//

import SwiftUI
import AVFoundation

class ExploreNowViewModel: ObservableObject {
    
    @Published var showSheet: Bool = true // Controls the visibility of a modal sheet in the UI.
    @Published var destinationSelection: DestinationItem = DestinationItem(id: nil, name: NSLocalizedString("Library", comment: ""), isLibrary: true)
    // Holds the currently selected destination or item, initialized to a default 'Library' item.

    var audioPlayer: AudioPlayer // Manages audio playback, queueing, and player state.
    var musicKitManager: MusicKitManager // Handles interactions with the MusicKit API.

    // Initializes the ViewModel with dependencies on AudioPlayer and MusicKitManager.
    init(audioPlayer: AudioPlayer, musicKitManager: MusicKitManager) {
        self.audioPlayer = audioPlayer
        self.musicKitManager = musicKitManager
    }
    
    // Computed property to check if the audio player's queue has items.
    var queueIsNotEmpty: Bool {
        audioPlayer.queueCount > 0 // Returns true if there's at least one item in the queue.
    }

    // Pauses the audio player. This method is intended to be called when the view disappears.
    func pausePlayer() {
        if audioPlayer.queueCount > 0 { // Checks if there's anything in the queue before pausing.
            audioPlayer.pause() // Pauses playback.
        }
    }

    // Responds to changes in the app's scene phase, allowing the ViewModel to adjust its behavior based on app state.
    func onScenePhaseChange(_ newScenePhase: ScenePhase) {
        switch newScenePhase {
        case .active:
            // Actions to take when the app becomes active. Placeholder for future logic.
            print("App is active")
        case .inactive:
            // Actions to take when the app becomes inactive. Placeholder for future logic.
            print("App is inactive")
        case .background:
            // Automatically pauses the audio player when the app moves to the background.
            audioPlayer.pause()
        @unknown default:
            // Fallback for future scene phases not covered by current implementation.
            print("Unknown state")
        }
    }
}
