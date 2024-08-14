//
//  GoogleCredentialInfo.swift
//  
//
//  Created by Nikolai Nobadi on 8/3/24.
//

/// A structure representing the credentials obtained from Google Sign-In.
public struct GoogleCredentialInfo {
    /// The user's email address.
    public let email: String?
    
    /// The ID token obtained from Google Sign-In.
    public let tokenId: String
    
    /// The user's display name.
    public let displayName: String?
    
    /// The access token ID obtained from Google Sign-In.
    public let accessTokenId: String
    
    /// Initializes the structure with the given parameters.
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - displayName: The user's display name.
    ///   - tokenId: The ID token obtained from Google Sign-In.
    ///   - accessTokenId: The access token ID obtained from Google Sign-In.
    public init(email: String?, displayName: String?, tokenId: String, accessTokenId: String) {
        self.email = email
        self.displayName = displayName
        self.tokenId = tokenId
        self.accessTokenId = accessTokenId
    }
}
