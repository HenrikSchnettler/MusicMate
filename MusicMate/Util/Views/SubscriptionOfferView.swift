//
//  SubscriptionOfferView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 25.06.23.
//

import SwiftUI
import MusicKit

// A view to present Apple Music subscription offers.
struct SubscriptionOfferView: View {
    // Manages interaction with MusicKit.
    @EnvironmentObject var musicKitManager: MusicKitManager
    // State variable to determine if the offer view is currently showing.
    @State var isShowingOffer = false

    // Subscription offer options configuration.
    var offerOptions: MusicSubscriptionOffer.Options {
        var offerOptions = MusicSubscriptionOffer.Options()
        // Uncomment the line below if you want to specify a particular album ID.
        //offerOptions.itemID = album.id
        return offerOptions
    }

    // Main body of the SubscriptionOfferView.
    var body: some View {
        // A button to trigger the display of subscription offers.
        Button("Show Subscription Offers", action: showSubscriptionOffer)
            // Disables the button if the user can't become a subscriber.
            .disabled(!(musicKitManager.musicSubscription?.canBecomeSubscriber ?? false))
            // Presents the music subscription offer when `isShowingOffer` is true.
            .musicSubscriptionOffer(isPresented: $isShowingOffer, options: offerOptions)
    }

    // Function to set `isShowingOffer` to true, which triggers the display of the subscription offer.
    func showSubscriptionOffer() {
        isShowingOffer = true
    }
}

struct SubscriptionOfferView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionOfferView()
    }
}

