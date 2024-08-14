//
//  File.swift
//  
//
//  Created by Nikolai Nobadi on 8/13/24.
//

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
