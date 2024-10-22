//
//  CardStackView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 12.07.23.
//

import SwiftUI

struct CardStackView: View {
    // ViewModel instance to manage the data and logic for the card stack.
    @ObservedObject var vm: CardStackViewModel

    var body: some View {
        VStack {
            ZStack { // ZStack layers the cards on top of each other.
                // Loops over the reversedQueue of card items from the ViewModel to display the correct display order.
                ForEach(vm.reversedQueue, id: \.id) { item in
                    // Each item in the queue is presented as a CardView.
                    CardView(
                        item: item, // Passes the current item to the CardView.
                        isActive: vm.isActive(item: item), // Determines if the current card is active based on the ViewModel logic.
                        viewShouldBeFinalized: vm.viewShouldBeFinalized(for: item) // Determines if the view should be finalized based on the ViewModel logic.
                    )
                }
            }
        }
    }
}
