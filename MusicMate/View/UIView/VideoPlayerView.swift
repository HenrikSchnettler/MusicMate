//
//  VideoPlayerUiView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 05.08.23.
//

import Foundation
import AVKit
import SwiftUI

struct VideoPlayerView: UIViewRepresentable {
    var url: URL
    var isActive: Bool
    
    func makeUIView(context: Context) -> UIView {
        let view = VideoPlayerUiView(frame: .zero)
        view.isActive = isActive
        view.playInLoop(url: url)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<VideoPlayerView>) {
        if let view = uiView as? VideoPlayerUiView {
            view.isActive = isActive
        }
    }
}

class VideoPlayerUiView: UIView {
    private var playerLayer = AVPlayerLayer()
    private var looper: AVPlayerLooper?
    
    var videoPlayer: AVQueuePlayer? {
        get {
            return playerLayer.player as? AVQueuePlayer
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    var isActive: Bool = false {
        didSet {
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
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    func playInLoop(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        videoPlayer = AVQueuePlayer(playerItem: playerItem)
        looper = AVPlayerLooper(player: videoPlayer!, templateItem: playerItem)
        if isActive {
            videoPlayer?.play()
        } else {
            videoPlayer?.seek(to: CMTime.zero)
        }
    }
}
