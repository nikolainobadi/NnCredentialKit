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
    @Test("Throws if no linked providers exist")
    func throwsIfNoLinkedProvidersExist() async {
        let sut = makeSUT().sut

        await #expect(throws: CredentialError.emptyAuthProviders) {
            try await sut.start(actionAfterReauth: { })
        }
    }

    @Test("Throws if reauthentication is cancelled")
    func throwsIfReauthIsCancelled() async {
        let linked = makeLinkedProviders()
        let sut = makeSUT(linkedProviders: linked).sut

        await #expect(throws: CredentialError.cancelled) {
            try await sut.start(actionAfterReauth: { })
        }
    }

    @Test("Uses selected credential for reauthentication")
    func usesSelectedCredentialForReauth() async throws {
        let linked = makeLinkedProviders()
        let credential = makeEmailPasswordCredential()
        let (sut, delegate) = makeSUT(linkedProviders: linked, credentialType: credential)

        try await sut.start(actionAfterReauth: { })

        #expect(delegate.credentialType?.id == credential.id)
    }

    @Test("Performs action after successful reauth")
    func performsActionAfterReauth() async throws {
        var called = false
        let linked = makeLinkedProviders()
        let credential = makeEmailPasswordCredential()
        let (sut, _) = makeSUT(linkedProviders: linked, credentialType: credential)

        try await sut.start {
            called = true
        }

        #expect(called)
    }

    @Test("Skips action if reauth fails")
    func skipsActionIfReauthFails() async throws {
        var called = false
        let linked = makeLinkedProviders()
        let credential = makeEmailPasswordCredential()
        let (sut, _) = makeSUT(linkedProviders: linked, credentialType: credential, throwDelegateError: true)

        do {
            try await sut.start {
                called = true
            }
        } catch {}

        #expect(!called)
    }
}


// MARK: - Helpers
private extension ReauthenticationManagerTests {
    func makeSUT(
        linkedProviders: [AuthProvider] = [],
        credentialType: CredentialType? = nil,
        throwDelegateError: Bool = false,
        throwProviderError: Bool = false
    ) -> (sut: ReauthenticationManager, delegate: MockDelegate) {
        let delegate = MockDelegate(throwError: throwDelegateError, linkedProviders: linkedProviders)
        let provider = StubProvider(throwError: throwProviderError, credentialType: credentialType)
        let sut = ReauthenticationManager(delegate: delegate, credentialProvider: provider)
        return (sut, delegate)
    }

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


// MARK: - Stubs
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

    final class StubProvider: CredentialReauthenticationProvider {
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
