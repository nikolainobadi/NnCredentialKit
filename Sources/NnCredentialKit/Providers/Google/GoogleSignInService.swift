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
    
    init(client: any GoogleSignInClient) {
        self.client = client
    }
}

public extension GoogleSignInService {
    /// Creates a Google Sign-In service with the specified view controller.
    /// - Parameter viewController: The view controller from which to present the sign-in flow.
    convenience init(viewController: UIViewController?) {
        self.init(client: DefaultGoogleSignInClient(viewController: viewController))
    }
}

public extension GoogleSignInService {
    /// Initiates the Google Sign-In process.
    /// - Returns: A `GoogleCredentialInfo` object if sign-in is successful, or `nil` if the user cancels.
    func signIn() async throws -> GoogleCredentialInfo? {
        guard let result = try await client.signIn() else {
            return nil
        }

        return processSignInResult(result)
    }
}


// MARK: - Private Methods
private extension GoogleSignInService {
    func processSignInResult(_ result: GoogleSignInResult) -> GoogleCredentialInfo? {
        guard let idTokenString = result.idTokenString else {
            return nil
        }

        let displayName = [result.givenName, result.familyName].compactMap { $0 }.joined(separator: " ")

        return .init(email: result.email, displayName: displayName, tokenId: idTokenString, accessTokenId: result.accessTokenString)
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
