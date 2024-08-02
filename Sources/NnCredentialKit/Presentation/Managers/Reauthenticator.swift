//
//  Reauthenticator.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

final class Reauthenticator {
    private let delegate: ReauthenticationDelegate
    private let credentialProvider: CredentialReauthenticationProvider
    
    init(delegate: ReauthenticationDelegate, credentialProvider: CredentialReauthenticationProvider) {
        self.delegate = delegate
        self.credentialProvider = credentialProvider
    }
}


// MARK: - 
extension Reauthenticator {
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


// MARK: - Dependencies
protocol CredentialReauthenticationProvider {
    func loadReauthCredential(linkedProviders: [AuthProvider]) async throws -> CredentialType?
}

public protocol ReauthenticationDelegate {
    func loadLinkedProviders() -> [AuthProvider]
    func reauthenticate(with credientialType: CredentialType) async throws
}
