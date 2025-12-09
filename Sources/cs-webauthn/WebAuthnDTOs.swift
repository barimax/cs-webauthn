//
//  CreationOptionsResponse.swift
//  cs-webauthn
//
//  Created by Georgie Ivanov on 9.12.25.
//


// WebAuthnDTOs.swift
import Vapor
import WebAuthn

struct CreationOptionsResponse: Content {
    let publicKey: PublicKeyCredentialCreationOptions
    let challengeToken: String
}

struct RequestOptionsResponse: Content {
    let publicKey: PublicKeyCredentialRequestOptions
    let challengeToken: String
}

// start registration body – NOT used for auth, just for mobile/web UX if needed
struct StartPasskeyRegistrationRequest: Content {
    let email: String?
}

// start login body – optional email hint (you might not enforce it for passkeys)
struct StartPasskeyLoginRequest: Content {
    let email: String?
}

// Your existing JWT response shape
struct LoginResponse: Content {
    let token: String
}

struct Registration: Content {
    let credential: RegistrationCredential
    let challengeToken: String
}

struct Authentication: Content {
    let credential: AuthenticationCredential
    let challengeToken: String
}
