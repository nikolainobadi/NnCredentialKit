//
//  AccountLinkViewModel.swift
//
//
//  Created by Nikolai Nobadi on 8/1/24.
//

import Foundation

/// A view model responsible for managing account link/unlink actions.
@MainActor
public final class AccountLinkViewModel: ObservableObject {
    /// The list of providers currently available for linking/unlinking.
    @Published public var providers: [AuthProvider]

    /// When true, prevents displaying the link button if the provider is the only one linked to the account.
    public let preventUnlinkingLastProvider: Bool

    private let delegate: AccountLinkDelegate
    private let reauthenticator: Reauthenticator
    private let credentialProvider: CredentialTypeProvider

    /// Initializes the view model with the given parameters.
    /// - Parameters:
    ///   - providers: The initial list of providers.
    ///   - delegate: The delegate responsible for handling account link actions.
    ///   - reauthenticator: The reauthenticator responsible for handling reauthentication.
    ///   - credentialProvider: The provider responsible for loading credentials.
    ///   - preventUnlinkingLastProvider: When true, hides the link button if the provider is the only one linked. Defaults to false.
    init(providers: [AuthProvider] = [], delegate: AccountLinkDelegate, reauthenticator: Reauthenticator, credentialProvider: CredentialTypeProvider, preventUnlinkingLastProvider: Bool = false) {
        self.delegate = delegate
        self.providers = providers
        self.reauthenticator = reauthenticator
        self.credentialProvider = credentialProvider
        self.preventUnlinkingLastProvider = preventUnlinkingLastProvider
    }
}


// MARK: - Actions
public extension AccountLinkViewModel {
    /// Loads the supported providers for linking/unlinking.
    func loadProviders() {
        providers = delegate.loadSupportedProviders()
    }

    /// Determines whether the link button should be shown for a given provider.
    /// - Parameter provider: The provider to check.
    /// - Returns: True if the button should be shown, false otherwise.
    func shouldShowButton(for provider: AuthProvider) -> Bool {
        guard preventUnlinkingLastProvider else { return true }
        guard provider.isLinked else { return true }

        let linkedProviderCount = providers.filter { $0.isLinked }.count
        return linkedProviderCount > 1
    }

    /// Handles the link/unlink action for a specific provider.
    /// - Parameter provider: The provider to be linked or unlinked.
    /// - Returns: The result of the link/unlink action indicating success or cancellation.
    @discardableResult
    func linkAction(_ provider: AuthProvider) async throws -> AccountLinkActionResult {
        let result: AccountLinkActionResult

        if provider.isLinked {
            result = try await unlinkAccount(provider)
        } else {
            result = try await linkAccount(provider)
        }

        loadProviders()

        return result
    }
}


// MARK: - Private Methods
private extension AccountLinkViewModel {
    /// Links an account to a specified credential type.
    /// - Parameters:
    ///   - provider: The provider to be linked.
    ///   - credentialType: The credential type to be used for linking. Optional.
    /// - Returns: The result of the link action indicating success or cancellation.
    func linkAccount(_ provider: AuthProvider, credentialType: CredentialType? = nil) async throws -> AccountLinkActionResult {
        guard let credentialType = try await credentialProvider.loadCredential(provider.type) else {
            return .canceled
        }

        try await linkAccountToCredential(credentialType)

        return .success
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
    /// - Returns: The result of the unlink action indicating success.
    func unlinkAccount(_ provider: AuthProvider) async throws -> AccountLinkActionResult {
        guard providers.filter({ $0.isLinked }).count > 1 else {
            throw CredentialError.cannotUnlinkOnlyProvider
        }

        try await handleResult(delegate.unlinkProvider(provider.type)) { [unowned self] in
            _ = try await unlinkAccount(provider)
        }

        return .success
    }
    
    /// Handles the result of a credential operation, with reauthentication if required.
    /// - Parameters:
    ///   - result: The result of the credential operation.
    ///   - action: The action to perform after reauthentication, if required.
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
