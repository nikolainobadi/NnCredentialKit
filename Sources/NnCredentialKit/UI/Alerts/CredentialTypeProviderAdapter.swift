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
            return try await loadNewEmailSignUpCredential()
        }
    }
}


// MARK: - CredentialReauthenticationProvider
extension CredentialTypeProviderAdapter: CredentialReauthenticationProvider {
    func loadReauthCredential(linkedProviders: [AuthProvider]) async throws -> CredentialType? {
        if linkedProviders.isEmpty {
            fatalError()
        }
        
        guard let selectedProvider = selectProvider(from: linkedProviders) else {
            return nil
        }
        
        switch selectedProvider.type {
        case .apple:
            return try await loadAppleCredential()
        case .google:
            return try await loadGoogleCredential()
        case .emailPassword:
            return await loadEmailReauthenticationCredential(selectedProvider.linkedEmail)
        }
    }
}


// MARK: - Private Methods
private extension CredentialTypeProviderAdapter {
    func selectProvider(from linkedProviders: [AuthProvider]) -> AuthProvider? {
        // TODO: - 
        return nil
    }
    
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
    
    func loadEmailReauthenticationCredential(_ email: String) async -> CredentialType? {
        return nil
    }
    
    func loadNewEmailSignUpCredential() async throws -> CredentialType? {
        guard let info = await alertHandler.loadEmailSignUpInfo() else { return nil }
        guard info.passwordsMatch else {
            throw CredentialError.passwordsMustMatch
        }
        
        return .emailPassword(email: info.email, password: info.password)
    }
}
