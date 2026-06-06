//
//  ReauthenticationManager.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

import Foundation

/// A manager responsible for handling reauthentication flows.
@MainActor
final class ReauthenticationManager {
    private let debugEnabled: Bool
    private let delegate: ReauthenticationDelegate
    private let credentialProvider: CredentialReauthenticationProvider

    /// Initializes the manager with the specified delegate and credential provider.
    /// - Parameters:
    ///   - delegate: The delegate responsible for handling reauthentication actions.
    ///   - credentialProvider: The provider responsible for loading reauthentication credentials.
    ///   - debugEnabled: When `true`, prints reauthentication details to the console. Nothing is printed when `false` (default).
    init(delegate: ReauthenticationDelegate, credentialProvider: CredentialReauthenticationProvider, debugEnabled: Bool = false) {
        self.delegate = delegate
        self.debugEnabled = debugEnabled
        self.credentialProvider = credentialProvider
    }
}


// MARK: - Reauthenticator
extension ReauthenticationManager: Reauthenticator {
    /// Starts the reauthentication process and performs an action upon successful reauthentication.
    /// - Parameter actionAfterReauth: The action to perform after reauthentication.
    /// - Throws: An error if reauthentication or the subsequent action fails.
    func start(actionAfterReauth: @escaping () async throws -> Void) async throws {
        let linkedProviders = delegate.loadLinkedProviders().filter({ $0.isLinked })

        log("Starting reauthentication with \(linkedProviders.count) linked provider(s)")

        if linkedProviders.isEmpty {
            log("No linked providers available, reauthentication aborted")
            throw CredentialError.emptyAuthProviders
        }

        guard let selectedCredentialType = try await credentialProvider.loadReauthCredential(linkedProviders: linkedProviders) else {
            log("Reauthentication canceled")
            throw CredentialError.cancelled
        }

        try await delegate.reauthenticate(with: selectedCredentialType)
        log("Reauthentication successful, performing follow-up action")
        try await actionAfterReauth()
    }
}


// MARK: - Private Methods
private extension ReauthenticationManager {
    /// Prints a message to the console when debug logging is enabled.
    /// - Parameter message: The message to print.
    func log(_ message: String) {
        CredentialKitLogger.log(message, isEnabled: debugEnabled)
    }
}
