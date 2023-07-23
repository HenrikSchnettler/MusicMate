//
//  CardStackView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 12.07.23.
//

import SwiftUI

struct CardStackView: View {
    @EnvironmentObject var audioPlayer: AudioPlayer

    var body: some View {
        VStack {
            ZStack{
                ForEach(audioPlayer.queue.reversed(), id: \.id) { item in
                    CardView(item: item)
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
