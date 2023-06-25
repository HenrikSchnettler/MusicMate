//
//  SubscriptionOfferView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 25.06.23.
//

import SwiftUI
import MusicKit

struct SubscriptionOfferView: View {
    //view for showing apple music subscription offer view
    @EnvironmentObject var musicKitManager: MusicKitManager
    @State var isShowingOffer = false

    var offerOptions: MusicSubscriptionOffer.Options {
        var offerOptions = MusicSubscriptionOffer.Options()
        //offerOptions.itemID = album.id
        return offerOptions
    }

    var body: some View {
        Button("Show Subscription Offers", action: showSubscriptionOffer)
            .disabled(!(musicKitManager.musicSubscription?.canBecomeSubscriber ?? false))
            .musicSubscriptionOffer(isPresented: $isShowingOffer, options: offerOptions)
    }

    func showSubscriptionOffer() {
        isShowingOffer = true
    }
}

struct SubscriptionOfferView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionOfferView()
    }
}
