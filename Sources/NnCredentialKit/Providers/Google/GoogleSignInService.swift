//
//  GoogleSignInService.swift
//  NnCredentialKit
//
//  Created by Nikolai Nobadi on 9/29/25.
//

import UIKit

@MainActor
public final class GoogleSignInService {
    private let client: GoogleSignInClient
    private let debugEnabled: Bool

    init(client: any GoogleSignInClient, debugEnabled: Bool = false) {
        self.client = client
        self.debugEnabled = debugEnabled
    }
}

public extension GoogleSignInService {
    /// Creates a Google Sign-In service with the specified view controller.
    /// - Parameters:
    ///   - viewController: The view controller from which to present the sign-in flow.
    ///   - debugEnabled: When `true`, prints Google Sign-In details to the console. Nothing is printed when `false` (default).
    convenience init(viewController: UIViewController?, debugEnabled: Bool = false) {
        self.init(client: DefaultGoogleSignInClient(viewController: viewController), debugEnabled: debugEnabled)
    }
}

public extension GoogleSignInService {
    /// Initiates the Google Sign-In process.
    /// - Returns: A `GoogleCredentialInfo` object if sign-in is successful, or `nil` if the user cancels.
    func signIn() async throws -> GoogleCredentialInfo? {
        log("Starting Google Sign-In")
        guard let result = try await client.signIn() else {
            log("Google Sign-In canceled by user")
            return nil
        }

        return processSignInResult(result)
    }
}


// MARK: - Private Methods
private extension GoogleSignInService {
    func processSignInResult(_ result: GoogleSignInResult) -> GoogleCredentialInfo? {
        guard let idTokenString = result.idTokenString else {
            log("Google sign-in result missing ID token")
            return nil
        }

        let displayName = [result.givenName, result.familyName].compactMap { $0 }.joined(separator: " ")

        log("Google credential received")

        return .init(email: result.email, displayName: displayName, tokenId: idTokenString, accessTokenId: result.accessTokenString)
    }

    /// Prints a message to the console when debug logging is enabled.
    /// - Parameter message: The message to print.
    func log(_ message: String) {
        CredentialKitLogger.log(message, isEnabled: debugEnabled)
    }
}

// MARK: - Dependencies
@MainActor
protocol GoogleSignInClient {
    func signIn() async throws -> GoogleSignInResult?
}

struct GoogleSignInResult: Sendable, Equatable {
    let idTokenString: String?
    let accessTokenString: String
    let email: String?
    let givenName: String?
    let familyName: String?
}
