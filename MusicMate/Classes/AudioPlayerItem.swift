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

class AudioPlayerItem: ObservableObject, Identifiable {
    private weak var AudioPlayer: AudioPlayer?
    private var PlayerItem: AVPlayerItem?
    private var statusObserver: Any?
    private var durationObserver: Any?
    private var playerCurrentsongObserver: Any?
    private var progressObserver: Any?
    private var endObserver: NSObjectProtocol?
    private var cancellable: AnyCancellable?
    let id = UUID()
    let AppleMusicTrack: Track?
    
    @Published var progress: Double = 0
    @Published var duration: Double = 0

    init(AudioPlayer: AudioPlayer, PlayerItem: AVPlayerItem, AppleMusicTrack: Track) {
        self.AudioPlayer = AudioPlayer
        self.PlayerItem = PlayerItem
        self.AppleMusicTrack = AppleMusicTrack
        
        self.setupPlayerCurrentsongObserver()
    }
    
    deinit {
        
    }
    
    private func setupPlayerCurrentsongObserver() {
        
        // Observe playerItem's status to know when duration becomes available
        playerCurrentsongObserver = AudioPlayer?.player.observe(\.currentItem, options: [.new,.initial]) { [weak self] (player, change) in
            if(self?.AudioPlayer?.player.currentItem === self?.PlayerItem)
            {
                self?.setupProgressObserver()
            }
        }
    }
    
    private func setupDurationObserver() {
        durationObserver = PlayerItem?.observe(\.duration, options: [.new]) { [weak self] (playerItem, change) in
            self?.duration = CMTimeGetSeconds(playerItem.duration)
        }
    }
    
    private func setupProgressObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        progressObserver = AudioPlayer?.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            guard let self = self else { return }
            self.progress = time.seconds
            self.duration = self.AudioPlayer?.player.currentItem?.duration.seconds ?? 0
        }
    }
    
    func seek(to progress: Double) {
        let time = CMTime(seconds: progress, preferredTimescale: 1000)
        AudioPlayer?.player.seek(to: time)
    }
}
