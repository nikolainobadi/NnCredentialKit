//
//  GoogleSignInCoordinatorTests.swift
//  NnCredentialKit
//
//  Created by Nikolai Nobadi on 9/29/25.
//

import Testing
@testable import NnCredentialKit

@MainActor
struct GoogleSignInCoordinatorTests {
    @Test("Returns nil when client returns nil")
    func returnsNilWhenClientReturnsNil() async throws {
        let sut = makeSUT(clientResult: nil).sut

        let result = try await sut.signIn()

        #expect(result == nil)
    }

    @Test("Returns nil when sign-in result missing id token")
    func returnsNilWhenSignInResultMissingIdToken() async throws {
        let signInResult = makeSignInResult(idTokenString: nil)
        let sut = makeSUT(clientResult: signInResult).sut

        let result = try await sut.signIn()

        #expect(result == nil)
    }

    @Test("Returns credential info with email and token when sign-in succeeds")
    func returnsCredentialInfoWithEmailAndTokenWhenSignInSucceeds() async throws {
        let email = "tester@gmail.com"
        let idToken = "id-token-123"
        let accessToken = "access-token-456"
        let signInResult = makeSignInResult(idTokenString: idToken, accessTokenString: accessToken, email: email)
        let sut = makeSUT(clientResult: signInResult).sut

        let result = try #require(try await sut.signIn())

        #expect(result.email == email)
        #expect(result.tokenId == idToken)
        #expect(result.accessTokenId == accessToken)
    }

    @Test("Combines given name and family name into display name")
    func combinesGivenNameAndFamilyNameIntoDisplayName() async throws {
        let givenName = "John"
        let familyName = "Doe"
        let signInResult = makeSignInResult(givenName: givenName, familyName: familyName)
        let sut = makeSUT(clientResult: signInResult).sut

        let result = try #require(try await sut.signIn())

        #expect(result.displayName == "\(givenName) \(familyName)")
    }

    @Test("Handles partial name with only given name")
    func handlesPartialNameWithOnlyGivenName() async throws {
        let givenName = "John"
        let signInResult = makeSignInResult(givenName: givenName, familyName: nil)
        let sut = makeSUT(clientResult: signInResult).sut

        let result = try #require(try await sut.signIn())

        #expect(result.displayName == givenName)
    }

    @Test("Handles partial name with only family name")
    func handlesPartialNameWithOnlyFamilyName() async throws {
        let familyName = "Doe"
        let signInResult = makeSignInResult(givenName: nil, familyName: familyName)
        let sut = makeSUT(clientResult: signInResult).sut

        let result = try #require(try await sut.signIn())

        #expect(result.displayName == familyName)
    }

    @Test("Handles empty display name when both names are nil")
    func handlesEmptyDisplayNameWhenBothNamesAreNil() async throws {
        let signInResult = makeSignInResult(givenName: nil, familyName: nil)
        let sut = makeSUT(clientResult: signInResult).sut

        let displayName = try #require(try await sut.signIn()?.displayName)

        #expect(displayName.isEmpty)
    }

    @Test("Propagates errors from client")
    func propagatesErrorsFromClient() async {
        enum TestError: Error { case signInFailed }
        let sut = makeSUT(clientResult: nil, clientError: TestError.signInFailed).sut

        await #expect(throws: TestError.signInFailed) {
            _ = try await sut.signIn()
        }
    }
}


// MARK: - SUT
private extension GoogleSignInCoordinatorTests {
    func makeSUT(clientResult: GoogleSignInResult?, clientError: (any Error)? = nil) -> (sut: GoogleSignInCoordinator, client: MockClient) {
        let client = MockClient(result: clientResult, error: clientError)
        let sut = GoogleSignInCoordinator(client: client)

        return (sut, client)
    }

    func makeSignInResult(idTokenString: String? = "id-token", accessTokenString: String = "access-token", email: String? = "test@gmail.com", givenName: String? = "Test", familyName: String? = "User") -> GoogleSignInResult {
        return .init(idTokenString: idTokenString, accessTokenString: accessTokenString, email: email, givenName: givenName, familyName: familyName)
    }
}


// MARK: - Mocks
private extension GoogleSignInCoordinatorTests {
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
