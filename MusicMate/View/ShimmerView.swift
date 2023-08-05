//
//  ShimmerView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 05.08.23.
//

import SwiftUI

public struct ShimmerConfiguration {
    public let gradient: Gradient
    public let initialLocation: (start: UnitPoint, end: UnitPoint)
    public let finalLocation: (start: UnitPoint, end: UnitPoint)
    public let duration: TimeInterval
    public let opacity: Double
    public static let `default` = ShimmerConfiguration(
        gradient: Gradient(stops: [
            .init(color: Color(UIColor.systemGray6), location: 0),
            .init(color: Color.gray, location: 0.3),
            .init(color: Color.gray, location: 0.7),
            .init(color: Color(UIColor.systemGray6), location: 1),
        ]),
        initialLocation: (start: UnitPoint(x: -1, y: 0.5), end: .leading),
        finalLocation: (start: .trailing, end: UnitPoint(x: 2, y: 0.5)),
        duration: 1,
        opacity: 0.8
    )
}

struct ShimmeringView<Content: View>: View {
    private let content: () -> Content
    private let configuration: ShimmerConfiguration
    @State private var startPoint: UnitPoint
    @State private var endPoint: UnitPoint
    
    init(configuration: ShimmerConfiguration, @ViewBuilder content: @escaping () -> Content) {
        self.configuration = configuration
        self.content = content
        _startPoint = .init(wrappedValue: configuration.initialLocation.start)
        _endPoint = .init(wrappedValue: configuration.initialLocation.end)
    }
    var body: some View {
        ZStack {
            content()
            LinearGradient(
                gradient: configuration.gradient,
                startPoint: startPoint,
                endPoint: endPoint
            )
                .opacity(configuration.opacity)
                .blendMode(.screen)
                .onAppear {
                    withAnimation(Animation.linear(duration: configuration.duration).repeatForever(autoreverses: false)) {
                        startPoint = configuration.finalLocation.start
                        endPoint = configuration.finalLocation.end
                    }
                }
        }
    }
}

public struct ShimmerModifier: ViewModifier {
    let configuration: ShimmerConfiguration
    public func body(content: Content) -> some View {
        ShimmeringView(configuration: configuration) { content }
    }
}

public extension View {
  func shimmer(configuration: ShimmerConfiguration = .default) -> some View {
    modifier(ShimmerModifier(configuration: configuration))
  }
}

struct ShimmerView_Previews: PreviewProvider {
    static var previews: some View {
        ShimmerView()
    }
}
