//
//  LoadingView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 21.06.23.
//

import SwiftUI

struct LoadingView: View {
    @State private var isLoading = true

    var body: some View {
        ProgressView("loading...")
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
