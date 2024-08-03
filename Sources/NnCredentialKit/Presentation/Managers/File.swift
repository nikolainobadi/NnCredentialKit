//
//  File.swift
//  
//
//  Created by Nikolai Nobadi on 8/3/24.
//

import Foundation

public final class SocialCredentialManager {
    private let provider: CredentialTypeProvider
    
    init(provider: CredentialTypeProvider) {
        self.provider = provider
    }
}

extension SocialCredentialManager {
    func getAppleCredential() async throws -> CredentialType? {
        return try await provider.loadCredential(.apple)
    }
    
    func getGoogleCredential() async throws -> CredentialType? {
        return try await provider.loadCredential(.google)
    }
}


// MARK: - Dependencies
public struct SocialCredentialInfo {
    public let tokenId: String
    public let secondaryTokenString: String
    public let displayName: String?
    
    public init(tokenId: String, secondaryTokenString: String, displayName: String?) {
        self.tokenId = tokenId
        self.secondaryTokenString = secondaryTokenString
        self.displayName = displayName
    }
}
