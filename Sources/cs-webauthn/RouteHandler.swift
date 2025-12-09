//
//  RouteHandler.swift
//  cs-webauthn
//
//  Created by Georgie Ivanov on 9.12.25.
//
import Vapor
import WebAuthn

struct RouteHandlerHelper {
    /// : "passkeys", "register", "options"
    @Sendable
    func passkeyRegisterOptions<U>(req: Request, userType: U.Type) async throws -> CreationOptionsResponse where U: WebAuthnUserProtocol {
        let user: U = try req.auth.require(userType)
        
        // 1) WebAuthn creation options
        let webAuthnUser = PublicKeyCredentialUserEntity(
            id: [UInt8](try user.requireID().uuidString.utf8),
            name: user.email,
            displayName: user.email
        )
        
        let options = try req.webAuthn.beginRegistration(user: webAuthnUser)
        
        // 2) build challenge token (short TTL)
        let challengeData = Data(options.challenge)
        let now = Date()
        let tokenPayload = WebAuthnChallengeToken(
            kind: .registration,
            userID: try user.requireID(),
            challenge: challengeData.base64EncodedString(),
            issuedAt: now,
            expiresAt: now.addingTimeInterval(5 * 60) // 5 minutes
        )
        
        let challengeToken = try req.signWebAuthnToken(tokenPayload)
        
        return CreationOptionsResponse(
            publicKey: options,
            challengeToken: challengeToken
        )
    }
    
    
    
    @Sendable
    func passkeyRegistrationVerify<U>(req: Request, userType: U.Type) async throws -> HTTPStatus where U: WebAuthnUserProtocol{
        let user = try req.auth.require(userType)
        
        // Client must send:
        // - WebAuthn RegistrationCredential JSON
        // - challengeToken string
        
        let body = try req.content.decode(Registration.self)
        
        // 1) verify challenge token
        let tokenPayload = try req.verifyWebAuthnToken(body.challengeToken)
        
        guard tokenPayload.kind == .registration else {
            throw Abort(.unauthorized, reason: "Wrong challenge kind")
        }
        guard tokenPayload.userID == user.id else {
            throw Abort(.unauthorized, reason: "Challenge not for this user")
        }
        
        guard let challengeData = Data(base64Encoded: tokenPayload.challenge) else {
            throw Abort(.badRequest, reason: "Invalid challenge encoding")
        }
        
        // 2) finish registration with WebAuthn
        let result = try await req.webAuthn.finishRegistration(
            challenge: [UInt8](challengeData),
            credentialCreationData: body.credential,
            confirmCredentialIDNotRegisteredYet: { credentialID in
                let idString = credentialID.base64String()
                return try await Passkey.find(idString, on: req.db) == nil
            }
        )
        
        // 3) store passkey for this user
        let passkey = Passkey(
            id: result.id,
            publicKey: result.publicKey.base64URLEncodedString().asString(),
            currentSignCount: result.signCount,
            userId: try user.requireID()
        )
        try await passkey.save(on: req.db)
        
        return .ok
    }
    
    @Sendable
    func passkeyLogin(req: Request) async throws -> RequestOptionsResponse {
        let _ = try? req.content.decode(StartPasskeyLoginRequest.self)
        // You can use email as hint, but for passkeys we allow authenticator to choose.
        
        let options = try req.webAuthn.beginAuthentication()
        
        let challengeData = Data(options.challenge)
        let now = Date()
        let payload = WebAuthnChallengeToken(
            kind: .authentication,
            userID: nil, // unknown yet – determined by credential
            challenge: challengeData.base64EncodedString(),
            issuedAt: now,
            expiresAt: now.addingTimeInterval(5 * 60)
        )
        
        let challengeToken = try req.signWebAuthnToken(payload)
        
        return RequestOptionsResponse(publicKey: options, challengeToken: challengeToken)
    }
    
    /// Use [func onLoginSuccess(_ userId: UUID) -> String ] to generate token
    @Sendable
    func passkeyLoginVerify(req: Request, onLoginSuccess: (_ userId: UUID) async throws -> String) async throws -> LoginResponse {
        
        
        let body = try req.content.decode(Authentication.self)
        
        // 1) Verify challenge token
        let payload = try req.verifyWebAuthnToken(body.challengeToken)
        
        guard payload.kind == .authentication else {
            throw Abort(.unauthorized, reason: "Wrong challenge kind")
        }
        
        guard let challengeData = Data(base64Encoded: payload.challenge) else {
            throw Abort(.badRequest, reason: "Invalid challenge encoding")
        }
        
        // 2) Find passkey from credential ID
        let credentialID = body.credential.id.urlDecoded.asString()
        guard let passkey = try await Passkey.find(credentialID, on: req.db) else {
            throw Abort(.unauthorized, reason: "Unknown passkey")
        }
        
        // 3) Verify assertion with WebAuthn
        let verified = try req.webAuthn.finishAuthentication(
            credential: body.credential,
            expectedChallenge: [UInt8](challengeData),
            credentialPublicKey: [UInt8](URLEncodedBase64(passkey.publicKey).urlDecoded.decoded!),
            credentialCurrentSignCount: passkey.currentSignCount
        )
        
        // 4) Update sign counter
        passkey.currentSignCount = verified.newSignCount
        try await passkey.save(on: req.db)
        
        // 5) Issue your normal JWT/UserToken
        
        
        return try await .init(token: onLoginSuccess(passkey.userId))   // adapt to your UserToken
    }
}
