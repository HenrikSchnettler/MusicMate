//
//  ViewOfShame.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 21.06.23.
//

import SwiftUI

struct ViewOfShame: View {
    var body: some View {
        VStack {
            Text("Missing permissions")
                .font(.title)
                .padding()
            Text("In order for MusicMate to work properly, it needs permissions to access your Apple Music/Media data. Please come back after given permissions in the settings app!")
                .padding()
            
            Button(action: {
                // app should be closed on click
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    exit(EXIT_SUCCESS)
                })
            }) {
                Text("Close App")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.themeAccent)
                    .cornerRadius(20)
            }
        }
    }
}
