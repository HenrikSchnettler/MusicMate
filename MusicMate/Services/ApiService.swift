//
//  ApiService.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 20.06.23.
//

import Foundation
import Combine

// all relevant http methods
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

//This class provides API related services such as making HTTP requests.
class APIService {

    // MARK: - Singleton
    /// The shared singleton instance of APIService.
    /// Ensures that only one instance of this class is instantiated.
    static let shared = APIService()
    
    /// A private initializer to prevent creating multiple instances.
    private init() {}
    
    // MARK: - Networking
    /// Makes an HTTP request with the given parameters.
    ///
    /// - Parameters:
    ///   - url: The URL for the request.
    ///   - method: The HTTP method to use.
    ///   - parameters: A dictionary of parameters to include in the request. Default is nil.
    ///
    /// - Returns: A Future that either provides the requested data or an error.
    func request(url: URL, method: HTTPMethod, parameters: [String: Any]? = nil) -> Future<Data, Error> {
        return Future { promise in
            // Create a URL request with the given URL.
            var request = URLRequest(url: url)
            // Set the HTTP method.
            request.httpMethod = method.rawValue
            
            // If parameters are provided, serialize them into JSON and set as the request body.
            if let parameters = parameters {
                request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
                // Set the content type of the request to JSON.
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            // Create a data task with the given request.
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // Handle the data task completion.
                
                // If an error occurred, reject the promise with the error.
                if let error = error {
                    promise(.failure(error))
                }
                // If data was returned, resolve the promise with the data.
                else if let data = data {
                    promise(.success(data))
                }
                // If neither data nor error is available, reject with an unknown error.
                else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred."])
                    promise(.failure(error))
                }
            }
            // Start the data task.
            task.resume()
        }
    }
}


