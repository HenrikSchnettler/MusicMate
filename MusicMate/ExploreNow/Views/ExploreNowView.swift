//
//  HomeView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 27.04.…23.
//

import SwiftUI
import AVFoundation

struct ExploreNowView: View {
    // Environment property to monitor the app's scene phase.
    @Environment(\.scenePhase) var scenePhase
    // Environment property to access the current color scheme (light or dark mode) used by the system.
    @Environment(\.colorScheme) var colorScheme
    // StateObject ViewModel that holds the data and business logic for this view.
    @StateObject var vm: ExploreNowViewModel

    var body: some View {
        // GeometryReader is used to read the size of the entire view, allowing dynamic sizing of child components.
        GeometryReader { wholeViewGeometry in
            VStack {
                Group { // Group is used to conditionally present one of its child views.
                    if vm.audioPlayer.recommendationModeSelection != nil && vm.audioPlayer.destinationSelection != nil && vm.queueIsNotEmpty {
                        // CardStackView is presented if there are items in the queue.
                        CardStackView(vm: CardStackViewModel(audioPlayer: vm.audioPlayer))
                            .environmentObject(vm.audioPlayer) // Passes the audioPlayer as an environment object to the CardStackView.
                    } else {
                        // SkeletonCardView is shown as a placeholder when the queue is empty, indicating loading or empty state.
                        SkeletonCardView()
                    }
                }
                .frame(height: wholeViewGeometry.size.height * 0.81) // Sets the height of the Group to 81% of the whole view.

                Spacer()
            }
            .sheet(isPresented: $vm.showSheet) { // Presents a modal sheet based on the 'showSheet' boolean in the ViewModel.
                // SwipeHistoryView allows users to review their interaction history, such as swiped cards.
                SwipeHistoryView()
                    .environmentObject(vm.audioPlayer)
                    .presentationDetents([.fraction(0.175), .medium, .large]) // Configures the sheet's possible heights.
                    .interactiveDismissDisabled(true) // Disables dismissal of the sheet by dragging.
                    .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.175)))
                    .presentationCornerRadius(21) // Sets the corner radius for the sheet's presentation.
                    .presentationDragIndicator(.hidden) // Hides the drag indicator on the sheet.
            }
            .cornerRadius(0) // Sets the corner radius of the entire view to 0.
            .onDisappear {
                vm.pausePlayer() // Pauses the audio player when the view is no longer visible.
            }
            .onChange(of: scenePhase) { newScenePhase in
                vm.onScenePhaseChange(newScenePhase) // Calls a method in the ViewModel to handle scene phase changes.
            }
        }
    }
}
