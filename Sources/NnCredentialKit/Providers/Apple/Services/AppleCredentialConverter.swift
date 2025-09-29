//
//  AppleCredentialConverter.swift
//  NnCredentialKit
//
//  Created by Nikolai Nobadi on 9/28/25.
//

import Foundation

struct AppleCredentialConverter: Sendable {
    func convert(raw: AppleAuthRawCredential, nonce: String?) throws -> AppleCredentialInfo {
        guard let nonce else { throw AppleSignInError.invalidState }
        let displayName = Self.displayName(from: raw.fullName)
        let idTokenString = try Self.serializeToken(raw.idTokenData)
        return .init(email: raw.email, displayName: displayName, idTokenString: idTokenString, nonce: nonce)
    }

    static func displayName(from fullName: PersonNameComponents?) -> String {
        let first = fullName?.givenName ?? ""
        let last = fullName?.familyName ?? ""
        return [first, last].joined(separator: " ").trimmingCharacters(in: .whitespaces)
    }

    static func serializeToken(_ data: Data?) throws -> String {
        guard let data, let string = String(data: data, encoding: .utf8) else {
            throw AppleSignInError.unableToSerializeToken
        }
        return string
    }
}


// MARK: - Dependencies
struct AppleAuthRawCredential: Sendable {
    let email: String?
    let fullName: PersonNameComponents?
    let idTokenData: Data?
}
