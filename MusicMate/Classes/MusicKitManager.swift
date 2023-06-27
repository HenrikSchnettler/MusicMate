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
    func getUsersPersonalStationId() async -> String{
        do{
            let countryCode = try await MusicDataRequest.currentCountryCode
            
            let url = URL(string: "https://api.music.apple.com/v1/catalog/\(countryCode)/stations?filter[identity]=personal")!

            let dataRequest = MusicDataRequest(urlRequest: URLRequest(url: url))
            let dataResponse = try await dataRequest.response()

            let decoder = JSONDecoder()
            let stationResponse = try decoder.decode(StationResponse.self, from: dataResponse.data)
            
            return stationResponse.data[0].id.rawValue
        }
        catch{
            print("Error: \(error)")
            return ""
        }
    }
    
    struct StationResponse: Decodable {
        let data: [Station]
    }
}
