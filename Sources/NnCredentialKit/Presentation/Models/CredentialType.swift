//
//  CredentialType.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

public enum CredentialType {
    case apple(tokenId: String, nonce: String)
    case google(tokenId: String, accessToken: String)
    case emailPassword(email: String, password: String)
}
