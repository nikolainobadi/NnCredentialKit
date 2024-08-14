//
//  AccountLinkViewModel.swift
//
//
//  Created by Nikolai Nobadi on 8/1/24.
//

import Foundation

/// A view model responsible for managing account link/unlink actions.
public final class AccountLinkViewModel: ObservableObject {
    /// The list of providers currently available for linking/unlinking.
    @Published public var providers: [AuthProvider]
    
    private let delegate: AccountLinkDelegate
    private let reauthenticator: Reauthenticator
    private let credentialProvider: CredentialTypeProvider
    
    /// Initializes the view model with the given parameters.
    /// - Parameters:
    ///   - providers: The initial list of providers.
    ///   - delegate: The delegate responsible for handling account link actions.
    ///   - reauthenticator: The reauthenticator responsible for handling reauthentication.
    ///   - credentialProvider: The provider responsible for loading credentials.
    init(providers: [AuthProvider] = [], delegate: AccountLinkDelegate, reauthenticator: Reauthenticator, credentialProvider: CredentialTypeProvider) {
        self.delegate = delegate
        self.providers = providers
        self.reauthenticator = reauthenticator
        self.credentialProvider = credentialProvider
    }
}


// MARK: - Actions
public extension AccountLinkViewModel {
    /// Loads the supported providers for linking/unlinking.
    @MainActor
    func loadProviders() {
        providers = delegate.loadSupportedProviders()
    }
    
    /// Handles the link/unlink action for a specific provider.
    /// - Parameter provider: The provider to be linked or unlinked.
    func linkAction(_ provider: AuthProvider) async throws {
        if provider.isLinked {
            try await unlinkAccount(provider)
        } else {
            try await linkAccount(provider)
        }
        await loadProviders()
    }
}

// MARK: - Private Methods

private extension AccountLinkViewModel {
    
    /// Links an account to a specified credential type.
    /// - Parameters:
    ///   - provider: The provider to be linked.
    ///   - credentialType: The credential type to be used for linking. Optional.
    func linkAccount(_ provider: AuthProvider, credentialType: CredentialType? = nil) async throws {
        guard let credentialType = try await credentialProvider.loadCredential(provider.type) else { return }
        try await linkAccountToCredential(credentialType)
    }
    
    /// Links an account to a specific credential.
    /// - Parameter credentialType: The credential to be used for linking.
    func linkAccountToCredential(_ credentialType: CredentialType) async throws {
        try await handleResult(delegate.linkProvider(with: credentialType)) { [unowned self] in
            try await linkAccountToCredential(credentialType)
        }
    }
    
    /// Unlinks an account from a specific provider.
    /// - Parameter provider: The provider to be unlinked.
    func unlinkAccount(_ provider: AuthProvider) async throws {
        guard providers.filter({ $0.isLinked }).count > 1 else {
            throw CredentialError.cannotUnlinkOnlyProvider
        }
        try await handleResult(delegate.unlinkProvider(provider.type)) { [unowned self] in
            try await unlinkAccount(provider)
        }
    }
    
    /// Handles the result of a credential operation, with reauthentication if required.
    /// - Parameters:
    ///   - result: The result of the credential operation.
    ///   - action: The action to perform after reauthentication, if required.
    func handleResult(_ result: AccountCredentialResult, actionAfterReauth action: @escaping () async throws -> Void) async throws {
        switch result {
        case .success: break
        case .failure(let error): throw error
        case .reauthRequired: try await reauthenticator.start(actionAfterReauth: action)
        }
    }
}
