// AccountLinkViewModelTests.swift

import Testing
@testable import NnCredentialKit

@MainActor
struct AccountLinkViewModelTests {
    @Test("SUT starts with empty values")
    func startsWithEmptyValues() {
        let (sut, delegate) = makeSUT()

        #expect(sut.providers.isEmpty)
        #expect(delegate.providerType == nil)
        #expect(delegate.credentialType == nil)
    }

    @Test("Links account when provider is not linked")
    func linksAccountIfNotLinked() async throws {
        let provider = makeAuthProvider(.emailPassword)
        let credential = makeEmailPasswordCredential()
        let (sut, delegate) = makeSUT(credentialType: credential)

        let result = try await sut.linkAction(provider)

        let credentialType = try #require(delegate.credentialType)

        #expect(result == .success)
        #expect(delegate.providerType == nil)
        #expect(credentialType.id == CredentialType.emailPassword(email: "", password: "").id)
    }

    @Test("Throws error when credential provider fails")
    func throwsIfCredentialProviderFails() async {
        let provider = makeAuthProvider(.emailPassword)
        let (sut, delegate) = makeSUT(throwProviderError: true)

        await #expect(throws: TestError.credentialTypeProvider) {
            _ = try await sut.linkAction(provider)
        }

        #expect(delegate.providerType == nil)
        #expect(delegate.credentialType == nil)
    }

    @Test("Returns canceled result when credential is nil")
    func returnsCanceledWhenCredentialIsNil() async throws {
        let provider = makeAuthProvider(.emailPassword)
        let (sut, delegate) = makeSUT()

        let result = try await sut.linkAction(provider)

        #expect(result == .canceled)
        #expect(delegate.providerType == nil)
        #expect(delegate.credentialType == nil)
    }

    @Test("Throws error when reauthentication fails")
    func throwsWhenReauthenticationFails() async {
        let error = TestError.reauth
        let provider = makeAuthProvider(.emailPassword)
        let credential = makeEmailPasswordCredential()
        let (sut, _) = makeSUT(credentialType: credential, firstResult: .failure(error))

        await #expect(throws: error) {
            _ = try await sut.linkAction(provider)
        }
    }

    @Test("Retries linking after successful reauthentication")
    func retriesAfterReauth() async {
        let error = TestError.postReauthorizationAction
        let provider = makeAuthProvider(.emailPassword)
        let credential = makeEmailPasswordCredential()
        let (sut, _) = makeSUT(credentialType: credential, firstResult: .reauthRequired, secondResult: .failure(error))

        await #expect(throws: error) {
            _ = try await sut.linkAction(provider)
        }
    }

    @Test("Unlinks provider when more than one is linked")
    func unlinksWhenMultipleProvidersExist() async throws {
        let provider = makeAuthProvider(.emailPassword, email: "tester@gmail.com")
        let secondProvider = makeAuthProvider(.apple, email: "tester@apple.com")
        let (sut, delegate) = makeSUT(providers: [provider, secondProvider])

        let result = try await sut.linkAction(provider)

        #expect(result == .success)
        #expect(delegate.providerType == provider.type)
    }

    @Test("Throws when trying to unlink the only linked provider")
    func throwsIfUnlinkingOnlyLinkedProvider() async {
        let provider = makeAuthProvider(.emailPassword, email: "tester@gmail.com")
        let (sut, _) = makeSUT(providers: [provider])

        await #expect(throws: CredentialError.cannotUnlinkOnlyProvider) {
            _ = try await sut.linkAction(provider)
        }
    }
}


// MARK: - Button Display Tests
extension AccountLinkViewModelTests {
    @Test("Shows button when prevent flag disabled")
    func showsButtonWhenPreventFlagDisabled() {
        let provider = makeAuthProvider(.emailPassword, email: "tester@gmail.com")
        let (sut, _) = makeSUT(providers: [provider], preventUnlinkingLastProvider: false)

        #expect(sut.shouldShowButton(for: provider))
    }

    @Test("Shows button for unlinked provider when prevent flag enabled")
    func showsButtonForUnlinkedProviderWhenPreventFlagEnabled() {
        let provider = makeAuthProvider(.emailPassword)
        let (sut, _) = makeSUT(providers: [provider], preventUnlinkingLastProvider: true)

        #expect(sut.shouldShowButton(for: provider))
    }

    @Test("Shows button for linked provider when multiple providers linked and prevent flag enabled")
    func showsButtonForLinkedProviderWhenMultipleProvidersLinkedAndPreventFlagEnabled() {
        let provider = makeAuthProvider(.emailPassword, email: "tester@gmail.com")
        let secondProvider = makeAuthProvider(.apple, email: "tester@apple.com")
        let (sut, _) = makeSUT(providers: [provider, secondProvider], preventUnlinkingLastProvider: true)

        #expect(sut.shouldShowButton(for: provider))
    }

    @Test("Hides button for linked provider when only provider linked and prevent flag enabled")
    func hidesButtonForLinkedProviderWhenOnlyProviderLinkedAndPreventFlagEnabled() {
        let provider = makeAuthProvider(.emailPassword, email: "tester@gmail.com")
        let (sut, _) = makeSUT(providers: [provider], preventUnlinkingLastProvider: true)

        #expect(!sut.shouldShowButton(for: provider))
    }

    @Test("Shows button for linked provider when only provider linked and prevent flag disabled")
    func showsButtonForLinkedProviderWhenOnlyProviderLinkedAndPreventFlagDisabled() {
        let provider = makeAuthProvider(.emailPassword, email: "tester@gmail.com")
        let (sut, _) = makeSUT(providers: [provider], preventUnlinkingLastProvider: false)

        #expect(sut.shouldShowButton(for: provider))
    }
}


// MARK: - SUT
private extension AccountLinkViewModelTests {
    func makeSUT(providers: [AuthProvider] = [], credentialType: CredentialType? = nil, firstResult: AccountCredentialResult = .success, secondResult: AccountCredentialResult = .success, throwProviderError: Bool = false, throwReauthError: Bool = false, preventUnlinkingLastProvider: Bool = false) -> (sut: AccountLinkViewModel, delegate: MockDelegate) {
        let delegate = MockDelegate(firstResult: firstResult, secondResult: secondResult, supportedProviders: providers)
        let auth = MockReauthenticator(throwError: throwReauthError)
        let provider = StubProvider(credentialType: credentialType, throwError: throwProviderError)
        let sut = AccountLinkViewModel(providers: providers, delegate: delegate, reauthenticator: auth, credentialProvider: provider, preventUnlinkingLastProvider: preventUnlinkingLastProvider)

        return (sut, delegate)
    }
    
    func makeAuthProvider(_ type: AuthProviderType, email: String = "") -> AuthProvider {
        return .init(linkedEmail: email, type: type)
    }
    
    func makeEmailPasswordCredential(email: String = "tester@gmail.com", password: String = "tester") -> CredentialType {
        return .emailPassword(email: email, password: password)
    }
}


// MARK: - Helper Classes
private extension AccountLinkViewModelTests {
    final class StubProvider: CredentialTypeProvider {
        private let throwError: Bool
        private let credentialType: CredentialType?

        init(credentialType: CredentialType?, throwError: Bool) {
            self.throwError = throwError
            self.credentialType = credentialType
        }

        func loadCredential(_ type: AuthProviderType) async throws -> CredentialType? {
            if throwError {
                throw TestError.credentialTypeProvider
            }

            return credentialType
        }
    }

    final class MockDelegate: AccountLinkDelegate, @unchecked Sendable {
        private let store: StubResultStore
        private let supportedProviders: [AuthProvider]
        private(set) var credentialType: CredentialType?
        private(set) var providerType: AuthProviderType?

        init(firstResult: AccountCredentialResult, secondResult: AccountCredentialResult, supportedProviders: [AuthProvider]) {
            self.store = .init(firstResult: firstResult, secondResult: secondResult)
            self.supportedProviders = supportedProviders
        }

        func loadSupportedProviders() -> [AuthProvider] {
            supportedProviders
        }

        func linkProvider(with type: CredentialType) async -> AccountCredentialResult {
            credentialType = type
            return store.getResult()
        }

        func unlinkProvider(_ type: AuthProviderType) async -> AccountCredentialResult {
            providerType = type
            return store.getResult()
        }

        // MARK: - Unused
        func loadLinkedProviders() -> [AuthProvider] { [] }
        func reauthenticate(with credientialType: CredentialType) async throws { }
    }
}

extension CredentialType {
    var id: String {
        switch self {
        case .apple:
            return "apple"
        case .google:
            return "google"
        case .emailPassword:
            return "emailPassword"
        }
    }
}
