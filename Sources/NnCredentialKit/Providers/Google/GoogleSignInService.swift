//
//  GoogleSignInService.swift
//  NnCredentialKit
//
//  Created by Nikolai Nobadi on 9/29/25.
//

@MainActor
final class GoogleSignInService {
    private let client: GoogleSignInClient

    init(client: any GoogleSignInClient) {
        self.client = client
    }
}

extension GoogleSignInService {
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
