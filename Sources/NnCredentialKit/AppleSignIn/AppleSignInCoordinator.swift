//
//  AppleSignInCoordinator.swift
//  
//
//  Created by Nikolai Nobadi on 8/3/24.
//

import AuthenticationServices

/// A coordinator responsible for managing the Apple Sign-In process.
@MainActor
public final class AppleSignInCoordinator: NSObject {
    private let session: AppleAuthSession
    private let nonceProvider: NonceProvider
    private let converter: AppleCredentialConverter
    
    private var currentNonce: String?
    
    init(session: AppleAuthSession, provider: NonceProvider, converter: AppleCredentialConverter) {
        self.session = session
        self.converter = converter
        self.nonceProvider = provider
    }
    
    public override init() {
        self.nonceProvider = DefaultNonceProvider()
        self.session = DefaultAppleAuthSession()
        self.converter = AppleCredentialConverter()
    }
}


// MARK: - Actions
public extension AppleSignInCoordinator {
    func createAppleTokenInfo(requestedScopes: [ASAuthorization.Scope]? = [.email, .fullName]) async throws -> AppleCredentialInfo? {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AppleCredentialInfo?, Error>) in
            let nonce = nonceProvider.make()
            currentNonce = nonce
            session.start(scopes: requestedScopes, nonce: nonceProvider.hash(nonce)) { [weak self] result in
                guard let self else {
                    return
                }
                
                switch result {
                case .success(let raw):
                    do {
                        let info = try self.converter.convert(raw: raw, nonce: self.currentNonce)
                        continuation.resume(returning: info)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    if let e = error as? ASAuthorizationError, e.code == .canceled {
                        continuation.resume(returning: nil)
                    } else if let e = error as? AppleSignInError, e == .canceled {
                        continuation.resume(returning: nil)
                    } else {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}


// MARK: - Dependencies
protocol NonceProvider: Sendable {
    func make() -> String
    func hash(_ value: String) -> String
}

@MainActor
protocol AppleAuthSession: AnyObject {
    func start(scopes: [ASAuthorization.Scope]?, nonce: String, completion: @escaping (Result<AppleAuthRawCredential, Error>) -> Void)
}
