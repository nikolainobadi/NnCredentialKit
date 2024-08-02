//
//  Reauthenticator.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

final class Reauthenticator {
    private let delegate: ReauthenticationDelegate
    
    init(delegate: ReauthenticationDelegate) {
        self.delegate = delegate
    }
}


// MARK: - 
extension Reauthenticator {
    func start(actionAfterReauth: @escaping () async throws -> Void) async throws {
        let linkedProviders = delegate.loadLinkedProviders()
        guard let selectedCredentialType = try await getCredentialInfo(from: linkedProviders) else {
            throw CredentialError.cancelled
        }
        
        try await delegate.reauthenticate(with: selectedCredentialType)
        try await actionAfterReauth()
    }
    
    func getCredentialInfo(from providers: [AuthProvider]) async throws -> CredentialType? {
        guard let selectedProvider = await selectProvider(from: providers) else {
            return nil
        }
        
        switch selectedProvider.type {
        case .apple:
            // TODO: -
            return nil
        case .google:
            // TODO: -
            return nil
        case .emailPassword:
            // TODO: - show password alert
            return nil
        }
    }
    
    func selectProvider(from providers: [AuthProvider]) async -> AuthProvider? {
        guard providers.count > 1 else {
            return providers.first
        }
        
        // TODO: -
        return nil
    }
}


// MARK: - Dependencies
public protocol ReauthenticationDelegate {
    func loadLinkedProviders() -> [AuthProvider]
    func reauthenticate(with credientialType: CredentialType) async throws
}
