//
//  SocialCredentialManager.swift
//  
//
//  Created by Nikolai Nobadi on 8/3/24.
//

import UIKit
import NnSwiftUIKit
import AuthenticationServices

/// A manager responsible for loading social credentials (Apple, Google).
public final class SocialCredentialManager {
    private let appleSignInScopes: [ASAuthorization.Scope]
    
    /// Initializes the manager with the specified Apple sign-in scopes.
    /// - Parameter appleSignInScopes: The scopes to request during Apple Sign-In.
    public init(appleSignInScopes: [ASAuthorization.Scope]) {
        self.appleSignInScopes = appleSignInScopes
    }
}


// MARK: - SocialCredentialProvider
extension SocialCredentialManager: SocialCredentialProvider {
    /// Loads the Apple credential for authentication.
    /// - Returns: The loaded `AppleCredentialInfo` or `nil` if the operation fails.
    public func loadAppleCredential() async throws -> AppleCredentialInfo? {
        try await AppleSignInCoordinator().createAppleTokenInfo(requestedScopes: appleSignInScopes)
    }
    
    /// Loads the Google credential for authentication.
    /// - Returns: The loaded `GoogleCredentialInfo` or `nil` if the operation fails.
    public func loadGoogleCredential() async throws -> GoogleCredentialInfo? {
        let rootVC = await UIApplication.shared.getTopViewController()
        return try await GoogleSignInHandler.signIn(rootVC: rootVC)
    }
}
