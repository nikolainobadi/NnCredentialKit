//
//  CredentialType.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

import NnGoogleSignIn

public enum CredentialType {
    case apple(AppleCredentialInfo)
    case google(GoogleTokenInfo)
    case emailPassword(email: String, password: String)
}
