//
//  Delegates.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

// MARK: - Public
public protocol DeleteAccountDelegate: ReauthenticationDelegate {
    func deleteAccount() async -> AccountCredentialResult
}

public protocol ReauthenticationDelegate {
    func loadLinkedProviders() -> [AuthProvider]
    func reauthenticate(with credientialType: CredentialType) async throws
}

public protocol AccountLinkDelegate: ReauthenticationDelegate {
    func loadSupportedProviders() -> [AuthProvider]
    func linkProvider(with type: CredentialType) async -> AccountCredentialResult
    func unlinkProvider(_ type: AuthProviderType) async -> AccountCredentialResult
}


// MARK: - Internal
protocol Reauthenticator {
    func start(actionAfterReauth: @escaping () async throws -> Void) async throws
}

protocol CredentialTypeProvider {
    func loadCredential(_ type: AuthProviderType) async throws -> CredentialType?
}

protocol CredentialReauthenticationProvider {
    func loadReauthCredential(linkedProviders: [AuthProvider]) async throws -> CredentialType?
}
