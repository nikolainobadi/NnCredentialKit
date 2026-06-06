//
//  CredentialManager.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

import Foundation

/// A class responsible for managing credentials for various authentication providers.
@MainActor
final class CredentialManager {
    private let debugEnabled: Bool
    private let alertHandler: CredentialAlerts
    private let socialCredentialProvider: SocialCredentialProvider

    /// Initializes the manager with the specified alert handler and social credential provider.
    /// - Parameters:
    ///   - alertHandler: The handler responsible for displaying alerts.
    ///   - socialCredentialProvider: The provider responsible for loading social credentials.
    ///   - debugEnabled: When `true`, prints credential workflow details to the console. Nothing is printed when `false` (default).
    init(alertHandler: CredentialAlerts, socialCredentialProvider: SocialCredentialProvider, debugEnabled: Bool = false) {
        self.alertHandler = alertHandler
        self.debugEnabled = debugEnabled
        self.socialCredentialProvider = socialCredentialProvider
    }
}


// MARK: - CredentialTypeProvider
extension CredentialManager: CredentialTypeProvider {
    /// Loads the credential for a specific authentication provider type.
    /// - Parameter type: The type of the authentication provider.
    /// - Returns: The loaded `CredentialType` or `nil` if the operation fails.
    func loadCredential(_ type: AuthProviderType) async throws -> CredentialType? {
        log("Loading credential for \(type) provider")
        switch type {
        case .apple: return try await .init(appleCredential: loadAppleCredential())
        case .google: return try await .init(googleCredential: loadGoogleCredential())
        case .emailPassword: return try await loadNewEmailSignUpCredential()
        }
    }
}


// MARK: - CredentialReauthenticationProvider
extension CredentialManager: CredentialReauthenticationProvider {
    /// Loads the credential for reauthentication with linked providers.
    /// - Parameter linkedProviders: The list of linked authentication providers.
    /// - Returns: The loaded `CredentialType` or `nil` if the operation fails.
    func loadReauthCredential(linkedProviders: [AuthProvider]) async throws -> CredentialType? {
        log("Loading reauthentication credential (\(linkedProviders.count) linked provider(s))")
        guard let selectedProvider = try await selectProvider(from: linkedProviders) else {
            log("Provider selection canceled")
            return nil
        }

        log("Selected \(selectedProvider.type) provider for reauthentication")
        switch selectedProvider.type {
        case .apple: return try await .init(appleCredential: loadAppleCredential())
        case .google: return try await .init(googleCredential: loadGoogleCredential())
        case .emailPassword: return await loadEmailReauthenticationCredential(selectedProvider.linkedEmail)
        }
    }
}


// MARK: - Private Methods
private extension CredentialManager {
    /// Loads the Apple credential for authentication.
    /// - Returns: The loaded `AppleCredentialInfo` or `nil` if the operation fails.
    func loadAppleCredential() async throws -> AppleCredentialInfo? {
        try await socialCredentialProvider.loadAppleCredential()
    }
    
    /// Loads the Google credential for authentication.
    /// - Returns: The loaded `GoogleCredentialInfo` or `nil` if the operation fails.
    func loadGoogleCredential() async throws -> GoogleCredentialInfo? {
        try await socialCredentialProvider.loadGoogleCredential()
    }
    
    /// Prompts the user to select a provider from a list of linked providers.
    /// - Parameter linkedProviders: The list of linked providers.
    /// - Returns: The selected `AuthProvider` or `nil` if the operation fails.
    func selectProvider(from linkedProviders: [AuthProvider]) async throws -> AuthProvider? {
        if linkedProviders.isEmpty {
            log("No linked providers available for reauthentication")
            throw CredentialError.emptyAuthProviders
        }
        return try await withCheckedThrowingContinuation { continuation in
            alertHandler.showReauthenticationAlert(providers: linkedProviders) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    /// Loads the credential for reauthenticating an email/password account.
    /// - Parameter email: The email address associated with the account.
    /// - Returns: The loaded `CredentialType` or `nil` if the operation fails.
    func loadEmailReauthenticationCredential(_ email: String) async -> CredentialType? {
        guard let password = await alertHandler.loadPassword("Please enter the password for the email: \(email)") else {
            log("Password entry canceled")
            return nil
        }
        return .emailPassword(email: email, password: password)
    }

    /// Loads the credential for signing up with an email and password.
    /// - Returns: The loaded `CredentialType` or `nil` if the operation fails.
    func loadNewEmailSignUpCredential() async throws -> CredentialType? {
        guard let info = await alertHandler.loadEmailSignUpInfo() else {
            log("Email sign-up canceled")
            return nil
        }
        guard info.passwordsMatch else {
            log("Email sign-up passwords do not match")
            throw CredentialError.passwordsMustMatch
        }
        return .emailPassword(email: info.email, password: info.password)
    }

    /// Prints a message to the console when debug logging is enabled.
    /// - Parameter message: The message to print.
    func log(_ message: String) {
        CredentialKitLogger.log(message, isEnabled: debugEnabled)
    }
}


// MARK: - Dependencies
@MainActor
protocol CredentialAlerts {
    func loadEmailSignUpInfo() async -> EmailSignUpInfo?
    func loadPassword(_ message: String) async -> String?
    func showReauthenticationAlert(providers: [AuthProvider], completion: @escaping (AuthProvider?) -> Void)
}

@MainActor
protocol SocialCredentialProvider {
    func loadAppleCredential() async throws -> AppleCredentialInfo?
    func loadGoogleCredential() async throws -> GoogleCredentialInfo?
}
