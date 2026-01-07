//
//  ApplicationExtension.swift
//  cs-webauthn
//
//  Created by Georgie Ivanov on 9.12.25.
//
import Vapor

struct WebAuthnSecretKey: StorageKey {
    typealias Value = String
}

public extension Application {
    var webAuthnSecretKey: String {
        get throws {
            guard let webAuthnSecretKey = self.storage[WebAuthnSecretKey.self] else {
                throw Abort(.internalServerError, reason: "Missing WebAuthnSecretKey")
            }
            return webAuthnSecretKey
        }
    }
    
    func loadWebAuthn(webAuthnSecretKey: String) {
        self.storage[WebAuthnSecretKey.self] = webAuthnSecretKey
        self.migrations.add(CreatePasskey())
    }
}
