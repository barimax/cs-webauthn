//
//  WebAuthnChallengeToken.swift
//  cs-webauthn
//
//  Created by Georgie Ivanov on 9.12.25.
//

import Vapor

public struct WebAuthnChallengeToken: Content {
    enum Kind: String, Codable {
        case registration
        case authentication
    }

    let kind: Kind
    let userID: UUID?        // for registration when user is logged in
    let challenge: String    // base64-encoded bytes
    let issuedAt: Date
    let expiresAt: Date
}
