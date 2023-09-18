//
//  ShimmerView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 05.08.23.
//

import SwiftUI

// Configuration structure for the shimmer effect.
public struct ShimmerConfiguration {
    // Gradient used for the shimmer effect.
    public let gradient: Gradient
    // Starting positions for the gradient (used when the shimmer starts).
    public let initialLocation: (start: UnitPoint, end: UnitPoint)
    // Ending positions for the gradient (used when the shimmer completes).
    public let finalLocation: (start: UnitPoint, end: UnitPoint)
    // Duration of the shimmer animation.
    public let duration: TimeInterval
    // Opacity of the shimmering gradient.
    public let opacity: Double
    
    // Default shimmer configuration.
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

// A view that provides a shimmering effect to its content.
struct ShimmeringView<Content: View>: View {
    // Content that should be shimmered.
    private let content: () -> Content
    // Configuration for the shimmer effect.
    private let configuration: ShimmerConfiguration
    // State variables to animate the shimmer's starting and ending points.
    @State private var startPoint: UnitPoint
    @State private var endPoint: UnitPoint
    
    // Initializer for the ShimmeringView.
    init(configuration: ShimmerConfiguration, @ViewBuilder content: @escaping () -> Content) {
        self.configuration = configuration
        self.content = content
        // Initialize the starting and ending points with the initial locations.
        _startPoint = .init(wrappedValue: configuration.initialLocation.start)
        _endPoint = .init(wrappedValue: configuration.initialLocation.end)
    }
    
    // The body of the shimmering view.
    var body: some View {
        // A ZStack layers the content and the shimmer effect.
        ZStack {
            // The original content.
            content()
            // LinearGradient provides the shimmer effect.
            LinearGradient(
                gradient: configuration.gradient,
                startPoint: startPoint,
                endPoint: endPoint
            )
            // Adjust the opacity of the shimmering gradient.
            .opacity(configuration.opacity)
            // Blend mode makes the shimmer effect blend with the content.
            .blendMode(.screen)
            // On appearance, animate the shimmer effect continuously.
            .onAppear {
                withAnimation(Animation.linear(duration: configuration.duration).repeatForever(autoreverses: false)) {
                    startPoint = configuration.finalLocation.start
                    endPoint = configuration.finalLocation.end
                }
            }
        }
    }
}

// A ViewModifier to apply the shimmer effect to a view.
public struct ShimmerModifier: ViewModifier {
    let configuration: ShimmerConfiguration
    
    public func body(content: Content) -> some View {
        // Wraps the given content inside the ShimmeringView.
        ShimmeringView(configuration: configuration) { content }
    }
}

// View extension to easily apply shimmer effect to any view.
public extension View {
    // Function to apply the shimmer effect to the view.
    func shimmer(configuration: ShimmerConfiguration = .default) -> some View {
        modifier(ShimmerModifier(configuration: configuration))
    }
}
