//
//  SocialCredentialManager.swift
//  
//
//  Created by Nikolai Nobadi on 8/3/24.
//

import UIKit
import NnSwiftUIKit
import AuthenticationServices

public final class SocialCredentialManager {
    private let appleSignInScopes: [ASAuthorization.Scope]
    
    public init(appleSignInScopes: [ASAuthorization.Scope]) {
        self.appleSignInScopes = appleSignInScopes
    }
}


// MARK: - SocialCredentialProvider
extension SocialCredentialManager: SocialCredentialProvider {
    public func loadAppleCredential() async throws -> AppleCredentialInfo? {
        try await AppleSignInCoordinator().createAppleTokenInfo(requestedScopes: appleSignInScopes)
    }
    
    public func loadGoogleCredential() async throws -> GoogleCredentialInfo? {
        let rootVC = await UIApplication.shared.getTopViewController()
        
        return try await GoogleSignInHandler.signIn(rootVC: rootVC)
    }
}
