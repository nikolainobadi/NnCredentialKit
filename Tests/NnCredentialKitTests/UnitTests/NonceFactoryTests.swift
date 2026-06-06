//
//  NonceFactoryTests.swift
//  NnCredentialKit
//
//  Created by Nikolai Nobadi on 9/28/25.
//

import Testing
@testable import NnCredentialKit

struct NonceFactoryTests {
    @Test
    func `Generates nonce with default length of 32 characters`() {
        let nonce = NonceFactory.randomNonceString()

        #expect(nonce.count == 32)
    }

    @Test
    func `Generates nonce with custom specified length`() {
        let customLength = 64
        let nonce = NonceFactory.randomNonceString(length: customLength)

        #expect(nonce.count == customLength)
    }

    @Test
    func `Generates nonce using only allowed character set`() {
        let allowedCharacters = Set("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        let nonce = NonceFactory.randomNonceString(length: 100)
        let nonceCharacters = Set(nonce)

        #expect(nonceCharacters.isSubset(of: allowedCharacters))
    }

    @Test
    func `Generates different nonces on consecutive calls`() {
        let nonce1 = NonceFactory.randomNonceString()
        let nonce2 = NonceFactory.randomNonceString()
        let nonce3 = NonceFactory.randomNonceString()

        #expect(nonce1 != nonce2)
        #expect(nonce2 != nonce3)
        #expect(nonce1 != nonce3)
    }
}


// MARK: - SHA256 Hashing
extension NonceFactoryTests {
    @Test
    func `Produces consistent SHA256 hash for same input`() {
        let input = "test-input-string"
        let hash1 = NonceFactory.sha256(input)
        let hash2 = NonceFactory.sha256(input)

        #expect(hash1 == hash2)
    }

    @Test
    func `Produces different SHA256 hashes for different inputs`() {
        let input1 = "first-input"
        let input2 = "second-input"
        let hash1 = NonceFactory.sha256(input1)
        let hash2 = NonceFactory.sha256(input2)

        #expect(hash1 != hash2)
    }

    @Test
    func `Returns SHA256 hash as lowercase hexadecimal string`() {
        let input = "test"
        let hash = NonceFactory.sha256(input)
        let hexCharacters = Set("0123456789abcdef")
        let hashCharacters = Set(hash)

        #expect(hash.count == 64)
        #expect(hashCharacters.isSubset(of: hexCharacters))
    }

    @Test
    func `Produces expected SHA256 hash for known input`() {
        let input = "hello"
        let expectedHash = "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"
        let hash = NonceFactory.sha256(input)

        #expect(hash == expectedHash)
    }
}
