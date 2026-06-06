//
//  AppleSignInServiceTests.swift
//  NnCredentialKit
//
//  Created by Nikolai Nobadi on 9/28/25.
//

import Testing
import AuthenticationServices
@testable import NnCredentialKit

@MainActor
struct AppleSignInServiceTests {
    @Test
    func `Uses default scopes and hashed nonce when starting session`() async throws {
        let nonce = "nonce-123"
        let (sut, session) = makeSUT(nonce: nonce)

        _ = try await sut.createAppleTokenInfo()

        let captured = try #require(session.captured)
        #expect(captured.scopes == [.email, .fullName])
        #expect(captured.nonce == "HASH(\(nonce))")
    }

    @Test
    func `Uses custom scopes and hashed nonce when provided`() async throws {
        let nonce = "abc"
        let customScopes: [ASAuthorization.Scope] = [.fullName]
        let (sut, session) = makeSUT(nonce: nonce)

        _ = try await sut.createAppleTokenInfo(requestedScopes: customScopes)

        let captured = try #require(session.captured)
        #expect(captured.scopes == customScopes)
        #expect(captured.nonce == "HASH(\(nonce))")
    }

    @Test
    func `Returns nil on user cancel from ASAuthorizationError`() async throws {
        let sut = makeSUT().sut
        let result = try await sut.createAppleTokenInfo()

        #expect(result == nil)
    }

    @Test
    func `Returns nil on user cancel from AppleSignInError`() async throws {
        let sut = makeSUT(result: .failure(AppleSignInError.canceled)).sut
        let result = try await sut.createAppleTokenInfo()

        #expect(result == nil)
    }

    @Test
    func `Throws on non cancel errors`() async {
        enum E: Error { case boom }
        let sut = makeSUT(result: .failure(E.boom)).sut

        await #expect(throws: E.boom) {
            _ = try await sut.createAppleTokenInfo()
        }
    }
    
    @Test
    func `Returns token info with email and full name from credential`() async throws {
        let email = "tester@gmail.com"
        let firstName = "mr"
        let lastName = "sir"
        let raw = makeRawCredential(email: email, firstName: firstName, lastName: lastName, idTokenData: .init())
        let sut = makeSUT(result: .success(raw)).sut
        let result = try #require(try await sut.createAppleTokenInfo())
        
        #expect(result.email == email)
        #expect(result.displayName == "\(firstName) \(lastName)")
    }
}


// MARK: - SUT
private extension AppleSignInServiceTests {
    func makeSUT(nonce: String = "n", result: Result<AppleAuthRawCredential, any Error> = .failure(Self.makeCanceledNSError())) -> (sut: AppleSignInService, session: MockSession) {
        let provider = MockNonceProvider(nonce: nonce)
        let session = MockSession(result: result)
        let sut = AppleSignInService(session: session, provider: provider, converter: AppleCredentialConverter())

        return (sut, session)
    }
}


// MARK: - Helpers
private extension AppleSignInServiceTests {
    func makeRawCredential(email: String? = nil, firstName: String? = nil, lastName: String? = nil, idTokenData: Data? = nil) -> AppleAuthRawCredential {
        return .init(email: email, fullName: .init(givenName: firstName, familyName: lastName), idTokenData: idTokenData)
    }

    static func makeCanceledNSError() -> NSError {
        NSError(domain: ASAuthorizationError.errorDomain, code: ASAuthorizationError.canceled.rawValue)
    }
}


// MARK: - Mocks
private extension AppleSignInServiceTests {
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
