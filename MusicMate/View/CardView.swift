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

    var body: some View {
        Rectangle()
            .frame(width: 320, height: 475)
            .border(.white, width: 6.0)
            .cornerRadius(10)
            .foregroundColor(color.opacity(1))
            .overlay(
                VStack{
                    Spacer()
                    //PlayerView(url: "https://mvod.itunes.apple.com/itunes-assets/HLSMusic125/v4/bc/1c/5f/bc1c5fac-0f38-375e-e221-057cd0f2665a/P359222039_default.m3u8")
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

struct PlayerView: UIViewRepresentable {
    let url: String
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        let player = AVPlayer(url: URL(string: url)!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        view.layer.addSublayer(playerLayer)
        player.play()
        
        return view
    }
}
