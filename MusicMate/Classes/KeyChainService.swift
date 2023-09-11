//
//  KeychainService.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 03.06.23.
//

import Foundation

class KeychainService {
    //querys the keyChain for a entry
    private func keychainQuery(withService service: String, account: String? = nil) -> [String: AnyObject] {
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject

        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject
        }

        return query
    }
    
    //save a entry in the keychain
    func save(key: String, value: String) {
        let data = value.data(using: .utf8)!
        var query = keychainQuery(withService: key)
        query[kSecValueData as String] = data as AnyObject

        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Could not save data to the keychain.")
        }
    }
    
    //gets a keychain entry
    func get(key: String) -> String? {
        var query = keychainQuery(withService: key)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue

        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
        }

        return nil
    }
}
