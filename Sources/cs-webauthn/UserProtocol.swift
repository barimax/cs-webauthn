//
//  UserProtocol.swift
//  cs-webauthn
//
//  Created by Georgie Ivanov on 9.12.25.
//
import Foundation
import Fluent
import Vapor

public protocol WebAuthnUserProtocol: Model, Authenticatable where IDValue == UUID {
    var email: String { get set }
}
