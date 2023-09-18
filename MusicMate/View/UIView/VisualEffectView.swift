//
//  VisualEffectView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 05.08.23.
//

import SwiftUI

// A SwiftUI view that represents a UIVisualEffectView from UIKit to display visual effects.
struct VisualEffectView: UIViewRepresentable {

    // The visual effect to be applied. It can be `nil` to represent no effect.
    var effect: UIVisualEffect?
    
    /// Creates the UIVisualEffectView for use in SwiftUI.
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        // Initializes a new instance of UIVisualEffectView.
        return UIVisualEffectView()
    }
    
    /// Updates the created UIVisualEffectView instance with the specified effect.
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        // Apply the provided visual effect to the UIVisualEffectView.
        uiView.effect = effect
    }
}

