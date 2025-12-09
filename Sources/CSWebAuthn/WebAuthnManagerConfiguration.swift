//
//  Untitled.swift
//  cs-webauthn
//
//  Created by Georgie Ivanov on 9.12.25.
//

public struct WebAuthnManagerConfiguration: Sendable {
    let relyingPartyID: String // no scheme
    let relyingPartyName: String
    let relyingPartyOrigin: String
    
    public init(relyingPartyID: String,
                relyingPartyName: String,
                relyingPartyOrigin: String) {
        self.relyingPartyID = relyingPartyID
        self.relyingPartyName = relyingPartyName
        self.relyingPartyOrigin = relyingPartyOrigin
    }
}
