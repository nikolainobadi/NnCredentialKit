//
//  AppleCredentialInfo.swift
//
//
//  Created by Nikolai Nobadi on 8/3/24.
//

/// A structure representing the credentials obtained from Apple Sign-In.
public struct AppleCredentialInfo {
    /// A nonce used to verify the identity token.
    public let nonce: String
    
    /// The user's email address, if available.
    public let email: String?
    
    /// The user's display name, if available.
    public let displayName: String?
    
    /// The ID token string obtained from Apple Sign-In.
    public let idTokenString: String
    
    /// Initializes the structure with the given parameters.
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - displayName: The user's display name.
    ///   - idTokenString: The ID token string obtained from Apple Sign-In.
    ///   - nonce: A nonce used to verify the identity token.
    public init(email: String?, displayName: String?, idTokenString: String, nonce: String) {
        self.nonce = nonce
        self.email = email
        self.displayName = displayName
        self.idTokenString = idTokenString
    }
}
