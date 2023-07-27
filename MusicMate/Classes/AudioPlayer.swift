//
//  AudioPlayer.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 12.07.23.
//

import AVFoundation
import Combine
import MusicKit

class AudioPlayer: ObservableObject {
    @Published var player: AVQueuePlayer
    private var cancellable: AnyCancellable?
    
    @Published var queueCount: Int = 0 {
        didSet {
            if queueCount < 3 {
                self.loadMoreItems()
            }
        }
    }

    @Published var queue: [AudioPlayerItem] = []

    init(player: AVQueuePlayer) {
        do {
            //audio should also play if the physical mute button of the users device is turned on
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
        self.player = player
        self.queueCount = 0
    }
    
    deinit {
        
    }

    // This is the function to load more items
    private func loadMoreItems() {
        Task{
            let personalStationId = await MusicKitManager.shared.getUsersPersonalStationId()
            let additionalItems = await MusicKitManager.shared.getStationsNextTracks(stationId: personalStationId){ track in
                if let previewUrl = track.previewAssets?.first?.url {
                    self.appendSong(url: previewUrl, track: track)
                }
            }
        }
    }

    func appendSong(url: URL, track: Track) {
        let item = AVPlayerItem(url: url)
        
        player.insert(item, after: player.items().last)
        DispatchQueue.main.async { // ensure this update is on the main thread
            self.queue.append(AudioPlayerItem(AudioPlayer: self, PlayerItem: item, AppleMusicTrack: track))
        }
        self.updateQueueCount()
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    func skip() {
        player.advanceToNextItem()
        // you'll want to remove the first item from the queue when skipping.
        if !self.queue.isEmpty {
            DispatchQueue.main.async { // ensure this update is on the main thread
                self.queue.removeFirst()
            }
            self.updateQueueCount()
        }
    }
    
    func updateQueueCount() {
        DispatchQueue.main.async { // ensure this update is on the main thread
            self.queueCount = self.queue.count
        }
    }
}
