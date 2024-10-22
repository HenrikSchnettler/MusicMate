//
//  AudioPlayer.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 12.07.23.
//

import AVFoundation
import Combine
import MusicKit

// A class representing an audio player, conforming to the ObservableObject protocol
// to allow it to broadcast its changes to any views that are subscribed to it.
class AudioPlayer: ObservableObject {
    
    // Represents the actual AV player.
    @Published var player: AVQueuePlayer
    
    // A cancellable object that can be used to cancel ongoing operations.
    private var cancellable: AnyCancellable?
    
    // Represents the number of items in the queue.
    // It also checks if the queue has less than 3 items and tries to load more.
    @Published var queueCount: Int = 0 {
        didSet {
            if (self.destinationSelection != nil) && (self.recommendationModeSelection != nil) && self.queueCount < 3 {
                self.loadMoreItems()
            }
        }
    }
    
    // Represents the audio queue.
    @Published var queue: [AudioPlayerItem] = []
    
    // Holds the current selected destination for positive swipes
    @Published var destinationSelection: DestinationItem? {
        didSet {
            saveDestinationSelctionToDefaults()
            
            Task {
                if(self.destinationSelection != nil && self.recommendationModeSelection != nil){
                    await clearQueue()
                }
            }
        }
    }
    
    // Holds all available destinations
    @Published var confirmDestinations = [
        DestinationItem(id: nil, name: NSLocalizedString("Library", comment: ""),action: .libraryMode)
    ]
    
    // Holds the current selected recommendation Mode
    @Published var recommendationModeSelection: RecommendationModeItem? {
        didSet {
            saveRecommendationModeToDefaults()
            
            Task {
                if(self.destinationSelection != nil && self.recommendationModeSelection != nil){
                    await clearQueue()
                }
            }
        }
    }
    
    // Holds all currently available recommendation modes
    let recommendationModes = [
        RecommendationModeItem(id: 1, displayText: NSLocalizedString("Personal", comment: ""), action: .personalMode),
        RecommendationModeItem(id: 2, displayText: NSLocalizedString("Public", comment: ""), action: .publicMode)
    ]

    // Initializer for the audio player.
    init(player: AVQueuePlayer) {
        do {
            // Ensures audio plays even if the physical mute button of the user's device is turned on.
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
        
        self.player = player
        
        loadActiveRecommendationMode()
        loadActiveDestination()
        
        self.queueCount = 0
    }
    
    // Destructor for cleanup purposes, currently empty.
    deinit {
        
    }

    // Loads more items into the queue when needed.
    private func loadMoreItems() {
        Task {
            weak var musicManager = MusicKitManager.shared
            
            let stationId = recommendationModeSelection?.action == .personalMode ? await musicManager?.getUsersPersonalStationId() : await musicManager?.getPublicStationId()
            
            let additionalItems = await musicManager?.getStationsNextTracks(stationId: stationId ?? "") { track in
                if let previewUrl = track.previewAssets?.first?.url {
                    Task {
                        // weak reference to the MusicKitManager instance
                        weak var musicManager = MusicKitManager.shared
                        // wait for getting the extended album from apple music api
                        await musicManager?.getAlbumByID(songId: track.id) { result in
                            switch result {
                            case .success(let album):
                                // if the call to the api was successfull and returned a extended album the current song should be added to the queue
                                self.appendSong(url: previewUrl, track: track, album: album)
                            case .failure(let error):
                                print("Error: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
        }
    }

    // Appends a song to the player's queue.
    func appendSong(url: URL, track: Track, album: ExtendedAlbum) {
        // create a PlayItem object
        let item = AVPlayerItem(url: url)
        
        // append song after the last song in the player
        player.insert(item, after: player.items().last)
        DispatchQueue.main.async { // Ensure this update is on the main thread.
            // sync the insert into player with an insert int the queue arary
            self.queue.append(AudioPlayerItem(AudioPlayer: self, PlayerItem: item, AppleMusicTrack: track, AppleMusicExtendedAlbum: album))
        }
        //update the observeable queue count
        self.updateQueueCount()
    }

    // Begins playback of the player.
    func play() {
        player.play()
    }

    // Pauses playback of the player.
    func pause() {
        player.pause()
    }

    // Skips the current track to play the next one.
    func skip() {
        player.advanceToNextItem()
        
        // Remove the first item from the queue when skipping when queue is not already empty.
        if !self.queue.isEmpty {
            DispatchQueue.main.async { // Ensure this update is on the main thread.
                self.queue.removeFirst()
            }
            //update the observeable queue count
            self.updateQueueCount()
        }
    }
    
    // Updates the queue count.
    func updateQueueCount() {
        DispatchQueue.main.async { // Ensure this update is on the main thread.
            self.queueCount = self.queue.count
        }
    }
    
    // Updates the queue count.
    func clearQueue() async {
        //update is on the main thread.
        DispatchQueue.main.async {
            self.pause()
            self.player.removeAllItems()
            self.queue.removeAll()
            self.queueCount = self.queue.count
        }
    }
    
    private func saveRecommendationModeToDefaults() {
        // Save the selected object's ID
        if let selectedObject = recommendationModeSelection {
            UserDefaults.standard.set(recommendationModeSelection?.action.rawValue, forKey: "recommendationModeSelection")
        }
    }
    
    private func loadActiveRecommendationMode() {
        // Load the saved properties
        let savedActionString = UserDefaults.standard.string(forKey: "recommendationModeSelection")
            
        // Ensure that there is a valid saved object; otherwise, default to first option
        if let action = savedActionString, let savedAction = RecommendationModeAction(rawValue: action) {
            // Find the matching object in the options array by ID and status
            if let matchedObject = self.recommendationModes.first(where: { $0.action == savedAction }) {
                self.recommendationModeSelection = matchedObject
            } else {
                // If no match found, set the default (e.g., the first option)
                self.recommendationModeSelection = recommendationModes.first
            }
        } else {
            self.recommendationModeSelection = recommendationModes.first
        }
    }
    
    private func saveDestinationSelctionToDefaults() {
        // Save the selected object's ID
        if let selectedObject = destinationSelection {
            UserDefaults.standard.set(destinationSelection?.action.rawValue, forKey: "destinationSelection")
        }
    }
    
    private func loadActiveDestination() {
        // Load the saved properties
        let savedActionString = UserDefaults.standard.string(forKey: "destinationSelection")
            
        // Ensure that there is a valid saved object; otherwise, default to first option
        if let action = savedActionString, let savedAction = DestinationModeAction(rawValue: action) {
            // Find the matching object in the options array by ID and status
            if let matchedObject = self.confirmDestinations.first(where: { $0.action == savedAction }) {
                self.destinationSelection = matchedObject
            } else {
                // If no match found, set the default (e.g., the first option)
                self.destinationSelection = confirmDestinations.first
            }
        } else {
            self.destinationSelection = confirmDestinations.first
        }
    }
}
