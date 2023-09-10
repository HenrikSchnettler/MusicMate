//
//  CardView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 12.07.23.
//

import SwiftUI
import AVKit
import MusicKit
import CoreData

struct CardView: View {
    @State private var offset = CGSize.zero
    @State private var color: Color = .white.opacity(0)
    @EnvironmentObject var audioPlayer: AudioPlayer
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var item: AudioPlayerItem
    var isActive: Bool
    var viewShouldBeFinalized: Bool
    @State private var sliderValuePlaceholder: Double = 0
    @Binding var destinationSelection: DestinationItem
    //describes the state the app is in
    @Environment(\.scenePhase) var scenePhase
    
    @Environment(\.managedObjectContext) private var viewContext
        
    var body: some View {
        VStack{
            GeometryReader { cardGeometry in
                VStack {
                    if viewShouldBeFinalized {
                        if let liveArtwork = item.AppleMusicExtendedAlbum?.attributes.editorialVideo?.motionDetailTall?.video {
                            VideoPlayerView(url: URL(string: liveArtwork)!, isActive: isActive)
                        }
                        else if let staticArtwork = item.AppleMusicExtendedAlbum?.attributes.artwork.url {
                            AsyncImage(url: URL(string: String(staticArtwork).replacingOccurrences(of: "{w}", with: String(Int(cardGeometry.size.width))).replacingOccurrences(of: "{h}", with: String(Int(cardGeometry.size.height))).replacingOccurrences(of: "{f}", with: "jpg"))) { image in
                                // This closure is called once the image is downloaded.
                                image
                                    .resizable()
                                    //.scaledToFit()
                                    .overlay(
                                        VisualEffectView(effect: UIBlurEffect(style: .light))
                                    )
                            } placeholder: {
                                
                            }
                            .frame(width: cardGeometry.size.width, height: cardGeometry.size.height) // Set the width to the parent's width
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            //.overlay(
                //VisualEffectView(effect: UIBlurEffect(style: .dark))
                                //.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            //)
            .overlay(
                GeometryReader { cardOverlayGeometry in
                    VStack {
                        HStack(alignment: .center){
                            GeometryReader { artWorkOverlayGeometry in
                                if viewShouldBeFinalized {
                                    if let liveArtwork = item.AppleMusicExtendedAlbum?.attributes.editorialVideo?.motionDetailTall?.video{
                                        
                                    }
                                    else if let staticArtwork = item.AppleMusicExtendedAlbum?.attributes.artwork.url{
                                        AsyncImage(url: URL(string: String(staticArtwork).replacingOccurrences(of: "{w}", with: "1920").replacingOccurrences(of: "{h}", with: "1920").replacingOccurrences(of: "{f}", with: "png"))) { image in
                                            // This closure is called once the image is downloaded.
                                            image
                                                .resizable()
                                                .shadow(radius: 20)
                                                .cornerRadius(16)
                                        } placeholder: {
                                            VisualEffectView(effect: UIBlurEffect(style: .light))
                                                .redacted(reason: .placeholder)
                                                .shimmer()
                                                .cornerRadius(16)
                                        }
                                        .frame(width: artWorkOverlayGeometry.size.width, height: artWorkOverlayGeometry.size.width)
                                    }
                                }
                            }
                        }
                        .padding()
                        .frame(width: cardOverlayGeometry.size.width, height: cardOverlayGeometry.size.height * 0.67)
                        HStack(alignment: .bottom){
                            if item.duration > 0 {
                                Slider(value: $item.progress, in: 0...item.duration, onEditingChanged: { editing in
                                    if !editing {
                                        item.seek(to: item.progress)
                                    }
                                })
                                .padding(.horizontal)
                                //.padding(.bottom, 10)
                            }
                            else{
                                Slider(value: $sliderValuePlaceholder, in: 0...100)
                                .padding(.horizontal)
                                //.padding(.bottom, 10)
                            }
                        }
                        .frame(width: cardOverlayGeometry.size.width, height: cardOverlayGeometry.size.height * 0.080)
                        .gesture(
                            DragGesture()
                                .onChanged{ gesture in
                                    
                                } .onEnded { _ in
                                    
                                }
                        )
                        VisualEffectView(effect: UIBlurEffect(style: .light))
                            .frame(width: cardOverlayGeometry.size.width, height: cardOverlayGeometry.size.height * 0.23)
                            .shadow(radius: 20)
                            .overlay(
                                GeometryReader { songInfoOverlayGeometry in
                                        HStack(alignment: .center){
                                            VStack(alignment: .leading){
                                                if(item.isPlaying ?? false)
                                                {
                                                    Button(action: {
                                                        audioPlayer.player.pause()
                                                    }) {
                                                        Image(systemName: "pause.circle.fill")
                                                            .resizable()
                                                            .foregroundColor(.white)
                                                            .frame(width: songInfoOverlayGeometry.size.height * 0.5, height: songInfoOverlayGeometry.size.height * 0.5)
                                                            .fixedSize(horizontal: true, vertical: true)
                                                            .shadow(radius: 20)
                                                    }
                                                }
                                                else{
                                                    Button(action: {
                                                        audioPlayer.player.play()
                                                    }) {
                                                        Image(systemName: "play.circle.fill")
                                                            .resizable()
                                                            .foregroundColor(.white)
                                                            .frame(width: songInfoOverlayGeometry.size.height * 0.5, height: songInfoOverlayGeometry.size.height * 0.5)
                                                            .fixedSize(horizontal: true, vertical: true)
                                                            .shadow(radius: 20)
                                                    }
                                                }
                                            }
                                            .frame(width: 50)
                                            .padding(.leading,20)
                                            .padding(.trailing,10)
                                            VStack(alignment: .leading){
                                                Text(item.AppleMusicTrack?.title ?? "")
                                                    .font(.headline)
                                                    .shadow(color: .gray, radius: 2, x: 0, y: 0)
                                                //Text(item.AppleMusicTrack?.albumTitle ?? "")
                                                Text(item.AppleMusicTrack?.artistName ?? "")
                                                    .font(.subheadline)
                                                    .shadow(color: .gray, radius: 1, x: 0, y: 0)
                                            }
                                            .padding(.leading,10)
                                            .padding(.trailing,20)
                                            .foregroundColor(Color.white)
                                            
                                            Spacer()
                                        }
                                        .frame(width: songInfoOverlayGeometry.size.width, height: songInfoOverlayGeometry.size.height)
                                }
                                
                            )
                    }
                }
            )
            .overlay(
                GeometryReader { cardOverlayGeometry in
                    Rectangle()
                        .fill(color)
                        .frame(width: cardOverlayGeometry.size.width, height: cardOverlayGeometry.size.height)
                }
            )
            .overlay(
                GeometryReader { cardOverlayGeometry in
                    Group{
                        if colorScheme == .dark
                        {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.3), lineWidth: cardOverlayGeometry.size.height * 0.01)
                        }
                    }
                }
            )
        }
        //.background(Color(UIColor.systemBackground))
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(radius: viewShouldBeFinalized ? 4 : 0)
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
            color = .red.opacity(0.4)
        case 150...500:
            color = .green.opacity(0.4)
        default:
            color = .white.opacity(0)
        }
    }
    
    func negativeSwipeEndAction(){
        insertTrackIntoHistory(wasAdded: false, wasLiked: false, wasDisliked: false)
        //skip to the next song without doing anything (yet)
        audioPlayer.skip()
    }
    
    func positiveSwipeEndAction(){
        //song should be added to the users library and then the player shoul skip to the next song (for now)
        Task{
            if let insertTrack = item.AppleMusicTrack {
                if destinationSelection.isLibrary{
                    try await MusicLibrary.shared.add(item.AppleMusicTrack!)
                    insertTrackIntoHistory(wasAdded: true, wasLiked: false, wasDisliked: false)
                }
                else{
                    
                }
            }
        }
        audioPlayer.skip()
    }
    
    func neutralSwipeEndAction(){
        
    }
    
    func insertTrackIntoHistory(wasAdded: Bool, wasLiked: Bool, wasDisliked: Bool){
        if let insertTrack = item.AppleMusicTrack {
            let newItem = SongHistory(context: viewContext)
            
            newItem.id = UUID()
            newItem.album = item.AppleMusicTrack?.albumTitle
            newItem.artist = item.AppleMusicTrack?.artistName
            newItem.albumCover = item.AppleMusicExtendedAlbum?.attributes.artwork.url
            newItem.songId = item.AppleMusicTrack?.id.rawValue
            newItem.title = item.AppleMusicTrack?.title
            newItem.timestamp = Date.now
            newItem.wasAdded = wasAdded
            newItem.wasDisliked = wasDisliked
            newItem.wasLiked = wasLiked
            
            do {
                try viewContext.save()
            } catch {
                print("Failed to insert history song")
            }
        }
    }
}

