//
//  CredentialManagerTests.swift
//
//
//  Created by Nikolai Nobadi on 8/3/24.
//

import Testing
@testable import NnCredentialKit

@MainActor
struct CredentialManagerTests {
    @Test("Returns nil when user cancels sign-in", arguments: AuthProviderType.allCases)
    func returnsNilOnUserCancel(providerType: AuthProviderType) async throws {
        let sut = makeSUT()
        let result = try await sut.loadCredential(providerType)
        
        #expect(result == nil)
    }

    @Test("Loads Apple credential for .apple")
    func loadsAppleCredential() async throws {
        let credential = makeAppleCredential()
        let sut = makeSUT(appleCredential: credential)
        let result = try #require(try await sut.loadCredential(.apple))

        #expect(result.id == CredentialType.apple(.init(email: nil, displayName: nil, idTokenString: "", nonce: "")).id)
    }

    @Test("Loads Google credential for .google")
    func loadsGoogleCredential() async throws {
        let credential = makeGoogleCredential()
        let sut = makeSUT(googleCredential: credential)
        let result = try #require(try await sut.loadCredential(.google))

        #expect(result.id == CredentialType.google(makeGoogleCredential()).id)
    }

    @Test("Loads email credential for .emailPassword")
    func loadsEmailCredential() async throws {
        let info = makeEmailInfo()
        let sut = makeSUT(info: info)
        let result = try #require(try await sut.loadCredential(.emailPassword))

        #expect(result.id == CredentialType.emailPassword(email: info.email, password: info.password).id)
    }

    @Test("Throws if email password confirm does not match")
    func throwsWhenPasswordsDoNotMatch() async {
        let sut = makeSUT(info: makeEmailInfo(password: "one", confirm: "two"))

        await #expect(throws: CredentialError.passwordsMustMatch) {
            _ = try await sut.loadCredential(.emailPassword)
        }
    }

    @Test("Returns nil on reauthentication cancel")
    func returnsNilOnReauthCancel() async throws {
        let linked = makeLinkedProviders()
        for type in AuthProviderType.allCases {
            let sut = makeSUT(selectedProvider: .init(linkedEmail: "", type: type))
            let result = try await sut.loadReauthCredential(linkedProviders: linked)
            #expect(result == nil)
        }
    }

    @Test("Throws when no linked providers exist")
    func throwsWhenNoLinkedProviders() async {
        let sut = makeSUT()
        await #expect(throws: CredentialError.emptyAuthProviders) {
            _ = try await sut.loadReauthCredential(linkedProviders: [])
        }
    }

    @Test("Loads Apple credential on reauth")
    func loadsAppleOnReauth() async throws {
        let linked = makeLinkedProviders()
        let selected = makeAuthProvider(.apple)
        let sut = makeSUT(selectedProvider: selected, appleCredential: makeAppleCredential())
        let result = try #require(try await sut.loadReauthCredential(linkedProviders: linked))

        #expect(result.id == CredentialType.apple(makeAppleCredential()).id)
    }

    @Test("Loads Google credential on reauth")
    func loadsGoogleOnReauth() async throws {
        let linked = makeLinkedProviders()
        let selected = makeAuthProvider(.google)
        let sut = makeSUT(selectedProvider: selected, googleCredential: makeGoogleCredential())
        let result = try #require(try await sut.loadReauthCredential(linkedProviders: linked))

        #expect(result.id == CredentialType.google(makeGoogleCredential()).id)
    }

    @Test("Loads email credential on reauth")
    func loadsEmailOnReauth() async throws {
        let linked = makeLinkedProviders()
        let selected = makeAuthProvider(.emailPassword)
        let info = makeEmailInfo()
        let sut = makeSUT(password: info.password, selectedProvider: selected)
        let result = try #require(try await sut.loadReauthCredential(linkedProviders: linked))

        #expect(result.id == CredentialType.emailPassword(email: info.email, password: info.password).id)
    }
}


// MARK: - Helpers
private extension CredentialManagerTests {
    func makeSUT(
        info: EmailSignUpInfo? = nil,
        password: String? = nil,
        selectedProvider: AuthProvider? = nil,
        appleCredential: AppleCredentialInfo? = nil,
        googleCredential: GoogleCredentialInfo? = nil,
        throwProviderError: Bool = false
    ) -> CredentialManager {
        let alerts = StubAlerts(info: info, password: password, selectedProvider: selectedProvider)
        let provider = StubProvider(
            throwError: throwProviderError,
            appleCredential: appleCredential,
            googleCredential: googleCredential
        )
        return CredentialManager(alertHandler: alerts, socialCredentialProvider: provider)
    }

    func makeAppleCredential() -> AppleCredentialInfo {
        .init(email: "", displayName: "", idTokenString: "", nonce: "")
    }

    func makeGoogleCredential() -> GoogleCredentialInfo {
        .init(email: "", displayName: "", tokenId: "", accessTokenId: "")
    }

    func makeEmailInfo(
        email: String = "tester@gmail.com",
        password: String = "tester",
        confirm: String? = nil
    ) -> EmailSignUpInfo {
        .init(email: email, password: password, confirm: confirm ?? password)
    }

    func makeLinkedProviders(types: [AuthProviderType] = AuthProviderType.allCases) -> [AuthProvider] {
        types.map { makeAuthProvider($0, email: "linked@\($0.rawValue).com") }
    }

    func makeAuthProvider(_ type: AuthProviderType, email: String = "") -> AuthProvider {
        .init(linkedEmail: email, type: type)
    }
}


// MARK: - Stubs
private extension CredentialManagerTests {
    final class StubAlerts: CredentialAlerts {
        private let info: EmailSignUpInfo?
        private let password: String?
        private let selectedProvider: AuthProvider?

        init(info: EmailSignUpInfo?, password: String?, selectedProvider: AuthProvider?) {
            self.info = info
            self.password = password
            self.selectedProvider = selectedProvider
        }

        func loadEmailSignUpInfo() async -> EmailSignUpInfo? { info }
        func loadPassword(_ message: String) async -> String? { password }
        func showReauthenticationAlert(providers: [AuthProvider], completion: @escaping (AuthProvider?) -> Void) {
            completion(selectedProvider)
        }
    }

    final class StubProvider: SocialCredentialProvider {
        private let throwError: Bool
        private let appleCredential: AppleCredentialInfo?
        private let googleCredential: GoogleCredentialInfo?

        init(throwError: Bool, appleCredential: AppleCredentialInfo?, googleCredential: GoogleCredentialInfo?) {
            self.throwError = throwError
            self.appleCredential = appleCredential
            self.googleCredential = googleCredential
        }

        func loadAppleCredential() async throws -> AppleCredentialInfo? {
            if throwError { throw TestError.network }
            return appleCredential
        }

        func loadGoogleCredential() async throws -> GoogleCredentialInfo? {
            if throwError { throw TestError.network }
            return googleCredential
        }
    }
}
