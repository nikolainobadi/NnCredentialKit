//
//  NonceFactoryTests.swift
//  NnCredentialKit
//
//  Created by Nikolai Nobadi on 9/28/25.
//

import Testing
@testable import NnCredentialKit

struct NonceFactoryTests {
    @Test("Generates nonce with default length of 32 characters")
    func generatesNonceWithDefaultLength() {
        let nonce = NonceFactory.randomNonceString()

        #expect(nonce.count == 32)
    }

    @Test("Generates nonce with custom specified length")
    func generatesNonceWithCustomLength() {
        let customLength = 64
        let nonce = NonceFactory.randomNonceString(length: customLength)

        #expect(nonce.count == customLength)
    }

    @Test("Generates nonce using only allowed character set")
    func generatesNonceUsingOnlyAllowedCharacterSet() {
        let allowedCharacters = Set("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = NonceFactory.randomNonceString(length: 100)
        let nonceCharacters = Set(nonce)

        #expect(nonceCharacters.isSubset(of: allowedCharacters))
    }

    @Test("Generates different nonces on consecutive calls")
    func generatesDifferentNoncesOnConsecutiveCalls() {
        let nonce1 = NonceFactory.randomNonceString()
        let nonce2 = NonceFactory.randomNonceString()
        let nonce3 = NonceFactory.randomNonceString()

        #expect(nonce1 != nonce2)
        #expect(nonce2 != nonce3)
        #expect(nonce1 != nonce3)
    }

    @Test("Produces consistent SHA256 hash for same input")
    func producesConsistentSHA256HashForSameInput() {
        let input = "test-input-string"
        let hash1 = NonceFactory.sha256(input)
        let hash2 = NonceFactory.sha256(input)

        #expect(hash1 == hash2)
    }

    @Test("Produces different SHA256 hashes for different inputs")
    func producesDifferentSHA256HashesForDifferentInputs() {
        let input1 = "first-input"
        let input2 = "second-input"
        let hash1 = NonceFactory.sha256(input1)
        let hash2 = NonceFactory.sha256(input2)

        #expect(hash1 != hash2)
    }

    @Test("Returns SHA256 hash as lowercase hexadecimal string")
    func returnsSHA256HashAsLowercaseHexadecimalString() {
        let input = "test"
        let hash = NonceFactory.sha256(input)
        let hexCharacters = Set("0123456789abcdef")
        let hashCharacters = Set(hash)

        #expect(hash.count == 64) // SHA256 produces 32 bytes = 64 hex characters
        #expect(hashCharacters.isSubset(of: hexCharacters))
    }

    @Test("Produces expected SHA256 hash for known input")
    func producesExpectedSHA256HashForKnownInput() {
        let input = "hello"
        let expectedHash = "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"
        let hash = NonceFactory.sha256(input)

        #expect(hash == expectedHash)
    }
}
