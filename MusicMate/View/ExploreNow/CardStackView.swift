//
//  CardStackView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 12.07.23.
//

import SwiftUI

struct CardStackView: View {
    // Reference to the audio player which manages and plays the music queue.
    @EnvironmentObject var audioPlayer: AudioPlayer
    // Binding to the current destination item selection.
    @Binding var destinationSelection: DestinationItem
    
    // Computed property that calculates and returns the first three indices from the audio queue.
    var firstThreeIndices: Range<Array<Item>.Index> {
        return audioPlayer.queue.startIndex..<(audioPlayer.queue.startIndex + min(2, audioPlayer.queue.count))
    }

    var body: some View {
        VStack {
            // Use of ZStack to stack cards on top of each other.
            ZStack{
                // Iterate over the last three items from the reversed audio queue.
                ForEach(audioPlayer.queue.reversed().suffix(3), id: \.id) { item in
                    // Find the index of the current item in the original audio queue.
                    let index = audioPlayer.queue.firstIndex(where: { $0.id == item.id })
                    
                    // Display each item as a CardView, and determine its active state based on whether it's the first item in the audio queue.
                    // Also check if the view should be finalized based on its position in the first three indices.
                    CardView(item: item, isActive: item.id == audioPlayer.queue.first?.id, viewShouldBeFinalized: index.map { firstThreeIndices.contains($0) } ?? false, destinationSelection: $destinationSelection)
                }
            }
        }
    }
}
