//
//  CredentialManager.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

final class CredentialManager {
    private let alertHandler: CredentialAlerts
    private let socialCredentialProvider: SocialCredentialProvider
    
    init(alertHandler: CredentialAlerts, socialCredentialProvider: SocialCredentialProvider) {
        self.alertHandler = alertHandler
        self.socialCredentialProvider = socialCredentialProvider
    }
}


// MARK: - CredentialTypeProvider
extension CredentialManager: CredentialTypeProvider {
    func loadCredential(_ type: AuthProviderType) async throws -> CredentialType? {
        switch type {
        case .apple:
            return try await .init(appleCredential: loadAppleCredential())
        case .google:
            return try await .init(googleCredential: loadGoogleCredential())
        case .emailPassword:
            return try await loadNewEmailSignUpCredential()
        }
    }
}


// MARK: - CredentialReauthenticationProvider
extension CredentialManager: CredentialReauthenticationProvider {
    func loadReauthCredential(linkedProviders: [AuthProvider]) async throws -> CredentialType? {
        guard let selectedProvider = try await selectProvider(from: linkedProviders) else {
            return nil
        }
        
        switch selectedProvider.type {
        case .apple:
            return try await .init(appleCredential: loadAppleCredential())
        case .google:
            return try await .init(googleCredential: loadGoogleCredential())
        case .emailPassword:
            return await loadEmailReauthenticationCredential(selectedProvider.linkedEmail)
        }
    }
}


// MARK: - Private Methods
private extension CredentialManager {
    func loadAppleCredential() async throws -> AppleCredentialInfo? {
        try await socialCredentialProvider.loadAppleCredential()
    }
    
    func loadGoogleCredential() async throws -> GoogleCredentialInfo? {
        try await socialCredentialProvider.loadGoogleCredential()
    }
    
    func selectProvider(from linkedProviders: [AuthProvider]) async throws -> AuthProvider? {
        if linkedProviders.isEmpty {
            throw CredentialError.emptyAuthProviders
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            alertHandler.showReauthenticationAlert(providers: linkedProviders) { result in
                continuation.resume(returning: result)
            }
        }
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


// MARK: - Dependencies
protocol CredentialAlerts {
    func loadEmailSignUpInfo() async -> EmailSignUpInfo?
    func loadPassword(_ message: String) async -> String?
    func showReauthenticationAlert(providers: [AuthProvider], completion: @escaping (AuthProvider?) -> Void)
}

protocol SocialCredentialProvider {
    func loadAppleCredential() async throws -> AppleCredentialInfo?
    func loadGoogleCredential() async throws -> GoogleCredentialInfo?
}
