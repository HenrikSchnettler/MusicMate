//
//  LoginInfoView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 25.06.23.
//

import SwiftUI

// Represents a view providing information about logging into an iCloud account.
struct LoginInfoView: View {
    // Main body of the LoginInfoView.
    var body: some View {
        // A vertical stack containing all elements.
        VStack {
            
            // A title text prompting the user to log in.
            Text("Please login into your iCloud account")
                .font(.title)   // Sets the font size to "title"
                .padding()      // Adds padding around the text.
            
            // A detailed description about the necessity of logging in for the app to function.
            Text("In order for MusicMate to work properly, please log into your iCloud account on this device!")
                .padding()      // Adds padding around the text.
            
        }
        .padding()            // Adds padding around the VStack, providing space around its content.
    }
}


struct LoginInfoView_Previews: PreviewProvider {
    static var previews: some View {
        LoginInfoView()
    }
}
