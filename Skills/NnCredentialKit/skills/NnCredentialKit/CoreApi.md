# Core API

Domain models, delegate protocols, error types, and accessibility identifiers for NnCredentialKit.

---

## Enum: CredentialType

Wraps provider-specific credential info into a unified type for authentication operations.

```swift
public enum CredentialType: Sendable
```

### Cases

| Case | Associated Values | Description |
|------|-------------------|-------------|
| `apple` | `AppleCredentialInfo` | Apple Sign-In credential |
| `google` | `GoogleCredentialInfo` | Google Sign-In credential |
| `emailPassword` | `email: String, password: String` | Email/password credential |

### Usage Example

```swift
let credential: CredentialType = .apple(appleCredentialInfo)
switch credential {
case .apple(let info): try await delegate.reauthenticate(with: credential)
case .google(let info): try await delegate.reauthenticate(with: credential)
case .emailPassword(let email, let password): try await delegate.reauthenticate(with: credential)
}
```

---

## Struct: AuthProvider

Represents a linked or available authentication provider with its associated email.

```swift
public struct AuthProvider: Hashable, Sendable
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `init(linkedEmail: String, type: AuthProviderType)` | Creates a provider with linked email and type |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `linkedEmail` | `String` | The email associated with this provider. Empty string means not linked |
| `type` | `AuthProviderType` | The provider type (apple, google, emailPassword) |

### Usage Example

```swift
let provider = AuthProvider(linkedEmail: "user@example.com", type: .apple)
```

### Linked State

An `AuthProvider` is considered **linked** when `linkedEmail` is non-empty. An empty `linkedEmail` (`""`) means the provider is available but not linked. This sentinel value drives `shouldShowButton(for:)` and unlink guards throughout the package.

---

## Enum: AuthProviderType

Identifies the authentication provider type.

```swift
public enum AuthProviderType: String, CaseIterable, Sendable
```

### Cases

| Case | Associated Values | Description |
|------|-------------------|-------------|
| `apple` | — | Apple Sign-In provider |
| `google` | — | Google Sign-In provider |
| `emailPassword` | — | Email/password provider |

---

## Enum: AccountCredentialResult

Result type for delegate operations that may require reauthentication.

```swift
public enum AccountCredentialResult: Sendable
```

### Cases

| Case | Associated Values | Description |
|------|-------------------|-------------|
| `success` | — | Operation completed successfully |
| `reauthRequired` | — | Firebase requires recent login; triggers reauthentication flow |
| `failure` | `Error` | Operation failed with an error |

### Usage Example — Firebase Integration

```swift
func deleteAccount() async -> AccountCredentialResult {
    do {
        try await firebaseAuth.currentUser?.delete()
        return .success
    } catch let error as AuthErrorCode where error == .requiresRecentLogin {
        return .reauthRequired
    } catch {
        return .failure(error)
    }
}
```

### Internal Flow

When a delegate method returns `.reauthRequired`, the calling manager (`AccountDeleter` or `AccountLinkViewModel`) automatically:
1. Invokes `ReauthenticationManager.start` to present credential selection UI
2. Reauthenticates the user with the selected provider
3. Recursively retries the original operation

---

## Enum: AccountLinkActionResult

Result type for account link/unlink actions, distinguishing success from user cancellation.

```swift
public enum AccountLinkActionResult: Sendable, Equatable
```

### Cases

| Case | Associated Values | Description |
|------|-------------------|-------------|
| `success` | — | Link/unlink operation completed |
| `canceled` | — | User cancelled the credential UI (not an error) |

### Cancellation vs Errors

A `.canceled` result is returned when the user dismisses the credential selection UI (e.g., Apple/Google sign-in sheet). Actual errors (network failures, etc.) are thrown, not wrapped in this result type.

---

## Enum: CredentialError

Domain errors thrown by credential operations.

```swift
public enum CredentialError: Error
```

### Cases

| Case | Associated Values | Description |
|------|-------------------|-------------|
| `cancelled` | — | User cancelled the reauthentication flow |
| `emptyAuthProviders` | — | No linked providers available for reauthentication |
| `passwordsMustMatch` | — | Email sign-up password and confirmation don't match |
| `cannotUnlinkOnlyProvider` | — | Cannot unlink the last remaining linked provider |

---

## Protocol: ReauthenticationDelegate

Base protocol for types that provide reauthentication support. Implemented by your Firebase auth layer.

```swift
public protocol ReauthenticationDelegate: Sendable
```

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `loadLinkedProviders()` | `[AuthProvider]` | Returns all providers (linked and unlinked) for the current user |
| `reauthenticate(with credientialType: CredentialType) async throws` | `Void` | Reauthenticates the user with the given credential |

### Usage Example

```swift
class FirebaseAuthManager: ReauthenticationDelegate {
    func loadLinkedProviders() -> [AuthProvider] {
        // Return providers from Firebase Auth.auth().currentUser?.providerData
        return [AuthProvider(linkedEmail: "user@email.com", type: .emailPassword)]
    }

    func reauthenticate(with credentialType: CredentialType) async throws {
        // Call Firebase Auth reauthentication
    }
}
```

---

## Protocol: AccountLinkDelegate

Protocol for account linking/unlinking operations. Extends `ReauthenticationDelegate`.

```swift
public protocol AccountLinkDelegate: ReauthenticationDelegate
```

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `loadSupportedProviders()` | `[AuthProvider]` | Returns all supported providers with their linked status |
| `linkProvider(with type: CredentialType) async` | `AccountCredentialResult` | Links a new provider to the account |
| `unlinkProvider(_ type: AuthProviderType) async` | `AccountCredentialResult` | Unlinks a provider from the account |

### Delegate Protocol Hierarchy

| Protocol | Extends | Additional Requirements |
|----------|---------|------------------------|
| `ReauthenticationDelegate` | — | `loadLinkedProviders()`, `reauthenticate(with:)` |
| `AccountLinkDelegate` | `ReauthenticationDelegate` | `loadSupportedProviders()`, `linkProvider(with:)`, `unlinkProvider(_:)` |
| `DeleteAccountDelegate` | `ReauthenticationDelegate` | `deleteAccount()` |

All three protocols require `Sendable` conformance. A single Firebase manager class can conform to all three since `AccountLinkDelegate` and `DeleteAccountDelegate` share the `ReauthenticationDelegate` base.

---

## Protocol: DeleteAccountDelegate

Protocol for account deletion with reauthentication support. Extends `ReauthenticationDelegate`.

```swift
public protocol DeleteAccountDelegate: ReauthenticationDelegate
```

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `deleteAccount() async` | `AccountCredentialResult` | Deletes the account; return `.reauthRequired` if Firebase requires recent login |

---

## Struct: AccountLinkButtonDelegate

Concrete struct (not a protocol) providing button text and action closure for account link/unlink UI.

```swift
public struct AccountLinkButtonDelegate: Sendable
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `buttonText` | `String` | Returns `"Unlink"` if provider is linked, `"Link"` otherwise |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `@discardableResult linkAction() async throws` | `AccountLinkActionResult` | Executes the link or unlink action |

### Usage Example

```swift
// Used within AccountLinkSection's linkButton closure
AccountLinkSection(config: config, delegate: delegate, appleSignInScopes: [.email]) { buttonDelegate in
    Button(buttonDelegate.buttonText) {
        Task { try await buttonDelegate.linkAction() }
    }
}
```

---

## Enum: CredentialKitAccessibilityId

Accessibility identifiers for UI testing. Defined in the `NnCredentialKitAccessibility` target for import without pulling in the full SDK.

```swift
public enum CredentialKitAccessibilityId: String
```

**Target:** `NnCredentialKitAccessibility` (separate lightweight target)

### Cases

| Case | Raw Value | Description |
|------|-----------|-------------|
| `emailField` | `"signUpEmailField"` | Email text field in sign-up flow |
| `passwordField` | `"signUpPasswordField"` | Password text field in sign-up flow |
| `confirmField` | `"signUpConfirmField"` | Confirm password field in sign-up flow |
| `accountLinkButton` | `"accountLinkButton"` | Account link/unlink button |
| `reauthPasswordField` | `"reauthPasswordField"` | Password field in reauthentication alert |

---

## Best Practices

- **Implement a single Firebase manager** — One class can conform to `AccountLinkDelegate` and `DeleteAccountDelegate` since both extend `ReauthenticationDelegate`. Share the `loadLinkedProviders()` and `reauthenticate(with:)` implementations.
- **Map Firebase errors correctly** — Convert `AuthErrorCode.requiresRecentLogin` to `.reauthRequired` in your delegate methods. The package automatically handles reauthentication and retries the original operation.
- **Linked state is email-based** — An `AuthProvider` with an empty `linkedEmail` is considered unlinked. Ensure your `loadLinkedProviders()` and `loadSupportedProviders()` return empty strings for unlinked providers, not nil-coalesced placeholder values.
- **`loadSupportedProviders()` must be safe to call anytime** — `AccountLinkViewModel` calls it after every link action, including user cancellation. Avoid side effects in this method.
- **Cancellation semantics differ by context** — In linking flows, user cancellation returns `.canceled` (not an error). In reauthentication flows, cancellation throws `CredentialError.cancelled`. Handle both paths in your error handling.
