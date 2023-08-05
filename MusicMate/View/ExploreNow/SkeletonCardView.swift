//
//  SkeletonCardView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 05.08.23.
//

import SwiftUI

struct SkeletonCardView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var color: Color = .black
    @State private var sliderValue: Double = 0

    var body: some View {
        VStack{
            GeometryReader { cardGeometry in
                VStack {
                    VisualEffectView(effect: UIBlurEffect(style: .light))
                        .frame(width: cardGeometry.size.width, height: cardGeometry.size.height)
                        .shimmer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            //.overlay(
                //VisualEffectView(effect: UIBlurEffect(style: .dark))
                                //.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            //)
            .overlay(
                GeometryReader { cardOverlayGeometry in
                    VStack {
                        HStack(alignment: .center){
                            GeometryReader { artWorkOverlayGeometry in
                                VisualEffectView(effect: UIBlurEffect(style: .light))
                                    .redacted(reason: .placeholder)
                                    .cornerRadius(16)
                                    .frame(width: artWorkOverlayGeometry.size.width, height: artWorkOverlayGeometry.size.width)
                            }
                        }
                        .padding()
                        .frame(width: cardOverlayGeometry.size.width, height: cardOverlayGeometry.size.height * 0.67)
                        HStack(alignment: .bottom){
                            Slider(value: $sliderValue, in: 0...100)
                            .padding(.horizontal)
                            //.padding(.bottom, 10)
                        }
                        .frame(width: cardOverlayGeometry.size.width, height: cardOverlayGeometry.size.height * 0.080)
                        VisualEffectView(effect: UIBlurEffect(style: .light))
                            .frame(width: cardOverlayGeometry.size.width, height: cardOverlayGeometry.size.height * 0.23)
                            .shadow(radius: 20)
                            .overlay(
                                GeometryReader { songInfoOverlayGeometry in
                                        HStack(alignment: .center){
                                            VStack(alignment: .leading){
                                                Button(action: {
                                                    
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
                                            VStack(alignment: .leading){
                                                Text("Placeholder Song Title")
                                                    .redacted(reason: .placeholder)
                                                    .font(.headline)
                                                //Text(item.AppleMusicTrack?.albumTitle ?? "")
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
                        if colorScheme == .dark
                        {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.3), lineWidth: cardOverlayGeometry.size.height * 0.01)
                        }
                    }
                }
            )
        }
        //.background(Color(UIColor.systemBackground))
        .background(Color.black)
        .cornerRadius(16)
        .shadow(radius: 4)
        .foregroundColor(color.opacity(1))
        .padding()
        //view should only be interactable if it is marked active
        .disabled(true)
    }
}

struct SkeletonCardView_Previews: PreviewProvider {
    static var previews: some View {
        SkeletonCardView()
    }
}
