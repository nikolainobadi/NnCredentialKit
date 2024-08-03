//
//  GoogleCredentialInfo.swift
//  
//
//  Created by Nikolai Nobadi on 8/3/24.
//

public struct GoogleCredentialInfo {
    public let email: String?
    public let tokenId: String
    public let displayName: String?
    public let accessTokenId: String
    
    public init(email: String?, displayName: String?, tokenId: String, accessTokenId: String) {
        self.email = email
        self.displayName = displayName
        self.tokenId = tokenId
        self.accessTokenId = accessTokenId
    }
}
