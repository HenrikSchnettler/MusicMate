//
//  ViewOfShame.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 21.06.23.
//

import SwiftUI

struct ViewOfShame: View {
    // Main body of the ViewOfShame.
    var body: some View {
        // A vertical stack containing all elements.
        VStack {
            // A title text indicating missing permissions.
            Text("Missing permissions")
                .font(.title)   // Sets the font size to "title"
                .padding()      // Adds padding around the text.
            
            // A detailed description about the necessity of granting permissions.
            Text("In order for MusicMate to work properly, it needs permissions to access your Apple Music/Media data. Please come back after given permissions in the settings app!")
                .padding()      // Adds padding around the text.
            
            // A button to open the app's settings page in system preferences.
            Button(action: {
                // Attempt to construct the URL for the app settings page.
                if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                    // Open the app's settings page.
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }) {
                Text("Open Settings")
                    .font(.title)
                    .foregroundColor(.white)             // Sets text color to white
                    .padding()                           // Adds padding around the text
                    .background(Color.accentColor)       // Sets background color to the accent color
                    .cornerRadius(20)                    // Adds a rounded corner with a 20-point radius
            }
            
            // A button to close the app.
            Button(action: {
                // Send a suspend action to the app.
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                // After a delay of one second, close the app.
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    exit(EXIT_SUCCESS)
                })
            }) {
                Text("Close App")
                    .font(.title)
                    .foregroundColor(.white)             // Sets text color to white
                    .padding()                           // Adds padding around the text
                    .background(Color.red)               // Sets background color to red
                    .cornerRadius(20)                    // Adds a rounded corner with a 20-point radius
            }
        }
    }
}
