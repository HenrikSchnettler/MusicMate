//
//  SwipeHistoryView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 26.08.23.
//

import SwiftUI

// A view to showcase the history of songs the user has swiped on.
struct SwipeHistoryView: View {
    // Reference to Core Data's managed object context.
    @Environment(\.managedObjectContext) private var viewContext
    
    // A fetch request to retrieve songs sorted by the time they were swiped.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SongHistory.timestamp, ascending: false)],
        animation: .easeIn)
    private var historySongs: FetchedResults<SongHistory>
    
    // State variable to manage filtering the history by song's addition status.
    @State private var filterBySelection = 0
    
    // Audio player instance to retrieve info about the current playing song.
    @EnvironmentObject var audioPlayer: AudioPlayer
    
    var body: some View {
        NavigationView{
            GeometryReader { fullGeometry in
                VStack(){
                    HStack{
                        Picker("", selection: $filterBySelection) {
                            HStack {
                                Text("All")
                            }
                            .tag(0)
                            
                            HStack {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.green)
                            }
                            .tag(1)
                            
                            HStack {
                                Image(systemName: "xmark.circle")
                                    .foregroundColor(.red)
                            }
                            .tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(.horizontal)
                    List{
                        Section(header: Text("The last swipes")){
                            ForEach(historySongs) { item in
                                // Conditional logic to determine if a history item should be shown based on the filter.
                                if((filterBySelection == 0 && (item.wasAdded || !item.wasAdded)) || (filterBySelection == 1 && item.wasAdded) || (filterBySelection == 2 && !item.wasAdded))
                                {
                                    HStack(alignment: .center){
                                        // Displaying the song's artwork.
                                        VStack(alignment: .leading){
                                            AsyncImage(url: URL(string: String(item.albumCover ?? "").replacingOccurrences(of: "{w}", with: String(Int(fullGeometry.size.width*0.1))).replacingOccurrences(of: "{h}", with: String(Int(fullGeometry.size.width*0.1))).replacingOccurrences(of: "{f}", with: "png"))) { image in
                                                // Once image is downloaded, apply styles.
                                                image
                                                    .resizable()
                                                    .shadow(radius: 20)
                                                    .cornerRadius(32)
                                            } placeholder: {
                                                // Placeholder while the image is being downloaded.
                                                VisualEffectView(effect: UIBlurEffect(style: .light))
                                                    .redacted(reason: .placeholder)
                                                    .shimmer()
                                                    .cornerRadius(32)
                                            }
                                            .frame(width: fullGeometry.size.width*0.1, height: fullGeometry.size.width*0.1)
                                        }
                                        
                                        // Displaying song's title and artist name.
                                        VStack(alignment: .leading){
                                            Text(item.title ?? "Unknown name")
                                                .font(.headline)
                                            Text(item.artist ?? "Unknown album")
                                                .font(.subheadline)
                                        }
                                        .padding(.leading,10)
                                        .padding(.trailing,20)
                                        
                                        Spacer()
                                        
                                        // Icons to indicate whether a song was added, liked, or disliked.
                                        if(item.wasAdded){
                                            if(item.wasLiked)
                                            {
                                                Image(systemName: "heart.circle.fill")
                                                    .foregroundColor(.red)
                                            }
                                            
                                            Image(systemName: "checkmark.circle")
                                                .foregroundColor(.green)
                                        }
                                        else{
                                            if(item.wasDisliked)
                                            {
                                                Image(systemName: "hand.thumbsdown.circle.fill")
                                                    .foregroundColor(.red)
                                            }
                                            Image(systemName: "xmark.circle")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .toolbar {
            // Toolbar items.
                // Picker for changing the destination.
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack{
                        Picker("Destination", selection: $audioPlayer.destinationSelection) {
                            ForEach(audioPlayer.confirmDestinations, id: \.id) { item in
                                Text(item.name).tag(item)
                            }
                        }
                        .labelsHidden()
                        .foregroundColor(.white)
                        .font(.system(size: 15))
                        .frame(minHeight: 30, maxHeight: 30, alignment: .center)
                        .accentColor(.white)
                        .background(
                            Color.themeAccent
                        )
                        .cornerRadius(32)
                    }
                    .padding(.vertical)
                }
                // Picker for switching between personal and public mode.
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack{
                        Picker("Recommendation Mode", selection: $audioPlayer.recommendationModeSelection) {
                            ForEach(audioPlayer.recommendationModes, id: \.id) { item in
                                    Text(item.displayText).tag(item)
                                }
                            }
                        .labelsHidden()
                        .foregroundColor(.white)
                        .font(.system(size: 15))
                        .frame(minHeight: 30, maxHeight: 30, alignment: .center)
                        .accentColor(.white)
                        .background(
                            Color.themeSecondary
                        )
                        .cornerRadius(32)
                    }
                    .padding(.vertical)
                }
                // Share button to share the currently playing song's link.
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack{
                        if let shareUrl = audioPlayer.queue.first?.AppleMusicTrack?.url{
                            ShareLink(item: shareUrl){
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share")
                            }
                            .font(.system(size: 15))
                            .accentColor(.white)
                            .labelsHidden()
                            .background(
                                Color.themeTertiary
                            )
                            .frame(minHeight: 30, maxHeight: 30, alignment: .center)
                            .cornerRadius(32)
                        }
                        else{
                            ShareLink(item: URL(string: "https://music.apple.com/")!){
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share")
                            }
                            .disabled(true)
                            .font(.system(size: 15))
                            .accentColor(.white)
                            .labelsHidden()
                            .background(
                                Color.themeTertiary
                            )
                            .frame(minHeight: 30, maxHeight: 30, alignment: .center)
                            .cornerRadius(32)
                        }
                            //Spacer()
                        
                    }
                    .padding(.vertical)
                }
            }
        }
    }
}

