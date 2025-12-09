//
//  ApplicationExtension.swift
//  cs-webauthn
//
//  Created by Georgie Ivanov on 9.12.25.
//
import Vapor

struct WebAuthnManagerConfigurationKey: StorageKey {
    typealias Value = WebAuthnManagerConfiguration
}

struct WebAuthnSecretKey: StorageKey {
    typealias Value = String
}

public extension Application {
    var webAuthnManagerConfiguration: WebAuthnManagerConfiguration {
        get throws {
            guard let config = self.storage[WebAuthnManagerConfigurationKey.self] else {
                throw Abort(.internalServerError, reason: "Missing WebAuthnManagerConfiguration")
            }
            return config
        }
    }
    
    var webAuthnSecretKey: String {
        get throws {
            guard let webAuthnSecretKey = self.storage[WebAuthnSecretKey.self] else {
                throw Abort(.internalServerError, reason: "Missing WebAuthnSecretKey")
            }
            return webAuthnSecretKey
        }
    }
    
    func loadWebAuthn(webAuthnManagerConfiguration: WebAuthnManagerConfiguration, webAuthnSecretKey: String) {
        self.storage[WebAuthnManagerConfigurationKey.self] = webAuthnManagerConfiguration
        self.storage[WebAuthnSecretKey.self] = webAuthnSecretKey
        self.migrations.add(CreatePasskey())
    }
}
