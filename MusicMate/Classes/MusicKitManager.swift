//
//  MusicKitManager.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 03.06.23.
//

import Foundation
import StoreKit

class MusicKitManager {
    private let keychainService = KeychainService()
    private let developerTokenKey = "developerToken"

    func fetchDeveloperToken(completion: @escaping (String?, Error?) -> Void) {
        let url = URL(string: "<#Your Node.js API URL#>")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("<#Your API Key#>", forHTTPHeaderField: "authorization")

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


    func getDeveloperTokenFromKeychain() -> String? {
        return keychainService.get(key: developerTokenKey)
    }
}
