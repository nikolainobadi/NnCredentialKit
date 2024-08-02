//
//  AuthProvider.swift
//  
//
//  Created by Nikolai Nobadi on 8/2/24.
//

import Foundation

public struct AuthProvider: Hashable {
    public let linkedEmail: String
    public let type: AuthProviderType
    
    public init(linkedEmail: String, type: AuthProviderType) {
        self.linkedEmail = linkedEmail
        self.type = type
    }
}


// MARK: - Helpers
extension AuthProvider {
    var isLinked: Bool {
        return !linkedEmail.isEmpty
    }
    
    var name: String {
        switch type {
        case .apple:
            return "Apple ID"
        case .google:
            return "Google Account"
        case .emailPassword:
            return "Email Address"
        }
    }
}

// MARK: - Dependencies
public enum AuthProviderType: String, CaseIterable {
    case apple, google, emailPassword
    
}
