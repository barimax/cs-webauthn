//
//  CreatePasskey.swift
//  cs-webauthn
//
//  Created by Georgie Ivanov on 9.12.25.
//
import Fluent

struct CreatePasskey: AsyncMigration {
    func prepare(on db: Database) async throws {
        try await db.schema("passkeys")
            .id()
            .field("public_key", .string, .required)
            .field("sign_count", .int, .required)
            .field("user_id", .uuid, .required)
            .create()
    }

    func revert(on db: Database) async throws {
        try await db.schema("passkeys").delete()
    }
}
