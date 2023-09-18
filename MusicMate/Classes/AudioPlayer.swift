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
            if queueCount < 3 {
                self.loadMoreItems()
            }
        }
    }
    
    // Represents the audio queue.
    @Published var queue: [AudioPlayerItem] = []

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
        self.queueCount = 0
    }
    
    // Destructor for cleanup purposes, currently empty.
    deinit {
        
    }

    // Loads more items into the queue when needed.
    private func loadMoreItems() {
        Task {
            weak var musicManager = MusicKitManager.shared
            let personalStationId = await musicManager?.getUsersPersonalStationId()
            let additionalItems = await musicManager?.getStationsNextTracks(stationId: personalStationId ?? "") { track in
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
}
