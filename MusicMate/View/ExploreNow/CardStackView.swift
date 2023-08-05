//
//  CardStackView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 12.07.23.
//

import SwiftUI

struct CardStackView: View {
    @EnvironmentObject var audioPlayer: AudioPlayer
    
    var firstThreeIndices: Range<Array<Item>.Index> {
        return audioPlayer.queue.startIndex..<(audioPlayer.queue.startIndex + min(2, audioPlayer.queue.count))
    }

    var body: some View {
        VStack {
            ZStack{
                ForEach(audioPlayer.queue.reversed(), id: \.id) { item in
                    let index = audioPlayer.queue.firstIndex(where: { $0.id == item.id })
                    
                    if (index.map { firstThreeIndices.contains($0) } != nil){
                        CardView(item: item, isActive: item.id == audioPlayer.queue.first?.id,viewShouldBeFinalized: index.map { firstThreeIndices.contains($0) } ?? false)
                        //.redacted(reason: .placeholder)
                    }
                }
            }
        }
    }
}

struct CardStackView_Previews: PreviewProvider {
    static var previews: some View {
        CardStackView()
    }
}
