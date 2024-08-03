//
//  AppleSignInCoordinator.swift
//  
//
//  Created by Nikolai Nobadi on 8/3/24.
//

import AuthenticationServices

public final class AppleSignInCoordinator: NSObject {
    private var currentNonce: String?
    private var completion: ((Result<AppleCredentialInfo?, Error>) -> Void)?
    
    public override init() { }
}


// MARK: - PresentationProviding
extension AppleSignInCoordinator: ASAuthorizationControllerPresentationContextProviding {
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
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        do {
            if let info = try convertCredential(auth: authorization, currentNonce: currentNonce) {
                completion?(.success(info))
            }
        } catch {
            completion?(.failure(error))
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion?(.failure(error))
    }
}


// MARK: - Handler
public extension AppleSignInCoordinator {
    func createAppleTokenInfo(requestedScopes: [ASAuthorization.Scope]? = [.email, .fullName]) async throws -> AppleCredentialInfo? {
        return try await withCheckedThrowingContinuation { continuation in
            completion = { result in
                switch result {
                case .success(let info):
                    continuation.resume(returning: info)
                case .failure(let error):
                    if let appleSignInError = error as? ASAuthorizationError, appleSignInError.code == .canceled {
                        return continuation.resume(returning: nil)
                    } else {
                        return continuation.resume(throwing: error)
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
    func convertCredential(auth: ASAuthorization, currentNonce: String?) throws -> AppleCredentialInfo? {
        guard let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential else { return nil }
        guard let currentNonce = currentNonce else { throw AppleSignInError.invalidState }
        
        let displayName = getDisplayName(from: appleIDCredential.fullName)
        let idTokenString = try serializeToken(appleIDCredential.identityToken)
        
        return .init(email: appleIDCredential.email, displayName: displayName, idTokenString: idTokenString, nonce: currentNonce)
    }

    func getDisplayName(from fullName: PersonNameComponents?) -> String {
        let firstName = fullName?.givenName ?? ""
        let lastName = fullName?.familyName ?? ""
        
        return "\(firstName) \(lastName)"
    }

    func serializeToken(_ appleIDToken: Data?) throws -> String {
        guard let appleIDToken = appleIDToken, let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AppleSignInError.unableToSerializeToken
        }
        
        return idTokenString
    }
}

