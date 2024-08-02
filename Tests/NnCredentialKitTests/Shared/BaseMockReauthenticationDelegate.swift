//
//  BaseMockReauthenticationDelegate.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

import Foundation
import NnCredentialKit

class BaseMockReauthenticationDelegate {
    private let throwError: Bool
    private let linkedProviders: [AuthProvider]
    private(set) var credentialType: CredentialType?
    
    init(throwError: Bool, linkedProviders: [AuthProvider]) {
        self.throwError = throwError
        self.linkedProviders = linkedProviders
    }
}


// MARK: - Delegate
extension BaseMockReauthenticationDelegate: ReauthenticationDelegate {
    func loadLinkedProviders() -> [AuthProvider] {
        return linkedProviders
    }
    
    func reauthenticate(with credientialType: CredentialType) async throws {
        if throwError { throw NSError(domain: "Test", code: 0) }
        
        self.credentialType = credientialType
    }
}
