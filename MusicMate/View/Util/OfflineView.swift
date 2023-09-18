//
//  OfflineView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 06.08.23.
//

import SwiftUI

struct OfflineView: View {
    // This is the main body of the OfflineView
    var body: some View {
        // Vertical stack that contains all the elements
        VStack(alignment: .center){
            
            // Text that indicates the user is offline
            Text("You are offline")
                .font(.largeTitle)   // Sets the font size to "largeTitle"
                .bold()              // Makes the text bold
                .padding(.bottom)    // Adds padding to the bottom of the text
            
            // Subtext providing instructions on how to connect to the internet
            Text("Please disable flight mode or connect to WIFI")
                .multilineTextAlignment(.center)    // Centers the text when it wraps across multiple lines
                .font(.headline)                    // Sets the font size to "headline"
                .foregroundColor(Color(UIColor.secondaryLabel)) // Sets the text color to the secondary label color of the current theme
            
        }
        .padding()    // Adds padding to the VStack, providing space around its content
    }
}


struct OfflineView_Previews: PreviewProvider {
    static var previews: some View {
        OfflineView()
    }
}
