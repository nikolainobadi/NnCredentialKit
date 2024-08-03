//
//  AppleSignInError.swift
//  
//
//  Created by Nikolai Nobadi on 8/3/24.
//

public enum AppleSignInError: Error {
    case invalidState
    case unableToFetchIdentityToken
    case unableToSerializeToken
}


// MARK: - Heplpers
public extension AppleSignInError {
    var title: String {
        return "Apple Sign-In Error"
    }
    
    var message: String {
        switch self {
        case .invalidState:
            return "Invalid State"
        case .unableToSerializeToken:
            return "Unable to serialize token"
        case .unableToFetchIdentityToken:
            return "Unable to fetch Identity token"
        }
    }
}
