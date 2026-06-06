//
//  AppleSignInService.swift
//
//
//  Created by Nikolai Nobadi on 8/3/24.
//

import AuthenticationServices

/// A service responsible for managing the Apple Sign-In process.
@MainActor
public final class AppleSignInService: NSObject {
    private let debugEnabled: Bool
    private let session: AppleAuthSession
    private let nonceProvider: NonceProvider
    private let converter: AppleCredentialConverter

    private var currentNonce: String?

    init(session: AppleAuthSession, provider: NonceProvider, converter: AppleCredentialConverter, debugEnabled: Bool = false) {
        self.session = session
        self.converter = converter
        self.nonceProvider = provider
        self.debugEnabled = debugEnabled
    }

    public override init() {
        self.debugEnabled = false
        self.nonceProvider = DefaultNonceProvider()
        self.session = DefaultAppleAuthSession()
        self.converter = AppleCredentialConverter()
    }

    /// Initializes the service with default dependencies.
    /// - Parameter debugEnabled: When `true`, prints Apple Sign-In details to the console. Nothing is printed when `false`.
    public convenience init(debugEnabled: Bool) {
        self.init(session: DefaultAppleAuthSession(), provider: DefaultNonceProvider(), converter: AppleCredentialConverter(), debugEnabled: debugEnabled)
    }
}


// MARK: - Actions
public extension AppleSignInService {
    func createAppleTokenInfo(requestedScopes: [ASAuthorization.Scope]? = [.email, .fullName]) async throws -> AppleCredentialInfo? {
        log("Starting Apple Sign-In session")
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
                        self.log("Apple credential received")
                        continuation.resume(returning: info)
                    } catch {
                        self.log("Failed to convert Apple credential: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    if let e = error as? ASAuthorizationError, e.code == .canceled {
                        self.log("Apple Sign-In canceled by user")
                        continuation.resume(returning: nil)
                    } else if let e = error as? AppleSignInError, e == .canceled {
                        self.log("Apple Sign-In canceled by user")
                        continuation.resume(returning: nil)
                    } else {
                        self.log("Apple Sign-In failed: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}


// MARK: - Private Methods
private extension AppleSignInService {
    /// Prints a message to the console when debug logging is enabled.
    /// - Parameter message: The message to print.
    func log(_ message: String) {
        CredentialKitLogger.log(message, isEnabled: debugEnabled)
    }
}


// MARK: - Deprecated
/// - Warning: This type is deprecated. Use `AppleSignInService` instead.
@available(*, deprecated, renamed: "AppleSignInService", message: "Use AppleSignInService instead")
public typealias AppleSignInCoordinator = AppleSignInService


// MARK: - Dependencies
protocol NonceProvider: Sendable {
    func make() -> String
    func hash(_ value: String) -> String
}

@MainActor
protocol AppleAuthSession: AnyObject {
    func start(scopes: [ASAuthorization.Scope]?, nonce: String, completion: @escaping (Result<AppleAuthRawCredential, Error>) -> Void)
}
