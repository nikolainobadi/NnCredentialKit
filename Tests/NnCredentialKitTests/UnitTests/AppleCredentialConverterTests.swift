//
//  AppleCredentialConverterTests.swift
//  NnCredentialKitTests
//
//  Created by Nikolai Nobadi on 12/28/24.
//

import Testing
import Foundation
@testable import NnCredentialKit

struct AppleCredentialConverterTests {
    @Test
    func `Converts raw credential to Apple credential info with all fields`() throws {
        let email = "test@apple.com"
        let givenName = "John"
        let familyName = "Doe"
        let nonce = "test-nonce"
        let tokenString = "test-token-string"
        let tokenData = tokenString.data(using: .utf8)
        let fullName = makePersonNameComponents(givenName: givenName, familyName: familyName)
        let raw = makeRawCredential(email: email, fullName: fullName, idTokenData: tokenData)
        let sut = makeSUT()

        let result = try sut.convert(raw: raw, nonce: nonce)

        #expect(result.email == email)
        #expect(result.displayName == "\(givenName) \(familyName)")
        #expect(result.idTokenString == tokenString)
        #expect(result.nonce == nonce)
    }

    @Test
    func `Converts raw credential with minimal fields`() throws {
        let nonce = "test-nonce"
        let tokenString = "minimal-token"
        let tokenData = tokenString.data(using: .utf8)
        let raw = makeRawCredential(email: nil, fullName: nil, idTokenData: tokenData)
        let sut = makeSUT()

        let result = try sut.convert(raw: raw, nonce: nonce)

        #expect(result.email == nil)
        #expect(result.displayName == "")
        #expect(result.idTokenString == tokenString)
        #expect(result.nonce == nonce)
    }

    @Test
    func `Throws error when nonce is nil`() {
        let raw = makeRawCredential()
        let sut = makeSUT()

        #expect(throws: AppleSignInError.invalidState) {
            try sut.convert(raw: raw, nonce: nil)
        }
    }

    @Test
    func `Throws error when token data cannot be serialized`() {
        let nonce = "test-nonce"
        let raw = makeRawCredential(idTokenData: nil)
        let sut = makeSUT()

        #expect(throws: AppleSignInError.unableToSerializeToken) {
            try sut.convert(raw: raw, nonce: nonce)
        }
    }

    @Test
    func `Throws error when token data is invalid UTF-8`() {
        let nonce = "test-nonce"
        let invalidData = Data([0xFF, 0xFE, 0xFD])
        let raw = makeRawCredential(idTokenData: invalidData)
        let sut = makeSUT()

        #expect(throws: AppleSignInError.unableToSerializeToken) {
            try sut.convert(raw: raw, nonce: nonce)
        }
    }
}

// MARK: - Display Name Tests
extension AppleCredentialConverterTests {
    @Test
    func `Creates display name from full name with both components`() {
        let givenName = "Jane"
        let familyName = "Smith"
        let fullName = makePersonNameComponents(givenName: givenName, familyName: familyName)

        let displayName = AppleCredentialConverter.displayName(from: fullName)

        #expect(displayName == "\(givenName) \(familyName)")
    }

    @Test
    func `Creates display name with only given name`() {
        let givenName = "Jane"
        let fullName = makePersonNameComponents(givenName: givenName, familyName: nil)

        let displayName = AppleCredentialConverter.displayName(from: fullName)

        #expect(displayName == givenName)
    }

    @Test
    func `Creates display name with only family name`() {
        let familyName = "Smith"
        let fullName = makePersonNameComponents(givenName: nil, familyName: familyName)

        let displayName = AppleCredentialConverter.displayName(from: fullName)

        #expect(displayName == familyName)
    }

    @Test
    func `Returns empty string when full name is nil`() {
        let displayName = AppleCredentialConverter.displayName(from: nil)

        #expect(displayName.isEmpty)
    }

    @Test
    func `Trims whitespace from display name`() {
        let fullName = makePersonNameComponents(givenName: " John ", familyName: " Doe ")

        let displayName = AppleCredentialConverter.displayName(from: fullName)

        #expect(displayName == "John   Doe")
    }
}

// MARK: - Token Serialization Tests
extension AppleCredentialConverterTests {
    @Test
    func `Serializes valid token data to string`() throws {
        let tokenString = "valid-token-string-12345"
        let tokenData = tokenString.data(using: .utf8)

        let result = try AppleCredentialConverter.serializeToken(tokenData)

        #expect(result == tokenString)
    }

    @Test
    func `Throws error when token data is nil`() {
        #expect(throws: AppleSignInError.unableToSerializeToken) {
            try AppleCredentialConverter.serializeToken(nil)
        }
    }

    @Test
    func `Serializes complex UTF-8 string correctly`() throws {
        let complexString = "Token-with-特殊字符-🔐-and-numbers-123"
        let tokenData = complexString.data(using: .utf8)

        let result = try AppleCredentialConverter.serializeToken(tokenData)

        #expect(result == complexString)
    }
}

// MARK: - SUT
private extension AppleCredentialConverterTests {
    func makeSUT() -> AppleCredentialConverter {
        return AppleCredentialConverter()
    }
}

// MARK: - Helpers
private extension AppleCredentialConverterTests {
    func makeRawCredential(
        email: String? = "default@test.com",
        fullName: PersonNameComponents? = nil,
        idTokenData: Data? = "default-token".data(using: .utf8)
    ) -> AppleAuthRawCredential {
        return AppleAuthRawCredential(
            email: email,
            fullName: fullName,
            idTokenData: idTokenData
        )
    }

    func makePersonNameComponents(
        givenName: String? = nil,
        familyName: String? = nil
    ) -> PersonNameComponents {
        var components = PersonNameComponents()
        components.givenName = givenName
        components.familyName = familyName
        return components
    }
}
