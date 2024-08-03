//
//  ReauthenticationManager.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

final class ReauthenticationManager {
    private let delegate: ReauthenticationDelegate
    private let credentialProvider: CredentialReauthenticationProvider
    
    init(delegate: ReauthenticationDelegate, credentialProvider: CredentialReauthenticationProvider) {
        self.delegate = delegate
        self.credentialProvider = credentialProvider
    }
}


// MARK: -  Reauthenticator
extension ReauthenticationManager: Reauthenticator {
    func start(actionAfterReauth: @escaping () async throws -> Void) async throws {
        let linkedProviders = delegate.loadLinkedProviders()
        
        if linkedProviders.isEmpty {
            throw CredentialError.emptyAuthProviders
        }
        
        guard let selectedCredentialType = try await credentialProvider.loadReauthCredential(linkedProviders: linkedProviders) else {
            throw CredentialError.cancelled
        }
        
        try await delegate.reauthenticate(with: selectedCredentialType)
        try await actionAfterReauth()
    }
}
