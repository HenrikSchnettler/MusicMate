//
//  ExtendedAlbum.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 31.07.23.
//

import Foundation
import MusicKit

// Define a root struct that includes the "data" key
struct ExtendedAlbumResponse: Codable {
    let data: [ExtendedAlbum]
}

// Define a struct for the individual albums that are included in "data"
struct ExtendedAlbum: Codable {
    let id: String
    let type: String
    let href: String
    let attributes: ExtendedAlbumAttributes
}

// Define a struct for the "attributes" key
struct ExtendedAlbumAttributes: Codable {
    let offers: [Offer]
    let copyright: String
    let genreNames: [String]
    let releaseDate: String
    let upc: String
    let isMasteredForItunes: Bool
    let artwork: Artwork
    let url: String
    let playParams: PlayParams
    let recordLabel: String
    let trackCount: Int
    let isCompilation: Bool
    let isPrerelease: Bool
    let audioTraits: [String]
    let editorialArtwork: EditorialArtwork?
    let isSingle: Bool
    let name: String
    let contentRating: String
    let artistName: String
    let editorialVideo: EditorialVideo?
    let isComplete: Bool
}

struct Offer: Codable {
    let buyParams: String
    let type: String
    let priceFormatted: String
    let price: Double
}

struct Artwork: Codable {
    let width: Int
    let url: String
    let height: Int
    let textColor3: String
    let textColor2: String
    let textColor4: String
    let textColor1: String
    let bgColor: String
    let hasP3: Bool
}

struct PlayParams: Codable {
    let id: String
    let kind: String
}

struct EditorialArtwork: Codable {
    let staticDetailTall: Artwork?
    let subscriptionHero: Artwork?
    let staticDetailSquare: Artwork?
    let storeFlowcase: Artwork?
}

struct EditorialVideo: Codable {
    let motionSquareVideo1x1: VideoDetail?
    let motionDetailTall: VideoDetail?
    let motionDetailSquare: VideoDetail?
}

struct VideoDetail: Codable {
    let previewFrame: Artwork
    let video: String
}
