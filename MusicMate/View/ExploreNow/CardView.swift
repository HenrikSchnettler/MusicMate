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
    // MARK: - State Properties
        
    // Represents the card's offset from its initial position.
    @State private var offset = CGSize.zero

    // Represents the card's color, initially set to an opaque white.
    @State private var color: Color = .white.opacity(0)

    // MARK: - Environment Objects & Bindings

    // Injected audio player object.
    @EnvironmentObject var audioPlayer: AudioPlayer

    // Current color scheme (light/dark mode).
    @Environment(\.colorScheme) var colorScheme

    // Audio player item to display.
    @ObservedObject var item: AudioPlayerItem

    // Indicates whether the card view is active.
    var isActive: Bool

    // Determines if the view should be finalized.
    var viewShouldBeFinalized: Bool

    // Placeholder value for the slider component.
    @State private var sliderValuePlaceholder: Double = 0

    // Represents the selected destination for navigation.
    @Binding var destinationSelection: DestinationItem

    // Provides the current state of the app (e.g. background, inactive, active).
    @Environment(\.scenePhase) var scenePhase

    // Represents the CoreData managed object context.
    @Environment(\.managedObjectContext) private var viewContext

    // Timer for holding down a gesture.
    @State private var holdTimer: Timer?

    // Indicates if a special action should be triggered.
    @State private var shouldTriggerSpecialAction: Bool = false

    // MARK: - Enumerations

    // Enum representing swipe directions.
    enum SwipeZone {
        case left, right, neutral
    }
    // Current swipe direction.
    @State private var currentZone: SwipeZone = .neutral

    // Scale factors for heart and dislike animations.
    @State var animationScaleHeart = 1.0
    @State var animationScaleDislike = 1.0
    // Haptic feedback generators.
    let impactLight = UIImpactFeedbackGenerator(style: .light)
    let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    let impactRigid = UIImpactFeedbackGenerator(style: .rigid)

    // MARK: - Body

    // The main view rendering body.
    var body: some View {
        VStack{
            // MARK: - Background
            
            // geometry of the whole card
            GeometryReader { cardGeometry in
                VStack {
                    if viewShouldBeFinalized {
                        // when instance of the card is near of beeing active the view the artwork should be shown
                        if let liveArtwork =
                            // if given show the liveArtwork as a video loop
                            item.AppleMusicExtendedAlbum?.attributes.editorialVideo?.motionDetailTall?.video {
                            VideoPlayerView(url: URL(string: liveArtwork)!, isActive: isActive)
                        }
                        // if there isnt found any liveArtwork there should be shown the static album cover
                        else if let staticArtwork = item.AppleMusicExtendedAlbum?.attributes.artwork.url {
                            AsyncImage(url: URL(string: String(staticArtwork).replacingOccurrences(of: "{w}", with: String(Int(cardGeometry.size.width))).replacingOccurrences(of: "{h}", with: String(Int(cardGeometry.size.height))).replacingOccurrences(of: "{f}", with: "jpg"))) { image in
                                // This closure is called once the image is downloaded.
                                image
                                    .resizable()
                                    // image is overlayed by a frosted glass effect
                                    .overlay(
                                        VisualEffectView(effect: UIBlurEffect(style: .light))
                                    )
                            } placeholder: {
                                // placeholder while image is loading
                            }
                            .frame(width: cardGeometry.size.width, height: cardGeometry.size.height) // Set the width to the parent's width
                        }
                    }
                }
            }
            // the card should take all available space
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                // MARK: - First Overlay
                
                // geometry of the first overlay
                GeometryReader { cardOverlayGeometry in
                    VStack {
                        HStack(alignment: .center){
                            // MARK: - First Overlay artwork Container
                            // geometry of the artwork container
                            GeometryReader { artWorkOverlayGeometry in
                                // when instance of the card is near of beeing active and there is only a static artwork it is shown over the frosted glass view
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
                                            // when image is loading there should be shown a skeleton view placeholder witb a shimmer effect
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
                        
                        // MARK: - First Overlay slider container
                        
                        HStack(alignment: .bottom){
                            // if the current song is ready show the duration slider
                            if item.duration > 0 {
                                Slider(value: $item.progress, in: 0...item.duration, onEditingChanged: { editing in
                                    if !editing {
                                        item.seek(to: item.progress)
                                    }
                                })
                                .padding(.horizontal)
                            }
                            // if the current song is not ready yet show a placeholder slider (It cant´t be accessed yet since the whole card is disabled at this point)
                            else{
                                Slider(value: $sliderValuePlaceholder, in: 0...100)
                                .padding(.horizontal)
                            }
                        }
                        .frame(width: cardOverlayGeometry.size.width, height: cardOverlayGeometry.size.height * 0.080)
                        // Empty Drag gesture to block the space around the slider so the user doesnt accidentally drag the whole card around when seeking in the current song
                        .gesture(
                            DragGesture()
                                .onChanged{ gesture in
                                    
                                } .onEnded { _ in
                                    
                                }
                        )
                        
                        // MARK: - First Overlay song information container
                        
                        VisualEffectView(effect: UIBlurEffect(style: .light))
                            .frame(width: cardOverlayGeometry.size.width, height: cardOverlayGeometry.size.height * 0.23)
                            .shadow(radius: 20)
                            .overlay(
                                // geometry of the song info container
                                GeometryReader { songInfoOverlayGeometry in
                                        HStack(alignment: .center){
                                            VStack(alignment: .leading){
                                                // show pause button when song is currently playing
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
                                                // show pause button when song is paused or hasn´t been started yet
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
                                            // song informations
                                            VStack(alignment: .leading){
                                                Text(item.AppleMusicTrack?.title ?? "")
                                                    .font(.headline)
                                                    .shadow(color: .gray, radius: 2, x: 0, y: 0)
                                                
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
                // MARK: - Second Overlay
                
                // geometry of the second overlay
                GeometryReader { cardOverlayGeometry in
                    ZStack{
                        // fill up whole card with a color based on the active dropzone
                        Rectangle()
                            .fill(color)
                            .frame(width: cardOverlayGeometry.size.width, height: cardOverlayGeometry.size.height)
                        
                        // if the user hold the card in the left dropzone for a longer time it should be shown a dislike image animation
                        if(shouldTriggerSpecialAction && currentZone == .left){
                            VStack(alignment: .trailing){
                                HStack{
                                    Spacer()
                                    withAnimation {
                                        Image(systemName: "hand.thumbsdown.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .scaleEffect(animationScaleDislike)
                                            .foregroundColor(.white)
                                            .onAppear {
                                                animationScaleDislike = 1.0
                                                let baseAnimation = Animation.easeInOut(duration: 1)
                                                let repeated = baseAnimation.repeatForever(autoreverses: true)
                                                
                                                impactRigid.impactOccurred()

                                                withAnimation(repeated) {
                                                    animationScaleDislike = 0.8
                                                }
                                            }
                                            .shadow(radius: 20)
                                    }
                                }
                            }
                            .padding(.trailing, 100)
                        }
                        // if the user hold the card in the right dropzone for a longer time it should be shown a like image animation
                        else if(shouldTriggerSpecialAction && currentZone == .right){
                            VStack(alignment: .leading){
                                HStack{
                                    withAnimation {
                                        Image(systemName: "heart.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                            .scaleEffect(animationScaleHeart)
                                            .foregroundColor(.white)
                                            .onAppear {
                                                animationScaleHeart = 1.0
                                                let baseAnimation = Animation.easeInOut(duration: 1)
                                                let repeated = baseAnimation.repeatForever(autoreverses: true)
                                                
                                                impactRigid.impactOccurred()

                                                withAnimation(repeated) {
                                                    animationScaleHeart = 0.8
                                                }
                                            }
                                            .shadow(radius: 20)
                                    }
                                    Spacer()
                                }
                            }
                            .padding(.leading, 100)
                        }
                    }
                }
            )
            .overlay(
                // MARK: - Third Overlay
                
                GeometryReader { cardOverlayGeometry in
                    Group{
                        // if current color theme is set to dark mode show a fine border around the card
                        if colorScheme == .dark
                        {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.3), lineWidth: cardOverlayGeometry.size.height * 0.01)
                        }
                    }
                }
            )
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        // show a shadow around the card (only vivible in light mode) and instance of the card is near of beeing active
        .shadow(radius: viewShouldBeFinalized ? 4 : 0)
        .padding()
        .offset(x: offset.width, y: offset.height * 0.4)
        .rotationEffect(.degrees(Double(offset.width / 40)))
        .gesture(
            DragGesture()
                .onChanged{ gesture in
                    // Update the offset based on user's drag
                    offset = gesture.translation
                    
                    // Animate color change based on drag's width
                    withAnimation{
                        changeColor(width: offset.width)
                    }
                    
                    // Determine the new zone based on the drag width
                    let newZone: SwipeZone
                    if (-500...(-150)).contains(offset.width) {
                        newZone = .left
                    } else if (150...500).contains(offset.width) {
                        newZone = .right
                    } else {
                        newZone = .neutral
                    }
                    
                    // Check if the user has transitioned between zones
                    if newZone != currentZone {
                        // Cancel the timer if transitioning between zones
                        holdTimer?.invalidate()
                        shouldTriggerSpecialAction = false

                        // Start the timer only if we're entering a drop zone
                        if newZone == .left || newZone == .right {
                            holdTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                                shouldTriggerSpecialAction = true
                            }
                        }
                        currentZone = newZone
                    }
                }
                .onEnded { _ in
                    // Animate the card swipe and color change based on drag's width
                    withAnimation(.easeOut(duration: 0.5)){
                        swipeCard(width: offset.width)
                        changeColor(width: offset.width)
                    }
                    
                    // Provide haptic feedback
                    impactHeavy.impactOccurred()
                    
                    // Schedule the swipe action after animation completes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if shouldTriggerSpecialAction {
                            doSwipeAction(width: offset.width, doExtraAction: true)
                            shouldTriggerSpecialAction = false
                        } else {
                            doSwipeAction(width: offset.width, doExtraAction: false)
                        }
                    }
                }
        )
        // Disable user interaction if the view is not marked as active
        .disabled(!isActive)
    }
    
    // Function to determine the final position of the card based on drag width
    func swipeCard(width: CGFloat){
        switch width {
        case -500...(-150):
            offset = CGSize(width: -500, height: 0)
        case 150...500:
            offset = CGSize(width: 500, height: 0)
        default:
            offset = .zero
        }
    }

    // Function to determine the action after card swipe based on drag width and additional conditions
    func doSwipeAction(width: CGFloat, doExtraAction: Bool){
        switch width {
        case -500...(-150):
            negativeSwipeEndAction(wasDisliked: doExtraAction)
        case 150...500:
            positiveSwipeEndAction(wasLiked: doExtraAction)
        default:
            neutralSwipeEndAction()
        }
    }

    // Function to change color of the view based on drag width
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

    // Actions to perform after a negative swipe
    func negativeSwipeEndAction(wasDisliked: Bool){
        insertTrackIntoHistory(wasAdded: false, wasLiked: false, wasDisliked: wasDisliked)
        audioPlayer.skip()
    }

    // Actions to perform after a positive swipe
    func positiveSwipeEndAction(wasLiked: Bool){
        Task{
            if let insertTrack = item.AppleMusicTrack {
                if destinationSelection.isLibrary {
                    try await MusicLibrary.shared.add(item.AppleMusicTrack!)
                    insertTrackIntoHistory(wasAdded: true, wasLiked: wasLiked, wasDisliked: false)
                }
            }
        }
        audioPlayer.skip()
    }

    // Actions to perform after a neutral swipe
    func neutralSwipeEndAction(){
        
    }

    // Function to insert a song's details into history
    func insertTrackIntoHistory(wasAdded: Bool, wasLiked: Bool, wasDisliked: Bool){
        if let insertTrack = item.AppleMusicTrack {
            let newItem = SongHistory(context: viewContext)
            // Setting properties for the song history item
            newItem.id = UUID()
            newItem.album = insertTrack.albumTitle
            newItem.artist = insertTrack.artistName
            newItem.albumCover = item.AppleMusicExtendedAlbum?.attributes.artwork.url
            newItem.songId = insertTrack.id.rawValue
            newItem.title = insertTrack.title
            newItem.timestamp = Date.now
            newItem.wasAdded = wasAdded
            newItem.wasDisliked = wasDisliked
            newItem.wasLiked = wasLiked
            
            // Try to save the new item to the context
            do {
                try viewContext.save()
            } catch {
                print("Failed to insert history song")
            }
        }
    }
}

