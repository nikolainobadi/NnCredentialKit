//
//  AccountCredentialResult.swift
//  
//
//  Created by Nikolai Nobadi on 8/2/24.
//

public enum AccountCredentialResult {
    case success, reauthRequired, failure(Error)
}
