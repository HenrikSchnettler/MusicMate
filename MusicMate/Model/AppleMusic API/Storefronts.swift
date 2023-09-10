//
//  Storefronts.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 25.06.23.
//

import Foundation

struct StorefrontResponse: Codable {
    let data: [Storefront]
}

struct Storefront: Codable {
    let id: String
    let type: String
    let href: String
    let attributes: Attributes
}

struct Attributes: Codable {
    let name: String
    let defaultLanguageTag: String
    let supportedLanguageTags: [String]
    let explicitContentPolicy: String
}

