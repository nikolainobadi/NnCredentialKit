//
//  AccountDeleter.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

import SwiftUI

final class AccountDeleter {
    private let delegate: DeleteAccountDelegate
    private let reauthenticator: Reauthenticator
    
    init(delegate: DeleteAccountDelegate) {
        self.delegate = delegate
        self.reauthenticator = .init(delegate: delegate)
    }
}


// MARK: - DeleteAccount
extension AccountDeleter {
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


// MARK: - Dependencies
public protocol DeleteAccountDelegate: ReauthenticationDelegate {
    func deleteAccount() async -> AccountCredentialResult
}
