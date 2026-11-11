/// An enum representing the result of an account credential operation.
public enum AccountCredentialResult: Sendable {
    /// The operation was successful.
    case success
    
    /// The operation requires reauthentication.
    case reauthRequired
    
    /// The operation failed with an error.
    case failure(Error)
}
