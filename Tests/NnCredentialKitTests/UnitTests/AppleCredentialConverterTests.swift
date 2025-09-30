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
    @Test("Converts raw credential to Apple credential info with all fields")
    func convertsRawCredentialToAppleCredentialInfoWithAllFields() throws {
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

    @Test("Converts raw credential with minimal fields")
    func convertsRawCredentialWithMinimalFields() throws {
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

    @Test("Throws error when nonce is nil")
    func throwsErrorWhenNonceIsNil() {
        let raw = makeRawCredential()
        let sut = makeSUT()

        #expect(throws: AppleSignInError.invalidState) {
            try sut.convert(raw: raw, nonce: nil)
        }
    }

    @Test("Throws error when token data cannot be serialized")
    func throwsErrorWhenTokenDataCannotBeSerialized() {
        let nonce = "test-nonce"
        let raw = makeRawCredential(idTokenData: nil)
        let sut = makeSUT()

        #expect(throws: AppleSignInError.unableToSerializeToken) {
            try sut.convert(raw: raw, nonce: nonce)
        }
    }

    @Test("Throws error when token data is invalid UTF-8")
    func throwsErrorWhenTokenDataIsInvalidUTF8() {
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
    @Test("Creates display name from full name with both components")
    func createsDisplayNameFromFullNameWithBothComponents() {
        let givenName = "Jane"
        let familyName = "Smith"
        let fullName = makePersonNameComponents(givenName: givenName, familyName: familyName)

        let displayName = AppleCredentialConverter.displayName(from: fullName)

        #expect(displayName == "\(givenName) \(familyName)")
    }

    @Test("Creates display name with only given name")
    func createsDisplayNameWithOnlyGivenName() {
        let givenName = "Jane"
        let fullName = makePersonNameComponents(givenName: givenName, familyName: nil)

        let displayName = AppleCredentialConverter.displayName(from: fullName)

        #expect(displayName == givenName)
    }

    @Test("Creates display name with only family name")
    func createsDisplayNameWithOnlyFamilyName() {
        let familyName = "Smith"
        let fullName = makePersonNameComponents(givenName: nil, familyName: familyName)

        let displayName = AppleCredentialConverter.displayName(from: fullName)

        #expect(displayName == familyName)
    }

    @Test("Returns empty string when full name is nil")
    func returnsEmptyStringWhenFullNameIsNil() {
        let displayName = AppleCredentialConverter.displayName(from: nil)

        #expect(displayName.isEmpty)
    }

    @Test("Trims whitespace from display name")
    func trimsWhitespaceFromDisplayName() {
        let fullName = makePersonNameComponents(givenName: " John ", familyName: " Doe ")

        let displayName = AppleCredentialConverter.displayName(from: fullName)

        #expect(displayName == "John   Doe")
    }
}

// MARK: - Token Serialization Tests
extension AppleCredentialConverterTests {
    @Test("Serializes valid token data to string")
    func serializesValidTokenDataToString() throws {
        let tokenString = "valid-token-string-12345"
        let tokenData = tokenString.data(using: .utf8)

        let result = try AppleCredentialConverter.serializeToken(tokenData)

        #expect(result == tokenString)
    }

    @Test("Throws error when token data is nil")
    func throwsErrorWhenTokenDataIsNil() {
        #expect(throws: AppleSignInError.unableToSerializeToken) {
            try AppleCredentialConverter.serializeToken(nil)
        }
    }

    @Test("Serializes complex UTF-8 string correctly")
    func serializesComplexUTF8StringCorrectly() throws {
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
