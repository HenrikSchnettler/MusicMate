//
//  Responses.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 16.01.24.
//

import Foundation
import MusicKit

// MARK: - Simple Response Models

/// Represents the response for fetching station details.
struct StationResponse: Decodable {
    let data: [Station]
}

/// Represents the response for fetching track details.
struct TrackResponse: Decodable {
    let data: [Track]
}

/// Represents the response for fetching song details.
struct SongResponse: Decodable {
    let data: [Song]
}

/// Represents the response for fetching album details.
struct AlbumResponse: Decodable {
    let data: [Album]
}

/// Represents the response for fetching track IDs.
struct TrackIdResponse: Decodable {
    let data: [Track.ID]
}
