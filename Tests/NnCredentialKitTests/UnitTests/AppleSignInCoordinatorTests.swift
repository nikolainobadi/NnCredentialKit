//
//  AppleSignInCoordinatorTests.swift
//  NnCredentialKit
//
//  Created by Nikolai Nobadi on 9/28/25.
//

import Testing
import AuthenticationServices
@testable import NnCredentialKit

@MainActor
struct AppleSignInCoordinatorTests {
    @Test("Uses default scopes and hashed nonce when starting session")
    func usesDefaultScopesAndHashedNonce() async throws {
        let nonce = "nonce-123"
        let (sut, session) = makeSUT(nonce: nonce)

        _ = try await sut.createAppleTokenInfo()

        let captured = try #require(session.captured)
        #expect(captured.scopes == [.email, .fullName])
        #expect(captured.nonce == "HASH(\(nonce))")
    }

    @Test("Uses custom scopes and hashed nonce when provided")
    func usesCustomScopes() async throws {
        let nonce = "abc"
        let customScopes: [ASAuthorization.Scope] = [.fullName]
        let (sut, session) = makeSUT(nonce: nonce)

        _ = try await sut.createAppleTokenInfo(requestedScopes: customScopes)

        let captured = try #require(session.captured)
        #expect(captured.scopes == customScopes)
        #expect(captured.nonce == "HASH(\(nonce))")
    }

    @Test("Returns nil on user cancel from ASAuthorizationError")
    func returnsNilOnSystemCancel() async throws {
        let sut = makeSUT().sut
        let result = try await sut.createAppleTokenInfo()

        #expect(result == nil)
    }

    @Test("Returns nil on user cancel from AppleSignInError")
    func returnsNilOnCustomCancel() async throws {
        let sut = makeSUT(result: .failure(AppleSignInError.canceled)).sut
        let result = try await sut.createAppleTokenInfo()

        #expect(result == nil)
    }

    @Test("Throws on non cancel errors")
    func throwsOnOtherErrors() async {
        enum E: Error { case boom }
        let sut = makeSUT(result: .failure(E.boom)).sut

        await #expect(throws: E.boom) {
            _ = try await sut.createAppleTokenInfo()
        }
    }
}


// MARK: - SUT
private extension AppleSignInCoordinatorTests {
    func makeSUT(nonce: String = "n", result: Result<AppleAuthRawCredential, any Error> = .failure(Self.makeCanceledNSError())) -> (sut: AppleSignInCoordinator, session: MockSession) {
        let provider = MockNonceProvider(nonce: nonce)
        let session = MockSession(result: result)
        let sut = AppleSignInCoordinator(session: session, provider: provider, converter: AppleCredentialConverter())
        
        return (sut, session)
    }

    static func makeCanceledNSError() -> NSError {
        NSError(domain: ASAuthorizationError.errorDomain, code: ASAuthorizationError.canceled.rawValue)
    }
}


// MARK: - Mocks
private extension AppleSignInCoordinatorTests {
    struct MockNonceProvider: NonceProvider, Sendable {
        let nonce: String
        
        func make() -> String {
            nonce
        }
        
        func hash(_ value: String) -> String {
            "HASH(\(value))"
        }
    }
    
    final class MockSession: AppleAuthSession {
        struct Capture {
            let scopes: [ASAuthorization.Scope]?
            let nonce: String
        }
        
        private let result: Result<AppleAuthRawCredential, Error>
        private(set) var captured: Capture?
        
        init(result: Result<AppleAuthRawCredential, Error>) {
            self.result = result
        }
        
        func start(scopes: [ASAuthorization.Scope]?, nonce: String, completion: @escaping (Result<AppleAuthRawCredential, Error>) -> Void) {
            captured = .init(scopes: scopes, nonce: nonce)
            completion(result)
        }
    }
}
