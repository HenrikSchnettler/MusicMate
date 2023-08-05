//
//  SocialProfile.swift
//  MusicMate
//
//  Created by Henrik Schnettler on 05.08.23.
//

import Foundation
import MusicKit

//SocialProfileResponse
struct SocialProfileResponse: Codable {
    let data: [SocialProfile]
    //let meta: SubscriptionDetails
}

//SocialProfile
struct SocialProfile: Codable {
    let id, type, href: String
    let attributes: ProfileAttributes
}

//ProfileAttributes
struct ProfileAttributes: Codable {
    let restrictions: Restrictions
    let avatarArtwork: AvatarArtwork
}

//AvatarArtwork
struct AvatarArtwork: Codable {
    let width, height: Int
    let url: String
    let hasP3: Bool
}

//Restrictions
struct Restrictions: Codable {
    // Include fields as per your requirement
}

//SubscriptionDetails
struct SubscriptionDetails: Codable {
    let challenge: Challenge
    let subscription: Subscription
}

//Challenge
struct Challenge: Codable {
    let subscriptionCapabilities: [String]
}

//Subscription
struct Subscription: Codable {
    let active: Bool
    let storefront: String
}
