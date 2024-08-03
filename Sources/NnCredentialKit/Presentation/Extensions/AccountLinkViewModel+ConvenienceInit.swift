//
//  AccountLinkViewModel+ConvenienceInit.swift
//
//
//  Created by Nikolai Nobadi on 8/3/24.
//

import AuthenticationServices

public extension AccountLinkViewModel {
    convenience init(delegate: AccountLinkDelegate, appleSignInScopes: [ASAuthorization.Scope]) {
        let credentialProvider = CredentialManager(appleSignInScopes: appleSignInScopes)
        let reauthenticator = ReauthenticationManager(delegate: delegate, credentialProvider: credentialProvider)
        
        self.init(delegate: delegate, reauthenticator: reauthenticator, credentialProvider: credentialProvider)
    }
}
