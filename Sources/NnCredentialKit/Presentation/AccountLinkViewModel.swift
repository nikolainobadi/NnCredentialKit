//
//  AccountLinkViewModel.swift
//
//
//  Created by Nikolai Nobadi on 8/1/24.
//

import Foundation

final class AccountLinkViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirm = ""
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
    
    func performEmailPasswordAccountLink() async throws {
        try validateEmailPasswordInfo()
        try await delegate.linkProvider(with: .emailPassword(email: email, password: password))
    }
}


// MARK: - Private Methods
private extension AccountLinkViewModel {
    func linkAccount(_ provider: AuthProvider) async throws {
        switch provider.type {
        case .apple:
            // TODO: -
            try await delegate.linkProvider(with: .apple(tokenId: "", nonce: ""))
        case .google:
            // TODO: -
            try await delegate.linkProvider(with: .google(tokenId: "", accessToken: ""))
        case .emailPassword:
            await showEmailAlert()
        }
    }
    
    func unlinkAccount(_ provider: AuthProvider) async throws {
        guard providers.filter({ $0.isLinked }).count > 1 else {
            // TODO: - throw cannotUnlinkOnlyProvider error
            fatalError()
        }
        
        try await delegate.unlinkProvider(provider.type)
    }
    
    func validateEmailPasswordInfo() throws {
        // TODO: -
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
