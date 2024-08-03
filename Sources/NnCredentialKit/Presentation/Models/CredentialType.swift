//
//  CredentialType.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

public enum CredentialType {
    case apple(AppleCredentialInfo)
    case google(GoogleCredentialInfo)
    case emailPassword(email: String, password: String)
}
