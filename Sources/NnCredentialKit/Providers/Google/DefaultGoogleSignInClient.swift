//
//  DefaultGoogleSignInClient.swift
//  NnCredentialKit
//
//  Created by Nikolai Nobadi on 9/29/25.
//

import UIKit
@preconcurrency import GoogleSignIn

struct DefaultGoogleSignInClient {
    private let viewController: UIViewController?
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
}

extension DefaultGoogleSignInClient: GoogleSignInClient {
    func signIn() async throws -> GoogleSignInResult? {
        guard let viewController else {
            return nil
        }
        
        do {
            let user = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController).user
            
            return .init(
                idTokenString: user.idToken?.tokenString,
                accessTokenString: user.accessToken.tokenString,
                email: user.profile?.email,
                givenName: user.profile?.givenName,
                familyName: user.profile?.familyName
            )
        } catch let googleError as GIDSignInError {
            if googleError.code == .canceled {
                print("User cancelled sign-in, no action required")
                return nil
            }
            
            throw googleError
        }
    }
}
