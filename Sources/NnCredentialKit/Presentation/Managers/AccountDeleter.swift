//
//  AccountDeleter.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

import SwiftUI

public final class AccountDeleter {
    private let delegate: DeleteAccountDelegate
    private let reauthenticator: Reauthenticator
    
    internal init(delegate: DeleteAccountDelegate, reauthenticator: Reauthenticator) {
        self.delegate = delegate
        self.reauthenticator = reauthenticator
    }
}


// MARK: - Init
public extension AccountDeleter {
    convenience init(delegate: DeleteAccountDelegate) {
        let socialProvider = SocialCredentialManager(appleSignInScopes: [])
        let credentialProvider = CredentialManager(socialCredentialProvider: socialProvider)
        let reauthenticator = ReauthenticationManager(delegate: delegate, credentialProvider: credentialProvider)
        
        self.init(delegate: delegate, reauthenticator:  reauthenticator)
    }
}


// MARK: - DeleteAccount
public extension AccountDeleter {
    func deleteAccount() async throws -> Void {
        let result = await delegate.deleteAccount()
        
        switch result {
        case .success:
            break
        case .failure(let error):
            throw error
        case .reauthRequired:
            try await reauthenticator.start { [unowned self] in
                try await deleteAccount()
            }
        }
    }
}
