//
//  CredentialTypeProviderAdapter.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

import NnAppleSignIn
import NnGoogleSignIn

final class CredentialTypeProviderAdapter {
    private let alertHandler = CredentialAlertHandler()
}


// MARK: - CredentialTypeProvider
extension CredentialTypeProviderAdapter: CredentialTypeProvider {
    func loadCredential(_ type: AuthProviderType) async throws -> CredentialType? {
        switch type {
        case .apple:
            return try await loadAppleCredential()
        case .google:
            return try await loadGoogleCredential()
            
        case .emailPassword:
            return .emailPassword(email: "", password: "")
        }
    }
}


// MARK: - CredentialReauthenticationProvider
extension CredentialTypeProviderAdapter: CredentialReauthenticationProvider {
    func loadReauthCredential(linkedProviders: [AuthProvider]) async throws -> CredentialType? {
        return nil
    }
}


// MARK: - Private Methods
private extension CredentialTypeProviderAdapter {
    func loadAppleCredential() async throws -> CredentialType? {
        guard let info = try await AppleSignInCoordinator().createAppleTokenInfo(requestedScopes: [.email]) else { return nil }
        
        // TODO: - may need to change to include displayName
        return .apple(tokenId: info.idTokenString, nonce: info.nonce)
    }
    
    func loadGoogleCredential() async throws -> CredentialType? {
        let rootVC = await alertHandler.getTopVC()
        
        guard let info = try await GoogleSignInHandler.signIn(rootVC: rootVC) else { return nil }
        
        // TODO: - may need to change to include displayName
        return .google(tokenId: info.tokenId, accessToken: info.accessTokenId)
    }
}
