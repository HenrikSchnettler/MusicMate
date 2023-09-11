//
//  AudioPlayerItem.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 23.07.23.
//

import AVFoundation
import Foundation
import Combine
import MusicKit

// Represents an individual audio item in the player's queue, providing facilities for observing playback state and progress.
class AudioPlayerItem: ObservableObject, Identifiable {
    
    // Weak reference to the main audio player for callbacks and updates.
    private weak var AudioPlayer: AudioPlayer?
    
    // Reference to the AVPlayerItem for actual playback.
    private var PlayerItem: AVPlayerItem?
    
    // Observers for various playback-related properties.
    private var statusObserver: Any?
    private var durationObserver: Any?
    private var playerCurrentsongObserver: Any?
    private var progressObserver: Any?
    private var endObserver: NSObjectProtocol?
    private var isPlayingObserver: NSObjectProtocol?
    
    // Used to store any subscriptions for cancellable operations.
    private var cancellable: AnyCancellable?
    
    // Unique identifier for each AudioPlayerItem.
    let id = UUID()
    
    // Metadata related to the current track and album.
    let AppleMusicTrack: Track?
    let AppleMusicExtendedAlbum: ExtendedAlbum?
    
    // Published properties to observe changes from the UI.
    @Published var progress: Double = 0
    @Published var duration: Double = 0
    @Published var isPlaying: Bool?

    // Initialize with essential components like the main audio player, the player item, and associated metadata.
    init(AudioPlayer: AudioPlayer, PlayerItem: AVPlayerItem, AppleMusicTrack: Track, AppleMusicExtendedAlbum: ExtendedAlbum) {
        self.AudioPlayer = AudioPlayer
        self.PlayerItem = PlayerItem
        self.AppleMusicTrack = AppleMusicTrack
        self.AppleMusicExtendedAlbum = AppleMusicExtendedAlbum
        
        self.setupPlayerCurrentsongObserver()
    }
    
    // Cleanup and remove any observers upon deinitialization to avoid memory leaks.
    deinit {
        NotificationCenter.default.removeObserver(statusObserver)
        NotificationCenter.default.removeObserver(durationObserver)
        NotificationCenter.default.removeObserver(playerCurrentsongObserver)
        NotificationCenter.default.removeObserver(progressObserver)
        NotificationCenter.default.removeObserver(endObserver)
        NotificationCenter.default.removeObserver(isPlayingObserver)
    }
    
    // Observe changes to the current song in the player.
    private func setupPlayerCurrentsongObserver() {
        playerCurrentsongObserver = AudioPlayer?.player.observe(\.currentItem, options: [.new,.initial]) { [weak self] (player, change) in
            // if the current son is currently playing in the player the observers should be activated
            if(self?.AudioPlayer?.player.currentItem === self?.PlayerItem)
            {
                self?.setupProgressObserver()
                self?.setupIsPlayingObserver()
                self?.setupEndObserver()
            }
        }
    }
    
    // Observe the playback status (e.g., whether the item is currently playing or paused).
    private func setupIsPlayingObserver() {
        isPlayingObserver = AudioPlayer?.player.observe(\.timeControlStatus, options: [.new,.initial]) { [weak self] (playerObject, change) in
            if(playerObject.timeControlStatus == .playing)
            {
                self?.isPlaying = true
            }
            else if (playerObject.timeControlStatus == .paused)
            {
                self?.isPlaying = false
            }
        }
    }
    
    // Observe when the player item finishes playing to its end.
    private func setupEndObserver() {
            endObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: PlayerItem,
                queue: .main
            ) { [weak self] _ in
                DispatchQueue.main.async {
                    // when item is done playing without user interaction it should be removed to mirror the deletion in the players actual queue
                    self?.AudioPlayer?.queue.removeFirst()
                }
                self?.AudioPlayer?.updateQueueCount()
            }
    }
    
    // Periodically observe the playback progress of the player item.
    private func setupProgressObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        progressObserver = AudioPlayer?.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            guard let self = self else { return }
            self.progress = time.seconds
            self.duration = self.AudioPlayer?.player.currentItem?.duration.seconds ?? 0
        }
    }
    
    // Seek to a specific progress point in the current player item.
    func seek(to progress: Double) {
        let time = CMTime(seconds: progress, preferredTimescale: 1000)
        AudioPlayer?.player.seek(to: time)
    }
}
