//
//  AppleCredentialInfo.swift
//
//
//  Created by Nikolai Nobadi on 8/3/24.
//

public struct AppleCredentialInfo {
    public let nonce: String
    public let email: String?
    public let displayName: String?
    public let idTokenString: String
    
    public init(email: String?, displayName: String?, idTokenString: String, nonce: String) {
        self.nonce = nonce
        self.email = email
        self.displayName = displayName
        self.idTokenString = idTokenString
    }
}
