//
//  AccountDeleter.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

/// A class responsible for managing the account deletion process.
public final class AccountDeleter {
    private let delegate: DeleteAccountDelegate
    private let reauthenticator: Reauthenticator
    
    /// Initializes the deleter with the specified delegate and reauthenticator.
    /// - Parameters:
    ///   - delegate: The delegate responsible for handling the account deletion.
    ///   - reauthenticator: The reauthenticator responsible for handling reauthentication.
    internal init(delegate: DeleteAccountDelegate, reauthenticator: Reauthenticator) {
        self.delegate = delegate
        self.reauthenticator = reauthenticator
    }
}


// MARK: - Init
public extension AccountDeleter {
    /// Convenience initializer for creating an `AccountDeleter` with a default reauthenticator.
    /// - Parameter delegate: The delegate responsible for handling the account deletion.
    convenience init(delegate: DeleteAccountDelegate) {
        let credentialProvider = CredentialManager(appleSignInScopes: [])
        let reauthenticator = ReauthenticationManager(delegate: delegate, credentialProvider: credentialProvider)
        self.init(delegate: delegate, reauthenticator: reauthenticator)
    }
}


// MARK: - Delete Account
public extension AccountDeleter {
    /// Initiates the account deletion process, with reauthentication if required.
    /// - Throws: An error if the deletion or reauthentication fails.
    func deleteAccount() async throws {
        let result = await delegate.deleteAccount()
        
        switch result {
        case .success: break
        case .failure(let error): throw error
        case .reauthRequired: try await reauthenticator.start { [unowned self] in
            try await deleteAccount()
        }
        }
    }
}
