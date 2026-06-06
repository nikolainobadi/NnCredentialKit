//
//  AccountDeleter.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

/// A class responsible for managing the account deletion process.
@MainActor
public final class AccountDeleter {
    private let debugEnabled: Bool
    private let delegate: DeleteAccountDelegate
    private let reauthenticator: Reauthenticator

    /// Initializes the deleter with the specified delegate and reauthenticator.
    /// - Parameters:
    ///   - delegate: The delegate responsible for handling the account deletion.
    ///   - reauthenticator: The reauthenticator responsible for handling reauthentication.
    ///   - debugEnabled: When `true`, prints account deletion details to the console. Nothing is printed when `false` (default).
    internal init(delegate: DeleteAccountDelegate, reauthenticator: Reauthenticator, debugEnabled: Bool = false) {
        self.delegate = delegate
        self.debugEnabled = debugEnabled
        self.reauthenticator = reauthenticator
    }
}


// MARK: - Init
public extension AccountDeleter {
    /// Convenience initializer for creating an `AccountDeleter` with a default reauthenticator.
    /// - Parameters:
    ///   - delegate: The delegate responsible for handling the account deletion.
    ///   - debugEnabled: When `true`, prints account deletion details to the console. Nothing is printed when `false` (default).
    convenience init(delegate: DeleteAccountDelegate, debugEnabled: Bool = false) {
        let credentialProvider = CredentialManager(appleSignInScopes: [], debugEnabled: debugEnabled)
        let reauthenticator = ReauthenticationManager(delegate: delegate, credentialProvider: credentialProvider, debugEnabled: debugEnabled)
        self.init(delegate: delegate, reauthenticator: reauthenticator, debugEnabled: debugEnabled)
    }
}


// MARK: - Delete Account
public extension AccountDeleter {
    /// Initiates the account deletion process, with reauthentication if required.
    /// - Throws: An error if the deletion or reauthentication fails.
    func deleteAccount() async throws {
        log("Starting account deletion")
        let result = await delegate.deleteAccount()

        switch result {
        case .success:
            log("Account deletion succeeded")
        case .failure(let error):
            log("Account deletion failed: \(error.localizedDescription)")
            throw error
        case .reauthRequired:
            log("Reauthentication required before account deletion")
            try await reauthenticator.start { [unowned self] in
                try await deleteAccount()
            }
        }
    }
}


// MARK: - Private Methods
private extension AccountDeleter {
    /// Prints a message to the console when debug logging is enabled.
    /// - Parameter message: The message to print.
    func log(_ message: String) {
        CredentialKitLogger.log(message, isEnabled: debugEnabled)
    }
}
