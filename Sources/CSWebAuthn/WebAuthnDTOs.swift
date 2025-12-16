//
//  CreationOptionsResponse.swift
//  cs-webauthn
//
//  Created by Georgie Ivanov on 9.12.25.
//


// WebAuthnDTOs.swift
import Vapor
import WebAuthn

public struct CreationOptionsResponse: Content {
    let publicKey: PublicKeyCredentialCreationOptions
    let challengeToken: String
}

public struct RequestOptionsResponse: Content {
    let publicKey: PublicKeyCredentialRequestOptions
    let challengeToken: String
}

// start registration body – NOT used for auth, just for mobile/web UX if needed
public struct StartPasskeyRegistrationRequest: Content {
    let email: String?
}

// start login body – optional email hint (you might not enforce it for passkeys)
public struct StartPasskeyLoginRequest: Content {
    let email: String?
}

// Your existing JWT response shape
public struct LoginResponse: Content {
    let token: String
}

public struct Registration: Content {
    let credential: RegistrationCredential
    let challengeToken: String
}

public struct Authentication: Content {
    let credential: AuthenticationCredential
    let challengeToken: String
}

public struct IsPasskeyEnabledRequest: Content {
    public let email: String
}

public struct IsPasskeyEnabledResponse: Content {
    public let isPasskeyEnabled: Bool
}
