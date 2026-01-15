//
//  RequestExtension.swift
//  cs-webauthn
//
//  Created by Georgie Ivanov on 9.12.25.
//

import Vapor
import WebAuthn

public extension Request {
    var webAuthn: WebAuthnManager {
        get throws {
            guard let relyingPartyID = self.headers.first(name: "X-WebAuthn-RP-ID"),
                  let relyingPartyName = self.headers.first(name: "X-WebAuthn-RP-Name"),
                  let relyingPartyOrigin = self.headers.first(name: "X-WebAuthn-RP-Origin") else {
                throw Abort(.internalServerError, reason: "Missing X-WebAuthn-* headers")
            }
            self.logger.debug("X-WebAuthn-RP-ID: \(relyingPartyID)")
            self.logger.debug("X-WebAuthn-RP-Name: \(relyingPartyName)")
            self.logger.debug("X-WebAuthn-RP-Origin: \(relyingPartyOrigin)")
            return WebAuthnManager(
                configuration: WebAuthnManager.Configuration(
                    relyingPartyID: relyingPartyID,
                    relyingPartyName: relyingPartyName,
                    relyingPartyOrigin: relyingPartyOrigin
                )
            )
        }
    }
    
    var webAuthnSecret: [UInt8] {
        get throws {
            let webAuthnSecretKey = try self.application.webAuthnSecretKey
            return Array(webAuthnSecretKey.utf8)
        }
    }
    
    func signWebAuthnToken(_ payload: WebAuthnChallengeToken) throws -> String {
        let data = try JSONEncoder().encode(payload)
        let mac = HMAC<SHA256>.authenticationCode(for: data, using: SymmetricKey(data: try webAuthnSecret))
        let macData = Data(mac)
        let combined = Data(macData) + data
        return combined.base64EncodedString()
    }
    
    func verifyWebAuthnToken(_ token: String) throws -> WebAuthnChallengeToken {
        guard let combinedData = Data(base64Encoded: token) else {
            throw Abort(.badRequest, reason: "Invalid challenge token encoding")
        }
        
        // 32 bytes = SHA256 size
        guard combinedData.count > 32 else {
            throw Abort(.badRequest, reason: "Invalid challenge token length")
        }
        
        let macData = combinedData.prefix(32)
        let jsonData = combinedData.suffix(from: 32)
        
        let key = SymmetricKey(data: try webAuthnSecret)
        let expectedMAC = HMAC<SHA256>.authenticationCode(for: jsonData, using: key)
        
        guard macData == Data(expectedMAC) else {
            throw Abort(.unauthorized, reason: "Invalid challenge token signature")
        }
        
        let payload = try JSONDecoder().decode(WebAuthnChallengeToken.self, from: jsonData)
        
        let now = Date()
        guard payload.expiresAt > now else {
            throw Abort(.unauthorized, reason: "Challenge token expired")
        }
        
        return payload
    }
}
