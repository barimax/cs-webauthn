//
//  Passkey.swift
//  cs-webauthn
//
//  Created by Georgie Ivanov on 9.12.25.
//


// Passkey.swift
import Vapor
import Fluent

public final class Passkey: Model, Content, @unchecked Sendable {
    
    public static let schema = "passkeys"

    @ID(custom: "id", generatedBy: .user)
    public var id: String?

    @Field(key: "public_key")
    public var publicKey: String

    @Field(key: "sign_count")
    public var currentSignCount: UInt32

    @Field(key: "user_id")
    public var userId: UUID

    public init() {}

    public init(id: String,
         publicKey: String,
         currentSignCount: UInt32,
         userId: UUID) {
        self.id = id
        self.publicKey = publicKey
        self.currentSignCount = currentSignCount
        self.userId = userId
    }
}
