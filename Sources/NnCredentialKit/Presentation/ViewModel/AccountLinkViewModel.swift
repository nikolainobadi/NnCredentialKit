//
//  AccountLinkViewModel.swift
//
//
//  Created by Nikolai Nobadi on 8/1/24.
//

import Foundation

final class AccountLinkViewModel: ObservableObject {
    @Published var providers: [AuthProvider]
    
    private let delegate: AccountLinkDelegate
    private let reauthenticator: Reauthenticator
    private let credentialProvider: CredentialTypeProvider
    
    init(providers: [AuthProvider] = [], delegate: AccountLinkDelegate, reauthenticator: Reauthenticator, credentialProvider: CredentialTypeProvider) {
        self.delegate = delegate
        self.providers = providers
        self.reauthenticator = reauthenticator
        self.credentialProvider = credentialProvider
    }
}


// MARK: - Actions
extension AccountLinkViewModel {
    func linkAction(_ provider: AuthProvider) async throws {
        if provider.isLinked {
            try await unlinkAccount(provider)
        } else {
            try await linkAccount(provider)
        }
    }
}


// MARK: - Private Methods
private extension AccountLinkViewModel {
    func linkAccount(_ provider: AuthProvider, credentialType: CredentialType? = nil) async throws {
        guard let credentialType = try await credentialProvider.loadCredential(provider.type) else {
            return
        }
        
        try await linkAccountToCredential(credentialType)
    }
    
    func linkAccountToCredential(_ credentialType: CredentialType) async throws {
        try await handleResult(delegate.linkProvider(with: credentialType)) { [unowned self] in
            try await linkAccountToCredential(credentialType)
        }
    }
    
    func unlinkAccount(_ provider: AuthProvider) async throws {
        guard providers.filter({ $0.isLinked }).count > 1 else {
            throw CredentialError.cannotUnlinkOnlyProvider
        }
        
        try await handleResult(delegate.unlinkProvider(provider.type)) { [unowned self] in
            try await unlinkAccount(provider)
        }
    }
    
    func handleResult(_ result: AccountCredentialResult, actionAfterReauth action: @escaping () async throws -> Void) async throws {
        switch result {
        case .success:
            break
        case .failure(let error):
            throw error
        case .reauthRequired:
            try await reauthenticator.start(actionAfterReauth: action)
        }
    }
}


// MARK: - Dependencies
protocol CredentialTypeProvider {
    func loadCredential(_ type: AuthProviderType) async throws -> CredentialType?
}

public protocol AccountLinkDelegate: ReauthenticationDelegate {
    func linkProvider(with: CredentialType) async -> AccountCredentialResult
    func unlinkProvider(_ type: AuthProviderType) async -> AccountCredentialResult
}
