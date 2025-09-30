//
//  GoogleSignInHandler.swift
//  
//
//  Created by Nikolai Nobadi on 8/3/24.
//

import UIKit

/// A handler for managing Google Sign-In operations.
@MainActor
public enum GoogleSignInHandler {
    /// Initiates the Google Sign-In process.
    /// - Parameter rootVC: The root view controller from which to present the sign-in flow.
    /// - Returns: A `GoogleCredentialInfo` object if sign-in is successful, or `nil` if the user cancels.
    public static func signIn(rootVC: UIViewController?) async throws -> GoogleCredentialInfo? {
        return try await GoogleSignInCoordinator(client: DefaultGoogleSignInClient(viewController: rootVC)).signIn()
    }
}
