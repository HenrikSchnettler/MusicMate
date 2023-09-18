//
//  SkeletonCardView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 05.08.23.
//

import SwiftUI

// Represents a placeholder view for cards, often used while actual content is loading.
struct SkeletonCardView: View {
    // Environment variable to check the current color scheme of the device (e.g. light or dark mode).
    @Environment(\.colorScheme) var colorScheme
    
    // State variable to set the color of the skeleton card.
    @State private var color: Color = .black
    // State variable for a slider within the skeleton card (though its functionality in this context is unclear).
    @State private var sliderValue: Double = 0

    var body: some View {
        VStack{
            GeometryReader { cardGeometry in
                VStack {
                    // Applies a blur effect to the entire card and give it the cutom shimmer view modifier.
                    VisualEffectView(effect: UIBlurEffect(style: .light))
                        .frame(width: cardGeometry.size.width, height: cardGeometry.size.height)
                        .shimmer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                GeometryReader { cardOverlayGeometry in
                    VStack {
                        // Represents the artwork placeholder.
                        HStack(alignment: .center){
                            GeometryReader { artWorkOverlayGeometry in
                                VisualEffectView(effect: UIBlurEffect(style: .light))
                                    .redacted(reason: .placeholder) // Redaction to show a placeholder style.
                                    .cornerRadius(16)
                                    .frame(width: artWorkOverlayGeometry.size.width, height: artWorkOverlayGeometry.size.width)
                            }
                        }
                        .padding()
                        .frame(width: cardOverlayGeometry.size.width, height: cardOverlayGeometry.size.height * 0.67)
                        
                        // Slider placeholder.
                        HStack(alignment: .bottom){
                            Slider(value: $sliderValue, in: 0...100)
                            .padding(.horizontal)
                        }
                        .frame(width: cardOverlayGeometry.size.width, height: cardOverlayGeometry.size.height * 0.080)
                        
                        // Bottom section of the card, containing song info.
                        VisualEffectView(effect: UIBlurEffect(style: .light))
                            .frame(width: cardOverlayGeometry.size.width, height: cardOverlayGeometry.size.height * 0.23)
                            .shadow(radius: 20)
                            .overlay(
                                GeometryReader { songInfoOverlayGeometry in
                                    HStack(alignment: .center){
                                        // Play button placeholder.
                                        VStack(alignment: .leading){
                                            Button(action: {
                                                // Action when the button is tapped. Currently empty.
                                            }) {
                                                Image(systemName: "play.circle.fill")
                                                    .resizable()
                                                    .redacted(reason: .placeholder)
                                                    .foregroundColor(Color.white)
                                                    .cornerRadius(30)
                                                    .frame(width: songInfoOverlayGeometry.size.height * 0.5, height: songInfoOverlayGeometry.size.height * 0.5)
                                                    .fixedSize(horizontal: true, vertical: true)
                                                    .shadow(radius: 20)
                                            }
                                        }
                                        .frame(width: 50)
                                        .padding(.leading,20)
                                        .padding(.trailing,10)
                                        
                                        // Song title and artist name placeholders.
                                        VStack(alignment: .leading){
                                            Text("Placeholder Song Title")
                                                .redacted(reason: .placeholder)
                                                .font(.headline)
    
                                            Text("Placeholder Artist")
                                                .redacted(reason: .placeholder)
                                                .font(.subheadline)
                                        }
                                        .padding(.leading,10)
                                        .padding(.trailing,20)
                                        .foregroundColor(Color.white)
                                        
                                        Spacer()
                                    }
                                    .frame(width: songInfoOverlayGeometry.size.width, height: songInfoOverlayGeometry.size.height)
                                }
                                
                            )
                    }
                }
            )
            .overlay(
                GeometryReader { cardOverlayGeometry in
                    Group{
                        // If the color scheme is dark, apply a specific style to the card.
                        if colorScheme == .dark {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.3), lineWidth: cardOverlayGeometry.size.height * 0.01)
                        }
                    }
                }
            )
        }
        .background(Color.black)
        .cornerRadius(16)
        .shadow(radius: 4)
        .foregroundColor(color.opacity(1))
        .padding()
        // This view is disabled to prevent user interaction.
        .disabled(true)
    }
}

struct SkeletonCardView_Previews: PreviewProvider {
    static var previews: some View {
        SkeletonCardView()
    }
}
