//
//  AccountLinkViewModel+ConvenienceInit.swift
//
//
//  Created by Nikolai Nobadi on 8/3/24.
//

import AuthenticationServices

/// An extension to `AccountLinkViewModel` that provides convenience initializers.
public extension AccountLinkViewModel {
    /// Initializes the view model with a delegate and Apple sign-in scopes.
    /// - Parameters:
    ///   - delegate: The delegate responsible for handling account link actions.
    ///   - appleSignInScopes: The scopes to request during Apple Sign-In.
    convenience init(delegate: AccountLinkDelegate, appleSignInScopes: [ASAuthorization.Scope]) {
        let credentialProvider = CredentialManager(appleSignInScopes: appleSignInScopes)
        let reauthenticator = ReauthenticationManager(delegate: delegate, credentialProvider: credentialProvider)
        self.init(delegate: delegate, reauthenticator: reauthenticator, credentialProvider: credentialProvider)
    }
}
