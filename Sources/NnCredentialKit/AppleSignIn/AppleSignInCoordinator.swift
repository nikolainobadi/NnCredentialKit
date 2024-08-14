//
//  AppleSignInCoordinator.swift
//  
//
//  Created by Nikolai Nobadi on 8/3/24.
//

import AuthenticationServices

/// A coordinator responsible for managing the Apple Sign-In process.
public final class AppleSignInCoordinator: NSObject {
    private var currentNonce: String?
    private var completion: ((Result<AppleCredentialInfo?, Error>) -> Void)?
    
    /// Initializes the coordinator.
    public override init() {}
}


// MARK: - PresentationProviding
extension AppleSignInCoordinator: ASAuthorizationControllerPresentationContextProviding {
    /// Provides the presentation anchor for the authorization controller.
    /// - Parameter controller: The authorization controller requesting the anchor.
    /// - Returns: The presentation anchor to use.
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("Unexpected window scene configuration.")
        }
        return window
    }
}


// MARK: - Delegate
extension AppleSignInCoordinator: ASAuthorizationControllerDelegate {
    /// Handles the completion of the authorization with the provided credentials.
    /// - Parameters:
    ///   - controller: The authorization controller managing the request.
    ///   - authorization: The authorization object containing the credentials.
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        do {
            if let info = try convertCredential(auth: authorization, currentNonce: currentNonce) {
                completion?(.success(info))
            }
        } catch {
            completion?(.failure(error))
        }
    }
    
    /// Handles the completion of the authorization with an error.
    /// - Parameters:
    ///   - controller: The authorization controller managing the request.
    ///   - error: The error encountered during the authorization process.
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion?(.failure(error))
    }
}


// MARK: - Handler
public extension AppleSignInCoordinator {
    /// Initiates the Apple Sign-In process and returns the user's credentials.
    /// - Parameter requestedScopes: The scopes to request during sign-in. Default is `[.email, .fullName]`.
    /// - Returns: The `AppleCredentialInfo` containing the user's credentials, or `nil` if the user cancels.
    func createAppleTokenInfo(requestedScopes: [ASAuthorization.Scope]? = [.email, .fullName]) async throws -> AppleCredentialInfo? {
        return try await withCheckedThrowingContinuation { continuation in
            completion = { result in
                switch result {
                case .success(let info): continuation.resume(returning: info)
                case .failure(let error):
                    if let appleSignInError = error as? ASAuthorizationError, appleSignInError.code == .canceled {
                        continuation.resume(returning: nil)
                    } else {
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            currentNonce = NonceFactory.randomNonceString()
            
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = requestedScopes
            request.nonce = NonceFactory.sha256(currentNonce!)
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
    }
}


// MARK: - Private Methods
private extension AppleSignInCoordinator {
    /// Converts the authorization object into an `AppleCredentialInfo` object.
    /// - Parameters:
    ///   - auth: The authorization object containing the credentials.
    ///   - currentNonce: The nonce used to verify the credentials.
    /// - Returns: The `AppleCredentialInfo` containing the user's credentials, or `nil` if conversion fails.
    /// - Throws: An error if the conversion fails due to invalid state or serialization issues.
    func convertCredential(auth: ASAuthorization, currentNonce: String?) throws -> AppleCredentialInfo? {
        guard let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential else { return nil }
        guard let currentNonce = currentNonce else { throw AppleSignInError.invalidState }
        
        let displayName = getDisplayName(from: appleIDCredential.fullName)
        let idTokenString = try serializeToken(appleIDCredential.identityToken)
        
        return .init(email: appleIDCredential.email, displayName: displayName, idTokenString: idTokenString, nonce: currentNonce)
    }
    
    /// Assembles a display name from the provided name components.
    /// - Parameter fullName: The `PersonNameComponents` containing the user's full name.
    /// - Returns: A `String` representing the user's full name.
    func getDisplayName(from fullName: PersonNameComponents?) -> String {
        let firstName = fullName?.givenName ?? ""
        let lastName = fullName?.familyName ?? ""
        return "\(firstName) \(lastName)"
    }
    
    /// Serializes the identity token into a string.
    /// - Parameter appleIDToken: The identity token as `Data`.
    /// - Returns: A `String` representing the serialized token.
    /// - Throws: An error if the token cannot be serialized.
    func serializeToken(_ appleIDToken: Data?) throws -> String {
        guard let appleIDToken = appleIDToken, let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AppleSignInError.unableToSerializeToken
        }
        return idTokenString
    }
}
