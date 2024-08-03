//
//  CredentialManager+ConvenienceInit.swift
//  
//
//  Created by Nikolai Nobadi on 8/3/24.
//

import AuthenticationServices

// MARK: - ConvenienceInit
extension CredentialManager {
    convenience init(appleSignInScopes: [ASAuthorization.Scope]) {
        let alertHandler = CredentialAlertHandler()
        let socialProvider = SocialCredentialManager(appleSignInScopes: appleSignInScopes)
        
        self.init(alertHandler: alertHandler, socialCredentialProvider: socialProvider)
    }
}
