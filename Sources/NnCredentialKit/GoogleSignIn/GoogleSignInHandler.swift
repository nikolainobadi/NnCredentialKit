//
//  GoogleSignInHandler.swift
//  
//
//  Created by Nikolai Nobadi on 8/3/24.
//

import UIKit
import GoogleSignIn

@MainActor
public enum GoogleSignInHandler {
    public static func signIn(rootVC: UIViewController?) async throws -> GoogleCredentialInfo? {
        guard let rootVC = rootVC else { return nil }
        
        do {
            let result = try await performSignIn(with: rootVC)
            
            return try processSignInResult(result)
        } catch let googleError as GIDSignInError {
            return try handleGoogleError(googleError)
        }
    }
}


// MARK: - Private Methods
private extension GoogleSignInHandler {
    static func performSignIn(with rootVC: UIViewController) async throws -> GIDSignInResult {
        return try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
    }
    
    static func processSignInResult(_ result: GIDSignInResult) throws -> GoogleCredentialInfo? {
        let user = result.user
        
        guard let idToken = user.idToken else { return nil }
        
        let email = user.profile?.email
        let displayName = assembleDisplayName(givenName: user.profile?.givenName, familyName: user.profile?.familyName)
        
        return .init(email: email, displayName: displayName, tokenId: idToken.tokenString, accessTokenId: user.accessToken.tokenString)
    }
    
    static func assembleDisplayName(givenName: String?, familyName: String?) -> String {
        return [givenName, familyName].compactMap { $0 }.joined(separator: " ")
    }
    
    static func handleGoogleError(_ error: GIDSignInError) throws -> GoogleCredentialInfo? {
        if error.code == .canceled {
            print("User cancelled sign-in, no action required")
            return nil
        }
        
        throw error
    }
}

