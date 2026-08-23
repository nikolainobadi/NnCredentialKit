# Providers API

Apple Sign-In and Google Sign-In service integrations and credential models.

---

## Class: AppleSignInService

Handles the Apple Sign-In flow including nonce generation, authorization, and credential extraction.

```swift
@MainActor
public final class AppleSignInService: NSObject
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `init()` | Creates a new Apple Sign-In service with default nonce factory and auth session |
| `convenience init(debugEnabled: Bool)` | Same defaults, with `[NnCredentialKit]` console logging when `true` |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `createAppleTokenInfo(requestedScopes: [ASAuthorization.Scope]? = [.email, .fullName]) async throws` | `AppleCredentialInfo?` | Initiates Apple Sign-In; returns nil on user cancellation |

### Usage Example

```swift
let appleService = AppleSignInService()
if let credential = try await appleService.createAppleTokenInfo() {
    // Use credential.idTokenString and credential.nonce for Firebase auth
}
```

### Internal Flow

1. Generates a fresh cryptographic nonce via `NonceFactory`
2. Passes the SHA-256 hash of the nonce to the `ASAuthorizationController`
3. Awaits the authorization callback
4. On success: converts the `ASAuthorizationAppleIDCredential` to `AppleCredentialInfo`
5. On cancellation (`ASAuthorizationError.canceled`): returns `nil` (does not throw)
6. On other errors: re-throws

### Nonce Generation Warning

`NonceFactory.randomNonceString()` calls `fatalError` if `SecRandomCopyBytes` fails. This is an unrecoverable crash, not a recoverable error. In practice this never happens on iOS.

---

## Struct: AppleCredentialInfo

Contains the credential information from a successful Apple Sign-In.

```swift
public struct AppleCredentialInfo: Sendable
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `init(email: String?, displayName: String?, idTokenString: String, nonce: String)` | Creates Apple credential info |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `nonce` | `String` | The raw nonce used for the sign-in request |
| `email` | `String?` | User's email (may be nil on subsequent sign-ins) |
| `displayName` | `String?` | User's display name (may be nil on subsequent sign-ins) |
| `idTokenString` | `String` | The identity token string for Firebase authentication |

### Display Name Format

The display name is built from `PersonNameComponents.givenName` and `familyName`, joined by a space and trimmed. If both components have internal whitespace, it is preserved — only outer edges are trimmed. Example: `" John "` + `" Doe "` → `"John   Doe"` (3 internal spaces).

---

## Enum: AppleSignInError

Errors specific to the Apple Sign-In flow.

```swift
public enum AppleSignInError: Error
```

### Cases

| Case | Associated Values | Description |
|------|-------------------|-------------|
| `invalidState` | — | Nonce is nil or credential type is unexpected |
| `unableToFetchIdentityToken` | — | Identity token data is missing from the Apple response |
| `unableToSerializeToken` | — | Identity token data cannot be decoded as UTF-8 |
| `canceled` | — | User cancelled the Apple Sign-In flow |

---

## Typealias: AppleSignInCoordinator (Deprecated)

```swift
@available(*, deprecated, renamed: "AppleSignInService")
public typealias AppleSignInCoordinator = AppleSignInService
```

Deprecated alias for `AppleSignInService`. Use `AppleSignInService` directly.

---

## Class: GoogleSignInService

Handles the Google Sign-In flow using the GoogleSignIn SDK.

```swift
@MainActor
public final class GoogleSignInService
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `convenience init(viewController: UIViewController?, debugEnabled: Bool = false)` | Creates service with the presenting view controller; logs `[NnCredentialKit]` console messages when `debugEnabled` is `true` |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `signIn() async throws` | `GoogleCredentialInfo?` | Initiates Google Sign-In; returns nil on cancellation or missing ID token |

### Usage Example

```swift
let googleService = GoogleSignInService(viewController: rootViewController)
if let credential = try await googleService.signIn() {
    // Use credential.tokenId and credential.accessTokenId for Firebase auth
}
```

### Silent Nil Cases

`signIn()` returns `nil` (without throwing) in two cases:
1. **User cancellation** — User dismisses the Google Sign-In sheet
2. **Missing ID token** — Google returns a result with `idTokenString: nil`

Both are indistinguishable to the caller. A nil `viewController` at init time also causes a silent `nil` return.

---

## Struct: GoogleCredentialInfo

Contains the credential information from a successful Google Sign-In.

```swift
public struct GoogleCredentialInfo: Sendable
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `init(email: String?, displayName: String?, tokenId: String, accessTokenId: String)` | Creates Google credential info |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `email` | `String?` | User's email from Google |
| `tokenId` | `String` | The ID token for Firebase authentication |
| `displayName` | `String?` | User's display name from Google profile |
| `accessTokenId` | `String` | The access token from Google |

### Display Name Format

Display name is assembled via `[givenName, familyName].compactMap { $0 }.joined(separator: " ")`. If both are nil, result is `""`. No trailing/leading spaces when only one name component exists.

---

## Enum: GoogleSignInHandler (Deprecated)

```swift
@MainActor
@available(*, deprecated, message: "Use GoogleSignInService directly instead")
public enum GoogleSignInHandler
```

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `static func signIn(rootVC: UIViewController?) async throws` | `GoogleCredentialInfo?` | Deprecated — forwards to `GoogleSignInService(viewController:).signIn()` |

Use `GoogleSignInService` directly instead.

---

## Best Practices

- **Prefer `SocialCredentialManager` over direct service usage** — It manages the Apple/Google sign-in services internally and integrates with the reauthentication flow. Use the services directly only for standalone sign-in outside the NnCredentialKit ecosystem.
- **Apple email/name are only available on first sign-in** — Apple only provides email and display name on the user's first authorization. On subsequent sign-ins, these fields are `nil`. Store them on first sign-in.
- **Google Sign-In requires a presenting view controller** — If `viewController` is nil (e.g., no active key window), `signIn()` silently returns `nil`. Ensure you have a foreground window before calling.
- **Handle both nil returns and thrown errors** — A nil return means user cancellation (normal flow). Thrown errors indicate actual failures (network, invalid state, token serialization). Don't treat nil as an error.
- **Use `AppleSignInService` not `AppleSignInCoordinator`** — The coordinator typealias is deprecated and will be removed in a future version. Same applies to `GoogleSignInHandler`.
