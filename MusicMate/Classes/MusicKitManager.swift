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

class MusicKitManager: ObservableObject {
    //reference to the singleton is reachable over the static constant of the class
    static let shared = MusicKitManager()
    
    private init() {
        // full authorization is made on init
        self.performInitialAuthorization()
    }
    
    //Keychain service in initalized
    private let keychainService = KeychainService()
    
    //The following variables notify the view if they update to it can refresh
    //@Published var authorizationStatus = SKCloudServiceAuthorizationStatus.notDetermined
    @Published var activeAppleMusicMembership = false
    @Published var initalAuthentificationComplete = false
    @Published var appleMusicAccessGrantedByUser = false
    
    private func performInitialAuthorization() -> Void {
        self.checkAppleMusicAccess() { accessIsGranted in
            if(!accessIsGranted)
            {
                //If access isnt granted the user is asked to do it
                self.requestAppleMusicAccess() { grantSuccessfull in
                    if(!grantSuccessfull)
                    {
                        //The user should be alerted that the app only works with apple music access
                    }
                    else{
                        self.checkUserCapabilities(){capability, error in
                        }
                    }
                }
            }
            else{
                self.checkUserCapabilities(){capability, error in
                }
            }
            self.initalAuthentificationComplete = true
        }
    }
    
    private func checkAppleMusicAccess(completion: @escaping (Bool) -> Void) {
        let status = SKCloudServiceController.authorizationStatus()

        switch status {
            case .authorized:
                print("Access to Apple Music granted.")
                self.appleMusicAccessGrantedByUser = true
                completion(true)
            case .denied, .restricted:
                print("Access to Apple Music denied or restricted.")
                self.appleMusicAccessGrantedByUser = false
                completion(false)
            case .notDetermined:
                print("Access to Apple Music not determined.")
                self.appleMusicAccessGrantedByUser = false
                completion(false)
            @unknown default:
                print("Unknown authorization status for Apple Music.")
                self.appleMusicAccessGrantedByUser = false
                completion(false)
        }
    }
    
    private func requestAppleMusicAccess(completion: @escaping (Bool) -> Void) {
        SKCloudServiceController.requestAuthorization { status in
            switch status {
                case .authorized:
                    print("authorized")
                    self.appleMusicAccessGrantedByUser = true
                    completion(true)
                default:
                    print("authorization denied or restricted")
                    self.appleMusicAccessGrantedByUser = false
                    completion(false)
            }
        }
    }
    
    private func checkUserCapabilities(completion: @escaping (SKCloudServiceCapability,Error?) -> Void) {
        SKCloudServiceController().requestCapabilities { (capability, error) in
                if let error = error {
                    print("An error occurred when requesting capabilities: \(error.localizedDescription)")
                    return
                }
                
                let defaults = UserDefaults.standard
                
                switch capability {
                case .musicCatalogPlayback:
                    defaults.set(true, forKey: "activeAppleMusicMembership")
                    self.activeAppleMusicMembership = true
                default:
                    defaults.set(false, forKey: "activeAppleMusicMembership")
                    self.activeAppleMusicMembership = false
                }
                
                completion(capability, error)
        }
    }
}
