//
//  CredentialManager+ConvenienceInit.swift
//  
//
//  Created by Nikolai Nobadi on 8/3/24.
//

import AuthenticationServices

/// An extension to `CredentialManager` that provides convenience initializers.
extension CredentialManager {
    /// Initializes the manager with default dependencies for handling Apple Sign-In.
    /// - Parameters:
    ///   - appleSignInScopes: The scopes to request during Apple Sign-In.
    ///   - debugEnabled: When `true`, prints credential workflow details to the console. Nothing is printed when `false` (default).
    convenience init(appleSignInScopes: [ASAuthorization.Scope], debugEnabled: Bool = false) {
        let alertHandler = CredentialAlertHandler()
        let socialProvider = SocialCredentialManager(appleSignInScopes: appleSignInScopes, debugEnabled: debugEnabled)
        self.init(alertHandler: alertHandler, socialCredentialProvider: socialProvider, debugEnabled: debugEnabled)
    }
}
