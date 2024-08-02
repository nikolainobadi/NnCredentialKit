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
            try await reauthenticator.start()
            try await deleteAccount()
        }
    }
}


// MARK: - Dependencies
protocol DeleteAccountDelegate: ReauthenticationDelegate {
    func deleteAccount() async -> AccountCredentialResult
}

enum AccountCredentialResult {
    case success, reauthRequired, failure(Error)
}

public struct AuthProvider: Hashable {
    public let linkedEmail: String
    public let type: AuthProviderType
    
    public init(linkedEmail: String, type: AuthProviderType) {
        self.linkedEmail = linkedEmail
        self.type = type
    }
}

extension AuthProvider {
    var isLinked: Bool {
        return !linkedEmail.isEmpty
    }
}

public enum AuthProviderType {
    case apple, google, emailPassword
}

extension AuthProvider: Identifiable {
    public var id: String {
        return name
    }
    
    var name: String {
        switch type {
        case .apple:
            return "Apple ID"
        case .google:
            return "Google Account"
        case .emailPassword:
            return "Email Address"
        }
    }
}

public enum CredentialType {
    case apple(tokenId: String, nonce: String)
    case google(tokenId: String, accessToken: String)
    case emailPassword(email: String, password: String)
}
