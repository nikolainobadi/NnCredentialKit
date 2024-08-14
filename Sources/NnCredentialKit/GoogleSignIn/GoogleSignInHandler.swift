//
//  GoogleSignInHandler.swift
//  
//
//  Created by Nikolai Nobadi on 8/3/24.
//

import UIKit
import GoogleSignIn

/// A handler for managing Google Sign-In operations.
@MainActor
public enum GoogleSignInHandler {
    /// Initiates the Google Sign-In process.
    /// - Parameter rootVC: The root view controller from which to present the sign-in flow.
    /// - Returns: A `GoogleCredentialInfo` object if sign-in is successful, or `nil` if the user cancels.
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
    /// Performs the Google Sign-In process.
    /// - Parameter rootVC: The root view controller from which to present the sign-in flow.
    /// - Returns: The result of the Google Sign-In operation.
    static func performSignIn(with rootVC: UIViewController) async throws -> GIDSignInResult {
        return try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
    }
    
    /// Processes the result of a successful Google Sign-In.
    /// - Parameter result: The result object returned by Google Sign-In.
    /// - Returns: A `GoogleCredentialInfo` object containing the user's credentials.
    static func processSignInResult(_ result: GIDSignInResult) throws -> GoogleCredentialInfo? {
        let user = result.user
        guard let idToken = user.idToken else { return nil }
        
        let email = user.profile?.email
        let displayName = assembleDisplayName(givenName: user.profile?.givenName, familyName: user.profile?.familyName)
        
        return .init(email: email, displayName: displayName, tokenId: idToken.tokenString, accessTokenId: user.accessToken.tokenString)
    }
    
    /// Assembles a display name from the given and family names.
    /// - Parameters:
    ///   - givenName: The user's given name.
    ///   - familyName: The user's family name.
    /// - Returns: A combined display name.
    static func assembleDisplayName(givenName: String?, familyName: String?) -> String {
        return [givenName, familyName].compactMap { $0 }.joined(separator: " ")
    }
    
    /// Handles Google Sign-In errors.
    /// - Parameter error: The `GIDSignInError` object containing error information.
    /// - Returns: A `GoogleCredentialInfo` object if the error can be handled, or `nil` if the user cancels.
    static func handleGoogleError(_ error: GIDSignInError) throws -> GoogleCredentialInfo? {
        if error.code == .canceled {
            print("User cancelled sign-in, no action required")
            return nil
        }
        throw error
    }
}
