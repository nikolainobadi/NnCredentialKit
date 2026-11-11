/// An enum representing the result of an account link action.
public enum AccountLinkActionResult: Sendable, Equatable {
    /// The link/unlink action was successful.
    case success

    /// The user canceled the link/unlink action.
    case canceled
}
