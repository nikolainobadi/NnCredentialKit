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
    ///   - preventUnlinkingLastProvider: When true, hides the link button if the provider is the only one linked. Defaults to false.
    ///   - debugEnabled: When `true`, prints account link details to the console. Nothing is printed when `false` (default).
    convenience init(delegate: AccountLinkDelegate, appleSignInScopes: [ASAuthorization.Scope], preventUnlinkingLastProvider: Bool = false, debugEnabled: Bool = false) {
        let credentialProvider = CredentialManager(appleSignInScopes: appleSignInScopes, debugEnabled: debugEnabled)
        let reauthenticator = ReauthenticationManager(delegate: delegate, credentialProvider: credentialProvider, debugEnabled: debugEnabled)
        self.init(delegate: delegate, reauthenticator: reauthenticator, credentialProvider: credentialProvider, preventUnlinkingLastProvider: preventUnlinkingLastProvider, debugEnabled: debugEnabled)
    }
}
