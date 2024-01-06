//
//  DestinationItem.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 09.09.23.
//

import Foundation
import MusicKit

struct DestinationItem: Hashable {
    let id: MusicItemID?
    let name: String
    let isLibrary: Bool
}
