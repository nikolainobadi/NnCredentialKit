//
//  CredentialTypeProviderAdapter.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

import Foundation

final class CredentialTypeProviderAdapter: CredentialTypeProvider {
    func loadCredential(_ type: AuthProviderType) -> CredentialType? {
        return nil
    }
}
