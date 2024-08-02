//
//  CredentialTypeProviderAdapter.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

import Foundation

final class CredentialTypeProviderAdapter {
    private let alertHandler = CredentialAlertHandler()
}

extension CredentialTypeProviderAdapter: CredentialTypeProvider {
    func loadCredential(_ type: AuthProviderType) -> CredentialType? {
        return nil
    }
}

extension CredentialTypeProviderAdapter: CredentialReauthenticationProvider {
    func loadReauthCredential(linkedProviders: [AuthProvider]) async throws -> CredentialType? {
        return nil
    }
}

// MARK: - Dependencies
final class CredentialAlertHandler {
    
}
