//
//  MusicKitManager.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 03.06.23.
//

import Foundation
import MusicKit
import StoreKit

class MusicKitManager {
    private let keychainService = KeychainService()
    private let developerTokenKey = "MUSICKIT_API_DEVTOKEN"
    private let apiToken = Bundle.main.object(forInfoDictionaryKey: "NODEJS_API_TOKEN") as? String
    private let controller = SKCloudServiceController()
    
    func performFullAuthorization() -> Void {
        self.checkAppleMusicAccess() { accessIsGranted in
            if(accessIsGranted)
            {
                self.checkUserCapabilities(){capability, error in
                    if(self.isDeveloperTokenStored())
                    {
                        //if the developer token is avaiable the user token should be reuqested to check if the developerToken is still valid
                        self.requestUserToken(){userToken, error in
                            if(error != nil)
                            {
                                //if there is a error with the rquest the developer token should be requested once again
                                self.fetchDeveloperToken(){ devtoken, error in
                                }
                            }
                        }
                    }
                    else{
                        //if the developer token isnt avaible in keychain it should be requested from the musicmate api
                        self.fetchDeveloperToken(){ devtoken, error in
                        }
                    }
                }
            }
            else{
                //If access isnt granted the user is asked to do it
                self.requestAppleMusicAccess() { grantSuccessfull in
                    if(grantSuccessfull)
                    {
                        self.checkUserCapabilities(){capability, error in
                            if(self.isDeveloperTokenStored())
                            {
                                //if the developer token is avaiable the user token should be reuqested to check if the developerToken is still valid
                                self.requestUserToken(){userToken, error in
                                    if(error != nil)
                                    {
                                        //if there is a error with the rquest the developer token should be requested once again
                                        self.fetchDeveloperToken(){ devtoken, error in
                                        }
                                    }
                                }
                            }
                            else{
                                //if the developer token isnt avaible in keychain it should be requested from the musicmate api
                                self.fetchDeveloperToken(){ devtoken, error in
                                }
                            }
                        }
                    }
                    else{
                        //The user should be alerted that the app only works with apple music access
                    }
                }
            }
        }
    }
    
    private func checkAppleMusicAccess(completion: @escaping (Bool) -> Void) {
        let status = SKCloudServiceController.authorizationStatus()

        switch status {
            case .authorized:
                print("Access to Apple Music granted.")
                completion(true)
            case .denied, .restricted:
                print("Access to Apple Music denied or restricted.")
                completion(false)
            case .notDetermined:
                print("Access to Apple Music not determined.")
                completion(false)
            @unknown default:
                print("Unknown authorization status for Apple Music.")
                completion(false)
        }
    }
    
    private func requestAppleMusicAccess(completion: @escaping (Bool) -> Void) {
        SKCloudServiceController.requestAuthorization { status in
            switch status {
                case .authorized:
                    print("authorized")
                    completion(true)
                default:
                    print("authorization denied or restricted")
                    completion(false)
            }
        }
    }
    
    private func checkUserCapabilities(completion: @escaping (SKCloudServiceCapability,Error?) -> Void) {
        self.controller.requestCapabilities { (capability, error) in
                if let error = error {
                    print("An error occurred when requesting capabilities: \(error.localizedDescription)")
                    return
                }
                
                let defaults = UserDefaults.standard
                
                switch capability {
                case .musicCatalogPlayback:
                    defaults.set(true, forKey: "activeAppleMusicMembership")
                default:
                    defaults.set(false, forKey: "activeAppleMusicMembership")
                }
                
                completion(capability, error)
        }
    }

    private func requestUserToken(completion: @escaping (String?, Error?) -> Void) {
        let developerToken = self.getDeveloperTokenFromKeychain() ?? ""
        
        self.controller.requestUserToken(forDeveloperToken: developerToken) { (userToken, error) in
                if let error = error {
                    print("An error occurred when requesting the user token: \(error)")
                    
                    let nsError = error as NSError
                    if nsError.domain == SKErrorDomain && nsError.code == SKError.cloudServiceNetworkConnectionFailed.rawValue {
                        print("The developer token may be expired or invalid.")
                        completion(nil, nsError)
                    }
                } else if let userToken = userToken {
                    completion(userToken, nil)
                }
            }
    }

    private func fetchDeveloperToken(completion: @escaping (String?, Error?) -> Void) {
        let url = URL(string: "https://api.musicmate.schnettler.dev/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(self.apiToken!, forHTTPHeaderField: "authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
            } else if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])

                    if let jsonDict = json as? [String: Any], let developerToken = jsonDict["developerToken"] as? String {
                        self.keychainService.save(key: self.developerTokenKey, value: developerToken)
                        completion(developerToken, nil)
                    } else {
                        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Received unexpected JSON format"])
                        completion(nil, error)
                    }
                } catch {
                    let developerToken = String(decoding: data, as: UTF8.self)
                    self.keychainService.save(key: self.developerTokenKey, value: developerToken)
                    completion(developerToken, nil)
                }
            }
        }

        task.resume()
    }

    
    private func isDeveloperTokenStored() -> Bool {
        if(self.getDeveloperTokenFromKeychain() == nil)
        {
            return false
        }
        else{
            return true
        }
    }
    
    private func getDeveloperTokenFromKeychain() -> String? {
        return keychainService.get(key: developerTokenKey)
    }
}
