import Foundation

/// An enum representing common errors that can occur during credential-related operations.
public enum CredentialError: Error {
    /// The operation was cancelled by the user.
    case cancelled
    
    /// No authentication providers were found.
    case emptyAuthProviders
    
    /// The provided passwords do not match.
    case passwordsMustMatch
    
    /// Attempting to unlink the only linked provider.
    case cannotUnlinkOnlyProvider
}
