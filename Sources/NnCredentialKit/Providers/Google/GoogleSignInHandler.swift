//
//  GoogleSignInHandler.swift
//
//
//  Created by Nikolai Nobadi on 8/3/24.
//

import UIKit

/// A handler for managing Google Sign-In operations.
///
/// - Warning: This type is deprecated. Use `GoogleSignInService` directly instead.
@MainActor
@available(*, deprecated, message: "Use GoogleSignInService directly instead")
public enum GoogleSignInHandler {
    /// Initiates the Google Sign-In process.
    /// - Parameter rootVC: The root view controller from which to present the sign-in flow.
    /// - Returns: A `GoogleCredentialInfo` object if sign-in is successful, or `nil` if the user cancels.
    ///
    /// - Warning: This method is deprecated. Use `GoogleSignInService(viewController:).signIn()` directly instead.
    @available(*, deprecated, message: "Use GoogleSignInService(viewController:).signIn() instead")
    public static func signIn(rootVC: UIViewController?) async throws -> GoogleCredentialInfo? {
        return try await GoogleSignInService(viewController: rootVC).signIn()
    }
}
