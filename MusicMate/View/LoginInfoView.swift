//
//  LoginInfoView.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 25.06.23.
//

import SwiftUI

struct LoginInfoView: View {
    var body: some View {
        VStack{
            Text("Please login into your iCloud account")
                .font(.title)
                .padding()
            Text("In order for MusicMate to work properly, please log into your iCloud account on this device!")
                .padding()
        }
        .padding()
    }
}

struct LoginInfoView_Previews: PreviewProvider {
    static var previews: some View {
        LoginInfoView()
    }
}
