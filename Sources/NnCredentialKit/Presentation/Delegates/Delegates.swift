//
//  Delegates.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

// MARK: - Public
/// A protocol defining the required methods for deleting an account.
public protocol DeleteAccountDelegate: ReauthenticationDelegate {
    /// Deletes the user's account.
    /// - Returns: The result of the account deletion operation.
    func deleteAccount() async -> AccountCredentialResult
}

/// A protocol defining the required methods for handling reauthentication.
public protocol ReauthenticationDelegate {
    /// Loads the providers currently linked to the user's account.
    /// - Returns: An array of linked `AuthProvider` objects.
    func loadLinkedProviders() -> [AuthProvider]
    
    /// Reauthenticates the user with a specified credential type.
    /// - Parameter credentialType: The credential type to use for reauthentication.
    /// - Throws: An error if reauthentication fails.
    func reauthenticate(with credientialType: CredentialType) async throws
}

/// A protocol defining the required methods for handling account link operations.
public protocol AccountLinkDelegate: ReauthenticationDelegate {
    /// Loads the providers supported by the application.
    /// - Returns: An array of supported `AuthProvider` objects.
    func loadSupportedProviders() -> [AuthProvider]
    
    /// Links the user's account to a specified provider.
    /// - Parameter type: The credential type to use for linking.
    /// - Returns: The result of the account link operation.
    func linkProvider(with type: CredentialType) async -> AccountCredentialResult
    
    /// Unlinks the user's account from a specified provider.
    /// - Parameter type: The type of the provider to unlink.
    /// - Returns: The result of the account unlink operation.
    func unlinkProvider(_ type: AuthProviderType) async -> AccountCredentialResult
}


// MARK: - Internal
/// A protocol defining the required methods for handling reauthentication flows.
protocol Reauthenticator {
    /// Starts the reauthentication process and performs an action upon successful reauthentication.
    /// - Parameter actionAfterReauth: The action to perform after reauthentication.
    /// - Throws: An error if reauthentication or the subsequent action fails.
    func start(actionAfterReauth: @escaping () async throws -> Void) async throws
}

/// A protocol defining the required methods for loading credentials.
protocol CredentialTypeProvider {
    /// Loads the credential for a specific authentication provider type.
    /// - Parameter type: The type of the authentication provider.
    /// - Returns: The loaded `CredentialType` or `nil` if the operation fails.
    func loadCredential(_ type: AuthProviderType) async throws -> CredentialType?
}

/// A protocol defining the required methods for loading reauthentication credentials.
protocol CredentialReauthenticationProvider {
    /// Loads the credential for reauthentication with linked providers.
    /// - Parameter linkedProviders: The list of linked authentication providers.
    /// - Returns: The loaded `CredentialType` or `nil` if the operation fails.
    func loadReauthCredential(linkedProviders: [AuthProvider]) async throws -> CredentialType?
}
