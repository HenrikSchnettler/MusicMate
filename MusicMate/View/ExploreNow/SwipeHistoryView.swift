//
//  SwipeHistoryView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 26.08.23.
//

import SwiftUI

struct SwipeHistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var destinationSelection: DestinationItem
    let confirmDestinations = [
        DestinationItem(id: nil, name: NSLocalizedString("Library", comment: ""),isLibrary: true)
    ]
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SongHistory.timestamp, ascending: false)],
        animation: .easeIn)
    private var historySongs: FetchedResults<SongHistory>
    
    @State private var filterBySelection = 0
    
    @EnvironmentObject var audioPlayer: AudioPlayer
    
    var body: some View {
        NavigationView{
            GeometryReader { fullGeometry in
                VStack(){
                    List{
                        Section(header: Text("The last swipes")){
                            ForEach(historySongs) { item in
                                if((filterBySelection == 0 && (item.wasAdded || !item.wasAdded)) || (filterBySelection == 1 && item.wasAdded) || (filterBySelection == 2 && !item.wasAdded))
                                {
                                    HStack(alignment: .center){
                                        VStack(alignment: .leading){
                                            AsyncImage(url: URL(string: String(item.albumCover ?? "").replacingOccurrences(of: "{w}", with: String(Int(fullGeometry.size.width*0.1))).replacingOccurrences(of: "{h}", with: String(Int(fullGeometry.size.width*0.1))).replacingOccurrences(of: "{f}", with: "png"))) { image in
                                                // This closure is called once the image is downloaded.
                                                image
                                                    .resizable()
                                                    .shadow(radius: 20)
                                                    .cornerRadius(32)
                                            } placeholder: {
                                                VisualEffectView(effect: UIBlurEffect(style: .light))
                                                    .redacted(reason: .placeholder)
                                                    .shimmer()
                                                    .cornerRadius(32)
                                            }
                                            .frame(width: fullGeometry.size.width*0.1, height: fullGeometry.size.width*0.1)
                                        }
                                        VStack(alignment: .leading){
                                            Text(item.title ?? "Unknown name")
                                                .font(.headline)
                                            Text(item.artist ?? "Unknown album")
                                                .font(.subheadline)
                                        }
                                        .padding(.leading,10)
                                        .padding(.trailing,20)
                                        
                                        Spacer()
                                        
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
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack{
                        Picker("Destination", selection: $destinationSelection) {
                            ForEach(confirmDestinations, id: \.id) { item in
                                HStack{
                                    Text(item.name).tag(item)
                                }
                            }
                        }
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
                ToolbarItem(placement: .navigationBarLeading) {
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
                    .padding(.vertical)
                }
            }
        }
    }
}
