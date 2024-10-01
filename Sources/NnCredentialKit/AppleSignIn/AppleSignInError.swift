//
//  AppleSignInError.swift
//  
//
//  Created by Nikolai Nobadi on 8/3/24.
//

/// An enum representing common errors that can occur during Apple Sign-In.
public enum AppleSignInError: Error {
    /// The sign-in process encountered an invalid state.
    case invalidState
    
    /// Unable to fetch the identity token during sign-in.
    case unableToFetchIdentityToken
    
    /// Unable to serialize the identity token.
    case unableToSerializeToken
}
