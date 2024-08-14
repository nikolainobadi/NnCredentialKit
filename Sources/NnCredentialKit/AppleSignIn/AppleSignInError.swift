//
//  AppleSignInError.swift
//  
//
//  Created by Nikolai Nobadi on 8/3/24.
//

import Foundation
import NnSwiftUIKit

/// An enum representing common errors that can occur during Apple Sign-In.
public enum AppleSignInError: Error {
    /// The sign-in process encountered an invalid state.
    case invalidState
    
    /// Unable to fetch the identity token during sign-in.
    case unableToFetchIdentityToken
    
    /// Unable to serialize the identity token.
    case unableToSerializeToken
}

// MARK: - DisplayableError
extension AppleSignInError: NnDisplayableError {
    public var title: String {
        return "Apple Sign-In Error"
    }

    public var message: String {
        switch self {
        case .invalidState: return "Invalid State"
        case .unableToSerializeToken: return "Unable to serialize token"
        case .unableToFetchIdentityToken: return "Unable to fetch Identity token"
        }
    }
}

