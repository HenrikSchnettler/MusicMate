//
//  ExploreView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 28.06.23.
//

import SwiftUI
import AVKit

struct ExploreView: View {
    var body: some View {
        VStack {
            ShimmerView()
        }
    }
}

struct ShimmerView: View {
    @State private var gradientStart: UnitPoint = .leading
    @State private var gradientEnd: UnitPoint = .trailing

    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.2), Color.gray.opacity(0.5)]), startPoint: gradientStart, endPoint: gradientEnd)
            .mask(
                VStack(alignment: .leading, spacing: 10) {
                    Circle()
                        .frame(width: 100, height: 100)
                    Rectangle()
                        .frame(height: 20)
                    Rectangle()
                        .frame(height: 20)
                }
                .padding()
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                    gradientStart = .leading
                    gradientEnd = .trailing
                }
            }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
