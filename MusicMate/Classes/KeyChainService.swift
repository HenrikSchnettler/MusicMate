//
//  KeychainService.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 03.06.23.
//

import Foundation

// This class provides services for accessing the device's keychain to securely store, retrieve, and manage sensitive data.
class KeychainService {

    // MARK: - Keychain Query

    /// Constructs a basic keychain query dictionary for the given service and account.
    ///
    /// - Parameters:
    ///   - service: A string used to identify the service associated with the keychain item.
    ///   - account: An optional string representing the account or key for the keychain item. Defaults to nil.
    ///
    /// - Returns: A dictionary containing the keychain query.
    private func keychainQuery(withService service: String, account: String? = nil) -> [String: AnyObject] {
        var query = [String: AnyObject]()
        
        // Set the class of the item we want to add to the keychain.
        query[kSecClass as String] = kSecClassGenericPassword
        // Set the service for the keychain item.
        query[kSecAttrService as String] = service as AnyObject

        // If an account (or key) is provided, set it for the keychain item.
        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject
        }

        return query
    }
    
    // MARK: - Keychain Operations

    /// Saves a value associated with a given key to the keychain.
    ///
    /// - Parameters:
    ///   - key: The key with which the value should be associated.
    ///   - value: The string value to be stored in the keychain.
    func save(key: String, value: String) {
        let data = value.data(using: .utf8)!
        var query = keychainQuery(withService: key)
        
        // Set the value we want to add to the keychain.
        query[kSecValueData as String] = data as AnyObject

        // Attempt to add the item to the keychain.
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("Could not save data to the keychain.")
        }
    }
    
    /// Retrieves a value from the keychain associated with the given key.
    ///
    /// - Parameter key: The key associated with the desired value.
    ///
    /// - Returns: The retrieved string value if it exists, or nil if not found.
    func get(key: String) -> String? {
        var query = keychainQuery(withService: key)
        
        // Set up the query for an exact match and to return the value.
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue

        // Attempt to match an item in the keychain with our query.
        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        // If we find a match, attempt to convert it to a string and return it.
        if status == noErr {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
        }

        return nil
    }
}
