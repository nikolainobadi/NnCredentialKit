//
//  DefaultAppleAuthSession.swift
//  NnCredentialKit
//
//  Created by Nikolai Nobadi on 9/28/25.
//

import AuthenticationServices

final class DefaultAppleAuthSession: NSObject {
    private var completion: ((Result<AppleAuthRawCredential, Error>) -> Void)?
}


// MARK: - AppleAuthSession
extension DefaultAppleAuthSession: AppleAuthSession {
    func start(scopes: [ASAuthorization.Scope]?, nonce: String, completion: @escaping (Result<AppleAuthRawCredential, Error>) -> Void) {
        self.completion = completion
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = scopes
        request.nonce = nonce
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}


// MARK: - ASAuthorizationControllerPresentationContextProviding
extension DefaultAppleAuthSession: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = scene.windows.first else {
            fatalError("No window")
        }
        
        return window
    }
}


// MARK: - ASAuthorizationControllerDelegate
extension DefaultAppleAuthSession: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            completion?(.success(.init(email: credential.email, fullName: credential.fullName, idTokenData: credential.identityToken)))
        } else {
            completion?(.failure(AppleSignInError.invalidState))
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion?(.failure(error))
    }
}
