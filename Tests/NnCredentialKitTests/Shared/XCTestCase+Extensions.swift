//
//  XCTestCase+Extensions.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

import XCTest
import NnCredentialKit

extension XCTestCase {
    func makeEmailPasswordCredential(email: String = "tester@gmail.com", password: String = "tester") -> CredentialType {
        return .emailPassword(email: email, password: password)
    }
    
    func makeAuthProvider(_ type: AuthProviderType, email: String = "") -> AuthProvider {
        return .init(linkedEmail: email, type: type)
    }
    
    func makeLinkedProviders(types: [AuthProviderType] = AuthProviderType.allCases) -> [AuthProvider] {
        return types.map { type in
                return .init(linkedEmail: "tester@\(type.rawValue).com", type: type)
        }
    }
}
