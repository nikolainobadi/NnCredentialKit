//
//  GoogleSignInServiceTests.swift
//  NnCredentialKit
//
//  Created by Nikolai Nobadi on 9/29/25.
//

import Testing
@testable import NnCredentialKit

@MainActor
struct GoogleSignInServiceTests {
    @Test
    func `Returns nil when client returns nil`() async throws {
        let sut = makeSUT(clientResult: nil)

        let result = try await sut.signIn()

        #expect(result == nil)
    }

    @Test
    func `Returns nil when sign-in result missing id token`() async throws {
        let signInResult = makeSignInResult(idTokenString: nil)
        let sut = makeSUT(clientResult: signInResult)

        let result = try await sut.signIn()

        #expect(result == nil)
    }

    @Test
    func `Returns credential info with email and token when sign-in succeeds`() async throws {
        let email = "tester@gmail.com"
        let idToken = "id-token-123"
        let accessToken = "access-token-456"
        let signInResult = makeSignInResult(idTokenString: idToken, accessTokenString: accessToken, email: email)
        let sut = makeSUT(clientResult: signInResult)

        let result = try #require(try await sut.signIn())

        #expect(result.email == email)
        #expect(result.tokenId == idToken)
        #expect(result.accessTokenId == accessToken)
    }

    @Test
    func `Combines given name and family name into display name`() async throws {
        let givenName = "John"
        let familyName = "Doe"
        let signInResult = makeSignInResult(givenName: givenName, familyName: familyName)
        let sut = makeSUT(clientResult: signInResult)

        let result = try #require(try await sut.signIn())

        #expect(result.displayName == "\(givenName) \(familyName)")
    }

    @Test
    func `Handles partial name with only given name`() async throws {
        let givenName = "John"
        let signInResult = makeSignInResult(givenName: givenName, familyName: nil)
        let sut = makeSUT(clientResult: signInResult)

        let result = try #require(try await sut.signIn())

        #expect(result.displayName == givenName)
    }

    @Test
    func `Handles partial name with only family name`() async throws {
        let familyName = "Doe"
        let signInResult = makeSignInResult(givenName: nil, familyName: familyName)
        let sut = makeSUT(clientResult: signInResult)

        let result = try #require(try await sut.signIn())

        #expect(result.displayName == familyName)
    }

    @Test
    func `Handles empty display name when both names are nil`() async throws {
        let signInResult = makeSignInResult(givenName: nil, familyName: nil)
        let sut = makeSUT(clientResult: signInResult)

        let displayName = try #require(try await sut.signIn()?.displayName)

        #expect(displayName.isEmpty)
    }

    @Test
    func `Propagates errors from client`() async {
        let error = TestError.network
        let sut = makeSUT(clientResult: nil, clientError: error)

        await #expect(throws: error) {
            _ = try await sut.signIn()
        }
    }
}


// MARK: - SUT
private extension GoogleSignInServiceTests {
    func makeSUT(clientResult: GoogleSignInResult?, clientError: (any Error)? = nil) -> GoogleSignInService {
        let client = MockClient(result: clientResult, error: clientError)

        return GoogleSignInService(client: client)
    }
}


// MARK: - Helpers
private extension GoogleSignInServiceTests {
    func makeSignInResult(idTokenString: String? = "id-token", accessTokenString: String = "access-token", email: String? = "test@gmail.com", givenName: String? = "Test", familyName: String? = "User") -> GoogleSignInResult {
        return .init(idTokenString: idTokenString, accessTokenString: accessTokenString, email: email, givenName: givenName, familyName: familyName)
    }
}


// MARK: - Mocks
private extension GoogleSignInServiceTests {
    final class MockClient: GoogleSignInClient {
        private let result: GoogleSignInResult?
        private let error: (any Error)?

        init(result: GoogleSignInResult?, error: (any Error)? = nil) {
            self.result = result
            self.error = error
        }

        func signIn() async throws -> GoogleSignInResult? {
            if let error {
                throw error
            }

            return result
        }
    }
}
