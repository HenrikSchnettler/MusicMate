//
//  RecommendationModeItem.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 19.10.24.
//

import Foundation

struct RecommendationModeItem: Hashable {
    let id: Int
    let displayText: String
    let action: RecommendationModeAction
}

enum RecommendationModeAction: String {
    case publicMode = "publicMode"
    case personalMode = "personalMode"
}
