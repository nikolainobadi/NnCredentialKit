//
//  AccountLinkViewModel.swift
//
//
//  Created by Nikolai Nobadi on 8/1/24.
//

import Foundation

final class AccountLinkViewModel: ObservableObject {
    @Published var providers: [AuthProvider]
    @Published var showingEmailSignUpAlert: Bool
    
    private let delegate: AccountLinkDelegate
    
    init(providers: [AuthProvider] = [], showingEmailSignUpAlert: Bool = false, delegate: AccountLinkDelegate) {
        self.delegate = delegate
        self.providers = providers
        self.showingEmailSignUpAlert = showingEmailSignUpAlert
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
        if provider.isLinked {
            await showEmailAlert()
        } else {
            // TODO: - perform accountLink
        }
    }
    
    func unlinkAccount(_ provider: AuthProvider) async throws {
        // TODO: - perform unlink
    }
}


// MARK: - MainActor
@MainActor
private extension AccountLinkViewModel {
    func showEmailAlert() {
        showingEmailSignUpAlert = true
    }
}


// MARK: - Dependencies
protocol AccountLinkDelegate: ReauthenticationDelegate {
    func linkProvider(with: CredentialType) async throws
    func unlinkProvider(_ type: AuthProviderType) async throws
}


