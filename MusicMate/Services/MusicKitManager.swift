//
//  MusicKitManager.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 03.06.23.
//

import Foundation
import MusicKit
import StoreKit
import Combine

// A class that manages interactions with the Apple Music API and provides functionality for music playback and user profiles.
@MainActor //Ensure updates are on the main thread
class MusicKitManager: ObservableObject {
    /// The shared singleton instance of `MusicKitManager`.
    static let shared = MusicKitManager()

    /// An instance of `KeychainService` for securely managing sensitive data.
    private let keychainService = KeychainService()

    // MARK: - Published Properties

    /// Indicates whether the initial authorization has been completed.
    @Published var initalAuthentificationComplete = false
    /// Indicates the authorization status for accessing MusicKit.
    @Published var isAuthorizedForMusicKit: Bool = false
    /// Holds the user's music subscription details.
    @Published var musicSubscription: MusicSubscription?
    
    // MARK: - Initializer

    /// Private initializer to ensure only one instance is created (Singleton).
    private init() {
        Task {
            await self.performInitialAuthorization()
            self.initalAuthentificationComplete = true
        }
    }

    // MARK: - Authorization

    /// Performs the initial authorization process for the Apple Music API.
    private func performInitialAuthorization() async -> Void {
        await self.requestMusicAuthorization()
        self.getUserCapabilities()
    }

    /// Requests authorization to access Apple Music.
    private func requestMusicAuthorization() async {
        let authorizationStatus = await MusicAuthorization.request()
        self.isAuthorizedForMusicKit = authorizationStatus == .authorized
    }

    /// Subscribes to and listens for updates related to the user's music subscription capabilities.
    private func getUserCapabilities() {
        Task {
            for await subscription in MusicSubscription.subscriptionUpdates {
                self.musicSubscription = subscription
            }
        }
    }
    
    // MARK: - Music Data Fetching

    /// Fetches the ID of the user's personal music station.
    ///
    /// - Returns: The `MusicItemID` of the user's personal station.
    func getUsersPersonalStationId() async -> MusicItemID?{
        do{
            //the country code of the user which is needed to access the right catalog of apple music
            let countryCode = try await MusicDataRequest.currentCountryCode
            
            let url = URL(string: "https://api.music.apple.com/v1/me/recommendations/")!

            let dataRequest = MusicDataRequest(urlRequest: URLRequest(url: url))
            let dataResponse = try await dataRequest.response()

            let decoder = JSONDecoder()
            let stationResponse = try decoder.decode(MusicPersonalRecommendationsResponse.self, from: dataResponse.data)
           
            // loop over all section inside the response object since we can´t identify which is the searched section
            for section in stationResponse.recommendations {
                // loop over all stations inside the current section
                for station in section.stations {
                    // Regex pattern which should match the users personal exploration station
                    let regexPattern = "^ra\\.q-GAI6I[a-zA-Z0-9]{22}xYWJiNzBmZjc1N2FhOTVm$"
                    if let _ = station.id.rawValue.range(of: regexPattern, options: .regularExpression) {
                        // Return personal station id
                        return station.id
                    }
                }
            }
            
            return nil
        }
        catch{
            print("Error: \(error)")
            return nil
        }
    }
    
    /// Fetches the user's social profile from the Apple Music API. (Not ready yet)
    func getUsersSocialProfile() async -> Void{
        do{
            let url = URL(string: "https://api.music.apple.com/v1/me/account")!

            let dataRequest = MusicDataRequest(urlRequest: URLRequest(url: url))
            let dataResponse = try await dataRequest.response()

            let decoder = JSONDecoder()
            let stationResponse = try decoder.decode(SocialProfileResponse.self, from: dataResponse.data)
            print("TEST")
        }
        catch{
            print("Error: \(error)")
        }
    }
    
    /// Fetches the next set of tracks for a given music station.
    ///
    /// - Parameters:
    ///   - stationId: The ID of the music station.
    ///   - trackFoundCallback: A callback executed when a new track is found.
    func getStationsNextTracks(stationId: MusicItemID, trackFoundCallback: @escaping (Track) -> Void) async {
        do {
            //the country code of the user which is needed to access the right catalog of apple music
            let countryCode = try await MusicDataRequest.currentCountryCode

            let url = URL(string: "https://api.music.apple.com/v1/me/stations/next-tracks/\(stationId)?limit=10&include=albums&extend=editorialVideo")!
            var urlRequest = URLRequest(url: url)
            //httpMethod must be POST as seen in the network request from the apple music web app
            urlRequest.httpMethod = "POST"

            let dataRequest = MusicDataRequest(urlRequest: urlRequest)

            let dataResponse = try await dataRequest.response()

            let decoder = JSONDecoder()
            let trackResponse = try decoder.decode(TrackResponse.self, from: dataResponse.data)
            for item in trackResponse.data {
                //we dont have to check anymore if the song is already in the users library or playlist since the new endpoint already excludes added songs
                trackFoundCallback(item)
            }
        }
        catch {
            print("Error: \(error)")
        }
    }
    
    /// Fetches an album by its ID.
    ///
    /// - Parameters:
    ///   - songId: The ID of the song from which to retrieve the associated album.
    ///   - completion: A callback executed upon fetching the album or encountering an error.
    func getAlbumByID(songId: MusicItemID, completion: @escaping (Result<ExtendedAlbum, Error>) -> Void) async {
        do{
            //the country code of the user which is needed to access the right catalog of apple music
            let countryCode = try await MusicDataRequest.currentCountryCode
            //the superior developer token which is used to get the dynamic album art for the songs (used for personal use only)
            let superiorDeveloperToken = "Bearer eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IldlYlBsYXlLaWQifQ.eyJpc3MiOiJBTVBXZWJQbGF5IiwiaWF0IjoxNzI0MDk1NzA5LCJleHAiOjE3MzEzNTMzMDksInJvb3RfaHR0cHNfb3JpZ2luIjpbImFwcGxlLmNvbSJdfQ.upq7QFkHN3etQVMycsuIlNYz8ElqqZeNCZ2OJUTHie2IbRiExsZJejLdQgv0JysNSu-w63IcOW6GCVbImMV3Zw"
            let url = URL(string: "https://amp-api.music.apple.com/v1/catalog/\(countryCode)/songs/\(songId)/albums?extend=editorialArtwork,editorialVideo,extendedAssetUrls,offers")!
            var urlRequest = URLRequest(url: url)
            
            urlRequest.httpMethod = "GET"
            
            //the superior developer token is sent via the Authorization header
            urlRequest.setValue(superiorDeveloperToken, forHTTPHeaderField: "Authorization")
            
            //the origin has to be set to the apple music web app in order for the dev token to work
            urlRequest.setValue("https://music.apple.com", forHTTPHeaderField: "Origin")
            
            let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                // Error Handling
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Ensure we have data
                guard let data = data else {
                    completion(.failure(NSError(domain: "dataNilError", code: -10001, userInfo: nil)))
                    return
                }
                
                // Decode JSON
                do {
                    let decoder = JSONDecoder()
                    //the response is encoded into the cusotm ExtendedAlbumResponse Model which is a extension of the MusicKit model with extra fields like the dynamic album cover
                    let albumResponse = try decoder.decode(ExtendedAlbumResponse.self, from: data)
                    completion(.success(albumResponse.data.first!))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        }
        catch{
            print("Error: \(error)")
        }
    }
    
    /// Checks if a particular song is already present in the user's personal library.
    ///
    /// - Parameters:
    ///   - songId: The ID of the song to check.
    ///
    /// - Returns: A Boolean value indicating whether the song is in the user's library.
    func checkIfSongIsInUserLibrary(songId: String) async -> Bool {
        do {
            //the country code of the user which is needed to access the right catalog of apple music
            let countryCode = try await MusicDataRequest.currentCountryCode

            let libURL = URL(string: "https://api.music.apple.com/v1/catalog/\(countryCode)/songs/\(songId)/library?relate=library")!

            let request = MusicDataRequest(urlRequest: URLRequest(url: libURL))

            let dataResponse = try await request.response()
            
            let decoder = JSONDecoder()
            
            let trackResponse = try decoder.decode(SongResponse.self, from: dataResponse.data)
            
            return true
        } catch {
            print("Error: \(error)")
            return false
        }
    }
}
