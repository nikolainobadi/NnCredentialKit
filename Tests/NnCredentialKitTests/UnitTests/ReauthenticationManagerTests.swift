//
//  ReauthenticationManagerTests.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

import Testing
@testable import NnCredentialKit

@MainActor
struct ReauthenticationManagerTests {
    @Test
    func `Throws if no linked providers exist`() async {
        let sut = makeSUT().sut

        await #expect(throws: CredentialError.emptyAuthProviders) {
            try await sut.start(actionAfterReauth: { })
        }
    }

    @Test
    func `Throws if reauthentication is cancelled`() async {
        let linked = makeLinkedProviders()
        let sut = makeSUT(linkedProviders: linked).sut

        await #expect(throws: CredentialError.cancelled) {
            try await sut.start(actionAfterReauth: { })
        }
    }

    @Test
    func `Uses selected credential for reauthentication`() async throws {
        let linked = makeLinkedProviders()
        let credential = makeEmailPasswordCredential()
        let (sut, delegate) = makeSUT(linkedProviders: linked, credentialType: credential)

        try await sut.start(actionAfterReauth: { })

        let credentialType = try #require(delegate.credentialType)

        #expect(credentialType.id == credential.id)
    }

    @Test
    func `Performs action after successful reauth`() async throws {
        var called = false
        let linked = makeLinkedProviders()
        let credential = makeEmailPasswordCredential()
        let sut = makeSUT(linkedProviders: linked, credentialType: credential).sut

        try await sut.start {
            called = true
        }

        #expect(called)
    }

    @Test
    func `Skips action if reauth fails`() async throws {
        var called = false
        let linked = makeLinkedProviders()
        let credential = makeEmailPasswordCredential()
        let sut = makeSUT(linkedProviders: linked, credentialType: credential, throwDelegateError: true).sut

        do {
            try await sut.start {
                called = true
            }
        } catch {}

        #expect(!called)
    }
}


// MARK: - SUT
private extension ReauthenticationManagerTests {
    func makeSUT(
        linkedProviders: [AuthProvider] = [],
        credentialType: CredentialType? = nil,
        throwDelegateError: Bool = false,
        throwProviderError: Bool = false
    ) -> (sut: ReauthenticationManager, delegate: MockDelegate) {
        let delegate = MockDelegate(throwError: throwDelegateError, linkedProviders: linkedProviders)
        let provider = MockCredentialProvider(throwError: throwProviderError, credentialType: credentialType)
        let sut = ReauthenticationManager(delegate: delegate, credentialProvider: provider)
        return (sut, delegate)
    }
}


// MARK: - Helpers
private extension ReauthenticationManagerTests {
    func makeLinkedProviders(types: [AuthProviderType] = AuthProviderType.allCases) -> [AuthProvider] {
        types.map { .init(linkedEmail: "linked@\($0.rawValue).com", type: $0) }
    }

    func makeEmailPasswordCredential(
        email: String = "tester@gmail.com",
        password: String = "tester"
    ) -> CredentialType {
        .emailPassword(email: email, password: password)
    }
}


// MARK: - Mocks
private extension ReauthenticationManagerTests {
    final class MockDelegate: ReauthenticationDelegate, @unchecked Sendable {
        private let throwError: Bool
        private let linkedProviders: [AuthProvider]
        private(set) var credentialType: CredentialType?

        init(throwError: Bool, linkedProviders: [AuthProvider]) {
            self.throwError = throwError
            self.linkedProviders = linkedProviders
        }

        func loadLinkedProviders() -> [AuthProvider] { linkedProviders }

        func reauthenticate(with credientialType: CredentialType) async throws {
            if throwError { throw TestError.reauth }
            self.credentialType = credientialType
        }
    }

    final class MockCredentialProvider: CredentialReauthenticationProvider {
        private let throwError: Bool
        private let credentialType: CredentialType?

        init(throwError: Bool, credentialType: CredentialType?) {
            self.throwError = throwError
            self.credentialType = credentialType
        }

        func loadReauthCredential(linkedProviders: [AuthProvider]) async throws -> CredentialType? {
            if throwError { throw TestError.network }
            return credentialType
        }
    }
}
