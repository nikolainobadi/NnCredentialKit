//
//  CredentialTypeProviderAdapter.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

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
        guard let selectedProvider = try await selectProvider(from: linkedProviders) else {
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
    func selectProvider(from linkedProviders: [AuthProvider]) async throws -> AuthProvider? {
        return try await withCheckedThrowingContinuation { continuation in
            alertHandler.showReauthenticationAlert(providers: linkedProviders) { result in
                switch result {
                case .success(let provider):
                    continuation.resume(returning: provider)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func loadAppleCredential() async throws -> CredentialType? {
        guard let info = try await AppleSignInCoordinator().createAppleTokenInfo(requestedScopes: [.email]) else {
            return nil
        }
        
        return .apple(info)
    }
    
    func loadGoogleCredential() async throws -> CredentialType? {
        let rootVC = await alertHandler.getTopVC()
        
        guard let info = try await GoogleSignInHandler.signIn(rootVC: rootVC) else {
            return nil
        }
        
        return .google(info)
    }
    
    func loadEmailReauthenticationCredential(_ email: String) async -> CredentialType? {
        guard let password = await alertHandler.loadPassword("Please enter the password for the email: \(email)") else {
            return nil
        }
        
        return .emailPassword(email: email, password: password)
    }
    
    func loadNewEmailSignUpCredential() async throws -> CredentialType? {
        guard let info = await alertHandler.loadEmailSignUpInfo() else {
            return nil
        }
        
        guard info.passwordsMatch else {
            throw CredentialError.passwordsMustMatch
        }
        
        return .emailPassword(email: info.email, password: info.password)
    }
}
