// AccountLinkViewModelTests.swift

import Testing
@testable import NnCredentialKit

@MainActor
struct AccountLinkViewModelTests {
    @Test
    func `SUT starts with empty values`() {
        let (sut, delegate) = makeSUT()

        #expect(sut.providers.isEmpty)
        #expect(delegate.providerType == nil)
        #expect(delegate.credentialType == nil)
    }

    @Test
    func `Returns success when linking an unlinked provider`() async throws {
        let provider = makeAuthProvider(.emailPassword)
        let credential = makeEmailPasswordCredential()
        let sut = makeSUT(credentialType: credential).sut

        let result = try await sut.linkAction(provider)

        #expect(result == .success)
    }

    @Test
    func `Sends credential to delegate without unlinking when provider is not linked`() async throws {
        let provider = makeAuthProvider(.emailPassword)
        let credential = makeEmailPasswordCredential()
        let (sut, delegate) = makeSUT(credentialType: credential)

        _ = try await sut.linkAction(provider)

        let credentialType = try #require(delegate.credentialType)

        #expect(delegate.providerType == nil)
        #expect(credentialType.id == credential.id)
    }

    @Test
    func `Throws error when credential provider fails`() async {
        let provider = makeAuthProvider(.emailPassword)
        let sut = makeSUT(throwProviderError: true).sut

        await #expect(throws: TestError.credentialTypeProvider) {
            _ = try await sut.linkAction(provider)
        }
    }

    @Test
    func `Does not contact delegate when credential provider fails`() async {
        let provider = makeAuthProvider(.emailPassword)
        let (sut, delegate) = makeSUT(throwProviderError: true)

        _ = try? await sut.linkAction(provider)

        #expect(delegate.providerType == nil)
        #expect(delegate.credentialType == nil)
    }

    @Test
    func `Returns canceled result when credential is nil`() async throws {
        let provider = makeAuthProvider(.emailPassword)
        let sut = makeSUT().sut

        let result = try await sut.linkAction(provider)

        #expect(result == .canceled)
    }

    @Test
    func `Does not contact delegate when credential is nil`() async throws {
        let provider = makeAuthProvider(.emailPassword)
        let (sut, delegate) = makeSUT()

        _ = try await sut.linkAction(provider)

        #expect(delegate.providerType == nil)
        #expect(delegate.credentialType == nil)
    }

    @Test
    func `Throws error when reauthentication fails`() async {
        let error = TestError.reauth
        let provider = makeAuthProvider(.emailPassword)
        let credential = makeEmailPasswordCredential()
        let sut = makeSUT(credentialType: credential, firstResult: .failure(error)).sut

        await #expect(throws: error) {
            _ = try await sut.linkAction(provider)
        }
    }

    @Test
    func `Retries linking after successful reauthentication`() async {
        let error = TestError.postReauthorizationAction
        let provider = makeAuthProvider(.emailPassword)
        let credential = makeEmailPasswordCredential()
        let sut = makeSUT(credentialType: credential, firstResult: .reauthRequired, secondResult: .failure(error)).sut

        await #expect(throws: error) {
            _ = try await sut.linkAction(provider)
        }
    }

    @Test
    func `Returns success when unlinking with multiple linked providers`() async throws {
        let provider = makeAuthProvider(.emailPassword, email: "tester@gmail.com")
        let secondProvider = makeAuthProvider(.apple, email: "tester@apple.com")
        let sut = makeSUT(providers: [provider, secondProvider]).sut

        let result = try await sut.linkAction(provider)

        #expect(result == .success)
    }

    @Test
    func `Sends provider type to delegate when unlinking with multiple linked providers`() async throws {
        let provider = makeAuthProvider(.emailPassword, email: "tester@gmail.com")
        let secondProvider = makeAuthProvider(.apple, email: "tester@apple.com")
        let (sut, delegate) = makeSUT(providers: [provider, secondProvider])

        _ = try await sut.linkAction(provider)

        #expect(delegate.providerType == provider.type)
    }

    @Test
    func `Throws when trying to unlink the only linked provider`() async {
        let provider = makeAuthProvider(.emailPassword, email: "tester@gmail.com")
        let sut = makeSUT(providers: [provider]).sut

        await #expect(throws: CredentialError.cannotUnlinkOnlyProvider) {
            _ = try await sut.linkAction(provider)
        }
    }
}


// MARK: - Button Display Tests
extension AccountLinkViewModelTests {
    @Test
    func `Shows button when prevent flag disabled`() {
        let provider = makeAuthProvider(.emailPassword, email: "tester@gmail.com")
        let sut = makeSUT(providers: [provider], preventUnlinkingLastProvider: false).sut

        #expect(sut.shouldShowButton(for: provider))
    }

    @Test
    func `Shows button for unlinked provider when prevent flag enabled`() {
        let provider = makeAuthProvider(.emailPassword)
        let sut = makeSUT(providers: [provider], preventUnlinkingLastProvider: true).sut

        #expect(sut.shouldShowButton(for: provider))
    }

    @Test
    func `Shows button for linked provider when multiple providers linked and prevent flag enabled`() {
        let provider = makeAuthProvider(.emailPassword, email: "tester@gmail.com")
        let secondProvider = makeAuthProvider(.apple, email: "tester@apple.com")
        let sut = makeSUT(providers: [provider, secondProvider], preventUnlinkingLastProvider: true).sut

        #expect(sut.shouldShowButton(for: provider))
    }

    @Test
    func `Hides button for linked provider when only provider linked and prevent flag enabled`() {
        let provider = makeAuthProvider(.emailPassword, email: "tester@gmail.com")
        let sut = makeSUT(providers: [provider], preventUnlinkingLastProvider: true).sut

        #expect(!sut.shouldShowButton(for: provider))
    }

    @Test
    func `Shows button for linked provider when only provider linked and prevent flag disabled`() {
        let provider = makeAuthProvider(.emailPassword, email: "tester@gmail.com")
        let sut = makeSUT(providers: [provider], preventUnlinkingLastProvider: false).sut

        #expect(sut.shouldShowButton(for: provider))
    }
}


// MARK: - SUT
private extension AccountLinkViewModelTests {
    func makeSUT(providers: [AuthProvider] = [], credentialType: CredentialType? = nil, firstResult: AccountCredentialResult = .success, secondResult: AccountCredentialResult = .success, throwProviderError: Bool = false, throwReauthError: Bool = false, preventUnlinkingLastProvider: Bool = false) -> (sut: AccountLinkViewModel, delegate: MockDelegate) {
        let delegate = MockDelegate(firstResult: firstResult, secondResult: secondResult, supportedProviders: providers)
        let auth = MockReauthenticator(throwError: throwReauthError)
        let provider = MockCredentialProvider(credentialType: credentialType, throwError: throwProviderError)
        let sut = AccountLinkViewModel(providers: providers, delegate: delegate, reauthenticator: auth, credentialProvider: provider, preventUnlinkingLastProvider: preventUnlinkingLastProvider)

        return (sut, delegate)
    }
}


// MARK: - Helpers
private extension AccountLinkViewModelTests {
    func makeAuthProvider(_ type: AuthProviderType, email: String = "") -> AuthProvider {
        return .init(linkedEmail: email, type: type)
    }
    
    func makeEmailPasswordCredential(email: String = "tester@gmail.com", password: String = "tester") -> CredentialType {
        return .emailPassword(email: email, password: password)
    }
}


// MARK: - Mocks
private extension AccountLinkViewModelTests {
    final class MockCredentialProvider: CredentialTypeProvider {
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
