//
//  AccountCredentialResult.swift
//  
//
//  Created by Nikolai Nobadi on 8/2/24.
//

/// An enum representing the result of an account credential operation.
public enum AccountCredentialResult {
    /// The operation was successful.
    case success
    
    /// The operation requires reauthentication.
    case reauthRequired
    
    /// The operation failed with an error.
    case failure(Error)
}
