//
//  DefaultNonceProvider.swift
//  NnCredentialKit
//
//  Created by Nikolai Nobadi on 9/28/25.
//

struct DefaultNonceProvider: NonceProvider {
    func make() -> String {
        return NonceFactory.randomNonceString()
    }
    
    func hash(_ value: String) -> String {
        return NonceFactory.sha256(value)
    }
}
