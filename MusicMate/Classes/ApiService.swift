//
//  ApiService.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 20.06.23.
//

import Foundation
import Combine

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

class APIService {
    static let shared = APIService()
    
    private init() {}
    
    func request(url: URL, method: HTTPMethod, parameters: [String: Any]? = nil) -> Future<Data, Error> {
        return Future { promise in
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            if let parameters = parameters {
                request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    promise(.failure(error))
                } else if let data = data {
                    promise(.success(data))
                } else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred."])
                    promise(.failure(error))
                }
            }
            task.resume()
        }
    }
}

