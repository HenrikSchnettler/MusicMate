//
//  HomeView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 27.04.23.
//

import SwiftUI
import MusicKit
import AVFoundation
import AVKit

struct HomeView: View {
    //MusicKitManager object
    @EnvironmentObject var musicKitManager: MusicKitManager
    //the personal station of the user
    @State var personalStation: Station?
    //object of class which connects to the player which can stream the preview of the songs
    @StateObject var audioPlayer = AudioPlayer(player: AVQueuePlayer())
    
    var body: some View {
        VStack{
            if audioPlayer.queueCount > 0
            {
                CardStackView()
                    .environmentObject(audioPlayer)
                    .onAppear {
                        if audioPlayer.queueCount > 0 {
                            audioPlayer.play()
                        }
                    }
            }
            else{
                //if personal station isnt loaded yet there should be a loading animation
                LoadingView()
            }
        }
        .onDisappear{
            if audioPlayer.queueCount > 0
            {
                audioPlayer.pause()
            }
        }
        .onAppear{
            if audioPlayer.queueCount > 0
            {
                audioPlayer.play()
            }
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
