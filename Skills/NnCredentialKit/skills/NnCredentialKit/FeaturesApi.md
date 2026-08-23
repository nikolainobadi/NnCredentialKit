# Features API

Account linking UI components, account deletion service, and social credential management.

---

## Class: AccountLinkViewModel

Observable view model managing account provider linking/unlinking with automatic reauthentication.

```swift
@MainActor
public final class AccountLinkViewModel: ObservableObject
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `convenience init(delegate: AccountLinkDelegate, appleSignInScopes: [ASAuthorization.Scope], preventUnlinkingLastProvider: Bool = false, debugEnabled: Bool = false)` | Production initializer — creates internal `CredentialManager` and `ReauthenticationManager` |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `providers` | `[AuthProvider]` | Published array of all providers with their linked status |
| `preventUnlinkingLastProvider` | `Bool` | When true, hides the unlink button for the last linked provider |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `loadProviders()` | `Void` | Synchronously refreshes `providers` from `delegate.loadSupportedProviders()` |
| `shouldShowButton(for provider: AuthProvider)` | `Bool` | Whether to show the link/unlink button for this provider |
| `@discardableResult linkAction(_ provider: AuthProvider) async throws` | `AccountLinkActionResult` | Links or unlinks the provider based on current linked state |

### Usage Example

```swift
let viewModel = AccountLinkViewModel(
    delegate: firebaseAuthManager,
    appleSignInScopes: [.email, .fullName],
    preventUnlinkingLastProvider: true
)
viewModel.loadProviders()
```

### Internal Flow

- `linkAction(_:)` dispatches to `linkAccount` (unlinked providers) or `unlinkAccount` (linked providers)
- On link: fetches credential via `CredentialManager`, then calls `delegate.linkProvider(with:)`. Returns `.canceled` if user dismisses credential UI
- On unlink: guards that at least 2 providers are linked (throws `CredentialError.cannotUnlinkOnlyProvider` if not), then calls `delegate.unlinkProvider(_:)`
- On `.reauthRequired`: reauthenticates and retries with the **same credential** (no re-fetch)
- `loadProviders()` is called unconditionally after every action, including cancellation

### Custom UI Example

```swift
@StateObject private var viewModel = AccountLinkViewModel(
    delegate: myDelegate,
    appleSignInScopes: [.email, .fullName],
    preventUnlinkingLastProvider: true
)

var body: some View {
    List(viewModel.providers, id: \.self) { provider in
        HStack {
            Text(provider.type.rawValue)
            if viewModel.shouldShowButton(for: provider) {
                Button(provider.isLinked ? "Unlink" : "Link") {
                    Task { try await viewModel.linkAction(provider) }
                }
            }
        }
    }
    .onAppear { viewModel.loadProviders() }
}
```

### Default Mismatch Warning

`AccountLinkSection.init` defaults `preventUnlinkingLastProvider` to `true`, but `AccountLinkViewModel.init` defaults to `false`. When using the ViewModel directly without the view, the unlink button is always visible by default.

---

## Struct: AccountLinkSection

SwiftUI view displaying a list of authentication providers with link/unlink buttons.

```swift
public struct AccountLinkSection<LinkButton: View>: View
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `init(config: AccountLinkSectionColorsConfig, delegate: AccountLinkDelegate, appleSignInScopes: [ASAuthorization.Scope], preventUnlinkingLastProvider: Bool = true, debugEnabled: Bool = false, @ViewBuilder linkButton: @escaping (AccountLinkButtonDelegate) -> LinkButton)` | Creates the section with custom link button UI |

### Usage Example

```swift
AccountLinkSection(
    config: AccountLinkSectionColorsConfig(),
    delegate: firebaseAuthManager,
    appleSignInScopes: [.email, .fullName]
) { buttonDelegate in
    Button(buttonDelegate.buttonText) {
        Task { try await buttonDelegate.linkAction() }
    }
}
```

---

## Struct: AccountLinkSectionColorsConfig

Color configuration for the `AccountLinkSection` view.

```swift
public struct AccountLinkSectionColorsConfig
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `init(providerNameColor: Color = .primary, emailColor: Color = .secondary)` | Creates color config with optional overrides |

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `providerNameColor` | `Color` | Color for provider name labels (default: `.primary`) |
| `emailColor` | `Color` | Color for linked email text (default: `.secondary`) |

---

## Class: AccountDeleter

Handles account deletion with automatic reauthentication when Firebase requires recent login.

```swift
@MainActor
public final class AccountDeleter
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `convenience init(delegate: DeleteAccountDelegate, debugEnabled: Bool = false)` | Production initializer — uses empty Apple scopes for reauthentication |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `deleteAccount() async throws` | `Void` | Deletes the account, handling reauthentication automatically |

### Usage Example

```swift
let deleter = AccountDeleter(delegate: firebaseAuthManager)
try await deleter.deleteAccount()
```

### Internal Flow

1. Calls `delegate.deleteAccount()` and switches on the result
2. On `.success`: returns immediately
3. On `.failure(error)`: re-throws the error
4. On `.reauthRequired`: triggers reauthentication flow, then **recursively** calls `deleteAccount()` again

### Apple Scopes Warning

The convenience `init(delegate:)` creates a `CredentialManager(appleSignInScopes: [])` — Apple Sign-In during account-deletion reauthentication requests **no scopes** (no email, no full name). This is intentional for reauthentication but means you cannot use this initializer if you need scopes during the reauth Apple Sign-In.

---

## Class: SocialCredentialManager

Manages loading social sign-in credentials from Apple and Google providers.

```swift
@MainActor
public final class SocialCredentialManager
```

### Initialization

| Initializer | Description |
|-------------|-------------|
| `init(appleSignInScopes: [ASAuthorization.Scope], debugEnabled: Bool = false)` | Creates manager with specified Apple Sign-In scopes |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `loadAppleCredential() async throws` | `AppleCredentialInfo?` | Initiates Apple Sign-In; returns nil on cancellation |
| `loadGoogleCredential() async throws` | `GoogleCredentialInfo?` | Initiates Google Sign-In; returns nil on cancellation |

### Google Sign-In Silent Nil

`loadGoogleCredential()` gets the top view controller via `UIApplication.shared.getTopViewController()`. If no foreground key window exists (e.g., called during app transition), the view controller is `nil` and Google Sign-In silently returns `nil` — indistinguishable from user cancellation.

---

## Reauthentication Flow

The full delegation chain when reauthentication is triggered:

```
AccountDeleter.deleteAccount() / AccountLinkViewModel.linkAction()
  └─► delegate method returns .reauthRequired
      └─► ReauthenticationManager.start(actionAfterReauth:)
            ├─► delegate.loadLinkedProviders() → filters to linked only
            ├─► CredentialManager.loadReauthCredential(linkedProviders:)
            │     ├─► CredentialAlertHandler.showReauthenticationAlert(...)
            │     └─► Per selected provider:
            │           ├─ .apple  → AppleSignInService.createAppleTokenInfo()
            │           ├─ .google → GoogleSignInService.signIn()
            │           └─ .emailPassword → CredentialAlertHandler.loadPassword(...)
            ├─► delegate.reauthenticate(with: credential)
            └─► actionAfterReauth() → retries original operation
```

---

## Debug Logging

Every public entry point accepts `debugEnabled: Bool = false`. When `true`, workflow details print to the console prefixed with `[NnCredentialKit]`, and the flag is threaded automatically through all internally-constructed components (`CredentialManager`, `ReauthenticationManager`, `SocialCredentialManager`, and the Apple/Google services).

```swift
AccountLinkSection(config: .init(), delegate: delegate, appleSignInScopes: [.email], debugEnabled: true) { ... }
AccountDeleter(delegate: delegate, debugEnabled: true)
SocialCredentialManager(appleSignInScopes: [.email], debugEnabled: true)
```

Log messages cover workflow steps, cancellations, and failures only — passwords, tokens, nonces, and email addresses are never logged.

---

## Best Practices

- **Use `AccountLinkSection` for standard UI** — It wires up `AccountLinkViewModel` internally. Use the ViewModel directly only when building fully custom UI.
- **Set `preventUnlinkingLastProvider: true`** — Prevents users from unlinking their only auth provider, which would lock them out. `AccountLinkSection` defaults this to `true`; the ViewModel defaults to `false`.
- **Handle errors from `linkAction`** — While `.canceled` is a normal return value, thrown errors (network failures, `CredentialError.cannotUnlinkOnlyProvider`) need UI treatment.
- **`AccountDeleter` is one-shot** — Create a new instance for each deletion attempt. The convenience init is sufficient for most cases.
- **Reauthentication retries with same credential** — After reauthentication, the linking flow retries with the originally-fetched credential (no re-fetch). If the credential expires quickly, this is safe because reauthentication just established a fresh session.
