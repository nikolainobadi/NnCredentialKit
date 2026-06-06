//
//  SocialCredentialManager.swift
//  
//
//  Created by Nikolai Nobadi on 8/3/24.
//

import UIKit
import AuthenticationServices

/// A manager responsible for loading social credentials (Apple, Google).
@MainActor
public final class SocialCredentialManager {
    private let debugEnabled: Bool
    private let appleSignInScopes: [ASAuthorization.Scope]

    /// Initializes the manager with the specified Apple sign-in scopes.
    /// - Parameters:
    ///   - appleSignInScopes: The scopes to request during Apple Sign-In.
    ///   - debugEnabled: When `true`, prints social credential details to the console. Nothing is printed when `false` (default).
    public init(appleSignInScopes: [ASAuthorization.Scope], debugEnabled: Bool = false) {
        self.debugEnabled = debugEnabled
        self.appleSignInScopes = appleSignInScopes
    }
}


// MARK: - SocialCredentialProvider
extension SocialCredentialManager: SocialCredentialProvider {
    /// Loads the Apple credential for authentication.
    /// - Returns: The loaded `AppleCredentialInfo` or `nil` if the operation fails.
    public func loadAppleCredential() async throws -> AppleCredentialInfo? {
        return try await AppleSignInService(debugEnabled: debugEnabled).createAppleTokenInfo(requestedScopes: appleSignInScopes)
    }

    /// Loads the Google credential for authentication.
    /// - Returns: The loaded `GoogleCredentialInfo` or `nil` if the operation fails.
    public func loadGoogleCredential() async throws -> GoogleCredentialInfo? {
        let viewController = UIApplication.shared.getTopViewController()
        let client = DefaultGoogleSignInClient(viewController: viewController)
        return try await GoogleSignInService(client: client, debugEnabled: debugEnabled).signIn()
    }
}
