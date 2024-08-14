//
//  Delegates.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

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
