//
//  OfflineView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 06.08.23.
//

import SwiftUI

struct OfflineView: View {
    var body: some View {
        VStack(alignment: .center){
            Text("You are offline")
                .font(.largeTitle)
                .bold()
                .padding(.bottom)
            Text("Please disable flight mode or connect to WIFI")
                .multilineTextAlignment(.center)
                .font(.headline)
                .foregroundColor(Color(UIColor.secondaryLabel))
        }
        .padding()
    }
}

struct OfflineView_Previews: PreviewProvider {
    static var previews: some View {
        OfflineView()
    }
}
