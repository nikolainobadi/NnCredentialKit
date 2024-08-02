//
//  CredentialTypeProviderAdapter.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

import Foundation

final class CredentialTypeProviderAdapter { }

extension CredentialTypeProviderAdapter: CredentialTypeProvider {
    func loadCredential(_ type: AuthProviderType) -> CredentialType? {
        return nil
    }
}

extension CredentialTypeProviderAdapter: CredentialReauthenticationProvider {
    func loadReauthCredential(for type: AuthProviderType) async throws -> CredentialType? {
        return nil
    }
}
