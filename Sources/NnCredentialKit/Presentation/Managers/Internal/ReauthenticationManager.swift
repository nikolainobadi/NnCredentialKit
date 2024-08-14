//
//  ReauthenticationManager.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

import Foundation

/// A manager responsible for handling reauthentication flows.
final class ReauthenticationManager {
    private let delegate: ReauthenticationDelegate
    private let credentialProvider: CredentialReauthenticationProvider
    
    /// Initializes the manager with the specified delegate and credential provider.
    /// - Parameters:
    ///   - delegate: The delegate responsible for handling reauthentication actions.
    ///   - credentialProvider: The provider responsible for loading reauthentication credentials.
    init(delegate: ReauthenticationDelegate, credentialProvider: CredentialReauthenticationProvider) {
        self.delegate = delegate
        self.credentialProvider = credentialProvider
    }
}


// MARK: - Reauthenticator
extension ReauthenticationManager: Reauthenticator {
    /// Starts the reauthentication process and performs an action upon successful reauthentication.
    /// - Parameter actionAfterReauth: The action to perform after reauthentication.
    /// - Throws: An error if reauthentication or the subsequent action fails.
    func start(actionAfterReauth: @escaping () async throws -> Void) async throws {
        let linkedProviders = delegate.loadLinkedProviders()
        
        if linkedProviders.isEmpty { throw CredentialError.emptyAuthProviders }
        
        guard let selectedCredentialType = try await credentialProvider.loadReauthCredential(linkedProviders: linkedProviders) else {
            throw CredentialError.cancelled
        }
        
        try await delegate.reauthenticate(with: selectedCredentialType)
        try await actionAfterReauth()
    }
}
