//
//  VideoPlayerUiView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 05.08.23.
//

import Foundation
import AVKit
import SwiftUI

/// A SwiftUI view to display a video player using a UIKit UIView.
struct VideoPlayerView: UIViewRepresentable {
    
    // The URL of the video to be played.
    var url: URL
    
    // A flag to indicate whether the video should be playing or paused.
    var isActive: Bool
    
    /// Create the UIView instance for the SwiftUI view.
    func makeUIView(context: Context) -> UIView {
        let view = VideoPlayerUiView(frame: .zero)
        view.isActive = isActive
        view.playInLoop(url: url)
        return view
    }
    
    /// Update the created UIView instance with any changes in SwiftUI view's state.
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<VideoPlayerView>) {
        if let view = uiView as? VideoPlayerUiView {
            view.isActive = isActive
        }
    }
}

/// A custom UIView to play a video using AVKit.
class VideoPlayerUiView: UIView {
    
    // AVPlayerLayer instance to render the video content.
    private var playerLayer = AVPlayerLayer()
    
    // A looper instance to loop the video playback.
    private var looper: AVPlayerLooper?
    
    // A computed property to manage the AVQueuePlayer associated with the playerLayer.
    var videoPlayer: AVQueuePlayer? {
        get {
            return playerLayer.player as? AVQueuePlayer
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    // A property to monitor the video's playback status.
    var isActive: Bool = false {
        didSet {
            // Play the video when isActive is true, otherwise, pause and reset the video.
            if isActive {
                videoPlayer?.play()
            } else {
                videoPlayer?.pause()
                videoPlayer?.seek(to: CMTime.zero)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set the video's display mode.
        playerLayer.videoGravity = .resizeAspectFill
        
        // Add the playerLayer to the UIView's layer.
        layer.addSublayer(playerLayer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// Layout the playerLayer to match the UIView's bounds.
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    /// Set up the video for looped playback.
    func playInLoop(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        
        // Initialize the AVQueuePlayer and set it to the videoPlayer.
        videoPlayer = AVQueuePlayer(playerItem: playerItem)
        
        // Create a loop for the video playback.
        looper = AVPlayerLooper(player: videoPlayer!, templateItem: playerItem)
        
        // If isActive is true, play the video. Otherwise, reset its position.
        if isActive {
            videoPlayer?.play()
        } else {
            videoPlayer?.seek(to: CMTime.zero)
        }
    }
}
