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
    /// - Parameter appleSignInScopes: The scopes to request during Apple Sign-In.
    convenience init(appleSignInScopes: [ASAuthorization.Scope]) {
        let alertHandler = CredentialAlertHandler()
        let socialProvider = SocialCredentialManager(appleSignInScopes: appleSignInScopes)
        self.init(alertHandler: alertHandler, socialCredentialProvider: socialProvider)
    }
}
