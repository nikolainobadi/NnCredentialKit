//
//  CredentialError.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

import Foundation
import NnSwiftUIKit

/// An enum representing common errors that can occur during credential-related operations.
enum CredentialError: Error {
    /// The operation was cancelled by the user.
    case cancelled
    
    /// No authentication providers were found.
    case emptyAuthProviders
    
    /// The provided passwords do not match.
    case passwordsMustMatch
    
    /// Attempting to unlink the only linked provider.
    case cannotUnlinkOnlyProvider
}


// MARK: - DisplayableError
extension CredentialError: NnDisplayableError {
    var message: String {
        switch self {
        case .cancelled:
            return "action cancelled."
        case .emptyAuthProviders:
            return "This account is not linked to any auth providers."
        case .passwordsMustMatch:
            return "The passwords must match."
        case .cannotUnlinkOnlyProvider:
            return "You cannot unlink your account if it is only linked to a single auth provider."
        }
    }
}
