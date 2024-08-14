//
//  AuthProvider.swift
//  
//
//  Created by Nikolai Nobadi on 8/2/24.
//

import Foundation

/// A structure representing an authentication provider and its associated credentials.
public struct AuthProvider: Hashable {
    /// The email address linked to this provider.
    public let linkedEmail: String
    
    /// The type of the authentication provider.
    public let type: AuthProviderType
    
    /// Initializes the structure with the given email and provider type.
    /// - Parameters:
    ///   - linkedEmail: The email address linked to this provider.
    ///   - type: The type of the authentication provider.
    public init(linkedEmail: String, type: AuthProviderType) {
        self.linkedEmail = linkedEmail
        self.type = type
    }
}


// MARK: - Helpers
extension AuthProvider {
    /// A Boolean value indicating whether this provider is linked (i.e., has an associated email).
    var isLinked: Bool {
        return !linkedEmail.isEmpty
    }
    
    /// The name of the provider, based on its type.
    var name: String {
        switch type {
        case .apple: return "Apple ID"
        case .google: return "Google Account"
        case .emailPassword: return "Email Address"
        }
    }
}


// MARK: - Dependencies
/// An enum representing the types of authentication providers supported by the system.
public enum AuthProviderType: String, CaseIterable {
    case apple, google, emailPassword
}
