//
//  CardView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 12.07.23.
//

import SwiftUI
import AVKit
import MusicKit

struct CardView: View {
    @State private var offset = CGSize.zero
    @State private var color: Color = .black
    @EnvironmentObject var audioPlayer: AudioPlayer
    @ObservedObject var item: AudioPlayerItem
    var isActive: Bool
    var viewShouldBeFinalized: Bool

    var body: some View {
        VStack{
            if viewShouldBeFinalized{
                VideoPlayerView(url: URL(string: "https://mvod.itunes.apple.com/itunes-assets/HLSMusic125/v4/f1/06/a2/f106a238-e9e3-bac6-7328-f265e5693f00/P359221696_default.m3u8")!, isActive: isActive)
                
                //AsyncImage(url: URL(string: //"https://is1-ssl.mzstatic.com/image/thumb/Video124/v4/41/e7/2d/41e72d55-5731-7ddc-5374-6170ad574950/Jobe31b64ce-6872-45af-9229-5c75a976b116-108272180-PreviewImage_preview_image_nonvideo_sdr-Time1608169257715.png/3200x475bb.png")) { image in
                            // This closure is called once the image is downloaded.
                            //image
                        //} placeholder: {
                            // This view is shown until the image downloads.
                            //ProgressView()
                        //}
                        //.frame(width: 320, height: 475)
            }
            else{
            }
        }
        .frame(width: 320, height: 475)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        //.shadow(radius: 1)
        .foregroundColor(color.opacity(1))
        .overlay(
            VStack(alignment: .center){
                if isActive{
                    //PlayerView(url: "https://mvod.itunes.apple.com/itunes-assets/HLSMusic125/v4/f1/06/a2/f106a238-e9e3-bac6-7328-f265e5693f00/P359221696_default.m3u8")
                }
                if(item.isPlaying ?? false)
                {
                    Button(action: {
                        audioPlayer.player.pause()
                    }) {
                        Image(systemName: "pause.circle")
                            .foregroundColor(.white)
                    }
                    .frame(minWidth: 50, maxWidth: 50, minHeight: 50, maxHeight: 50)
                }
                else{
                    Button(action: {
                        audioPlayer.player.play()
                    }) {
                        Image(systemName: "play.circle")
                            .foregroundColor(.white)
                    }
                    .frame(minWidth: 50, maxWidth: 50, minHeight: 50, maxHeight: 50)
                }
                Text(item.AppleMusicTrack?.title ?? "")
                Text(item.AppleMusicTrack?.albumTitle ?? "")
                Text(item.AppleMusicTrack?.artistName ?? "")
                //if personal station is fetched and avaible the CardView should be shown
                if item.duration > 0 {
                    Slider(value: $item.progress, in: 0...item.duration, onEditingChanged: { editing in
                        if !editing {
                            item.seek(to: item.progress)
                        }
                    })
                    .padding()
                }
            }
        )
        .padding()
        .offset(x: offset.width, y: offset.height * 0.4)
        .rotationEffect(.degrees(Double(offset.width / 40)))
        .gesture(
            DragGesture()
                .onChanged{ gesture in
                    offset = gesture.translation
                    withAnimation{
                        changeColor(width: offset.width)
                    }
                } .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.5)){
                        swipeCard(width: offset.width)
                        changeColor(width: offset.width)
                    }
                    let impactMedium = UIImpactFeedbackGenerator(style: .medium)
                    impactMedium.impactOccurred()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        doSwipeAction(width: offset.width)
                    }
                }
        )
        //view should only be interactable if it is marked active
        .disabled(!isActive)
    }
    
    func swipeCard(width: CGFloat){
        switch width {
        case -500...(-150):
            offset = CGSize(width: -500, height: 0)
            //negativeSwipe()
        case 150...500:
            offset = CGSize(width: 500, height: 0)
            //positiveSwipe()
        default:
            offset = .zero
        }
    }
    
    func doSwipeAction(width: CGFloat){
        switch width {
        case -500...(-150):
            negativeSwipeEndAction()
        case 150...500:
            positiveSwipeEndAction()
        default:
            neutralSwipeEndAction()
        }
    }
    
    func changeColor(width: CGFloat){
        switch width {
        case -500...(-130):
            color = .red
        case 150...500:
            color = .green
        default:
            color = .black
        }
    }
    
    func negativeSwipeEndAction(){
        //skip to the next song without doing anything (yet)
        audioPlayer.skip()
    }
    
    func positiveSwipeEndAction(){
        //song should be added to the users library and then the player shoul skip to the next song (for now)
        Task{
            if let insertTrack = item.AppleMusicTrack {
                try await MusicLibrary.shared.add(item.AppleMusicTrack!)
            }
        }
        audioPlayer.skip()
    }
    
    func neutralSwipeEndAction(){
        
    }
}

class PlayerUIView: UIView {
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

struct VideoPlayerView: UIViewRepresentable {
    var url: URL
    var isActive: Bool
    
    func makeUIView(context: Context) -> UIView {
        let view = PlayerUIView(frame: .zero)
        view.isActive = isActive
        view.playInLoop(url: url)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<VideoPlayerView>) {
        if let view = uiView as? PlayerUIView {
            view.isActive = isActive
        }
    }
}

