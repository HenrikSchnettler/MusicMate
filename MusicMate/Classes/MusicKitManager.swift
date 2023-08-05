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

@MainActor
class MusicKitManager: ObservableObject {
    //reference to the singleton is reachable over the static constant of the class
    static let shared = MusicKitManager()
    
    //Keychain service in initalized
    private let keychainService = KeychainService()
    
    //The following variables notify the view if they update to it can refresh
    //@Published var authorizationStatus = SKCloudServiceAuthorizationStatus.notDetermined
    @Published var initalAuthentificationComplete = false
    @Published var isAuthorizedForMusicKit: Bool = false
    @Published var musicSubscription: MusicSubscription?
    
    //init of class
    private init() {
        Task{
            await self.performInitialAuthorization()
            self.initalAuthentificationComplete = true
        }
    }
    
    //Initial authorization
    private func performInitialAuthorization() async -> Void {
        await self.requestMusicAuthorization()
        self.getUserCapabilities()
    }
    
    //request apple music authorization
    private func requestMusicAuthorization() async {
        let authorizationStatus = await MusicAuthorization.request()
        if authorizationStatus == .authorized {
            self.isAuthorizedForMusicKit = true
        } else {
            self.isAuthorizedForMusicKit = false
        }
    }
    
    //task which subscribes to the subscription capabilities since its first calles and stays active
    private func getUserCapabilities() {
        Task{
            for await subscription in MusicSubscription.subscriptionUpdates {
                self.musicSubscription = subscription
            }
        }
    }
    
    //get the users personal station so we can play recommended songs for the user
    func getUsersPersonalStationId() async -> MusicItemID{
        do{
            let countryCode = try await MusicDataRequest.currentCountryCode
            
            let url = URL(string: "https://api.music.apple.com/v1/catalog/\(countryCode)/stations?filter[identity]=personal")!

            let dataRequest = MusicDataRequest(urlRequest: URLRequest(url: url))
            let dataResponse = try await dataRequest.response()

            let decoder = JSONDecoder()
            let stationResponse = try decoder.decode(StationResponse.self, from: dataResponse.data)
            
            return stationResponse.data[0].id
        }
        catch{
            print("Error: \(error)")
            return MusicItemID("")
        }
    }
    
    //get the users profile information
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
    
    //gets the next songs for a station because we dont want to play the station directly
    func getStationsNextTracks(stationId: MusicItemID, trackFoundCallback: @escaping (Track) -> Void) async {
        do {
            let countryCode = try await MusicDataRequest.currentCountryCode

            let url = URL(string: "https://api.music.apple.com/v1/me/stations/next-tracks/\(stationId)?limit=10&include=albums&extend=editorialVideo")!
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST" //httpMethod must be POST as seen in the network request from the apple music web app

            let dataRequest = MusicDataRequest(urlRequest: urlRequest)

            let dataResponse = try await dataRequest.response()

            let decoder = JSONDecoder()
            let trackResponse = try decoder.decode(TrackResponse.self, from: dataResponse.data)
            for item in trackResponse.data {
                if await !self.checkIfSongIsInUserLibrary(songId: item.id.rawValue) {
                    trackFoundCallback(item)
                }
            }
        }
        catch {
            print("Error: \(error)")
        }
    }
    
    func getAlbumByID(songId: MusicItemID, completion: @escaping (Result<ExtendedAlbum, Error>) -> Void) async {
        do{
            let countryCode = try await MusicDataRequest.currentCountryCode
            
            let url = URL(string: "https://amp-api.music.apple.com/v1/catalog/\(countryCode)/songs/\(songId)/albums?extend=editorialArtwork,editorialVideo,extendedAssetUrls,offers")!
            var urlRequest = URLRequest(url: url)
            
            urlRequest.httpMethod = "GET"
            
            
            urlRequest.setValue("Bearer eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IldlYlBsYXlLaWQifQ.eyJpc3MiOiJBTVBXZWJQbGF5IiwiaWF0IjoxNjkwNDA2ODM1LCJleHAiOjE2OTc2NjQ0MzUsInJvb3RfaHR0cHNfb3JpZ2luIjpbImFwcGxlLmNvbSJdfQ.seFShNhCiGuoj5qBOqECAoKBtKJF0wN-KaEj4HICJnExwXtnYabeb0jTSSrK1uez5b6XvYUOsx0pgARKm1AJQg", forHTTPHeaderField: "Authorization")
            
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
    
    func checkIfSongIsInUserLibrary(songId: String) async -> Bool {
        do {
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
    
    struct StationResponse: Decodable {
        let data: [Station]
    }
    
    struct TrackResponse: Decodable {
        let data: [Track]
    }
    
    struct SongResponse: Decodable {
        let data: [Song]
    }
    
    struct AlbumResponse: Decodable {
        let data: [Album]
    }
    
    struct TrackIdResponse: Decodable {
        let data: [Track.ID]
    }
}
