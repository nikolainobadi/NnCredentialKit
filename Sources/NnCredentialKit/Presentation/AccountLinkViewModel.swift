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
    private let credentialProvider: CredentialTypeProvider
    
    init(providers: [AuthProvider] = [], delegate: AccountLinkDelegate, credentialProvider: CredentialTypeProvider) {
        self.delegate = delegate
        self.providers = providers
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
    func linkAccount(_ provider: AuthProvider) async throws {
        guard let credentialType = credentialProvider.loadCredential(provider.type) else {
            return
        }
        
        try await delegate.linkProvider(with: credentialType)
        
        // TODO: - reload providers
    }
    
    func unlinkAccount(_ provider: AuthProvider) async throws {
        guard providers.filter({ $0.isLinked }).count > 1 else {
            throw CredentialError.cannotUnlinkOnlyProvider
        }
        
        try await delegate.unlinkProvider(provider.type)
        
        // TODO: - reload providers
    }
}


// MARK: - Dependencies
protocol CredentialTypeProvider {
    func loadCredential(_ type: AuthProviderType) -> CredentialType?
}

public protocol AccountLinkDelegate: ReauthenticationDelegate {
    func linkProvider(with: CredentialType) async throws
    func unlinkProvider(_ type: AuthProviderType) async throws
}
