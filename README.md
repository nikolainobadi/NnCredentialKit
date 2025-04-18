# NnCredentialKit

![Swift](https://badgen.net/badge/swift/6.0%2B/purple)
![Platform](https://badgen.net/badge/platform/iOS%2016+/blue)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

NnCredentialKit is a comprehensive Swift package designed to handle user authentication workflows, including email/password sign-up, social login ([Apple Sign-In](https://developer.apple.com/documentation/authenticationservices), [Google Sign-In](https://developers.google.com/identity/sign-in/ios)), and account linking. This package streamlines the process of managing credentials, reauthentication, and account deletion.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
  - [Social Sign-In](#social-sign-in)
  - [Account Linking](#account-linking)
  - [Firebase Integration Notes](#firebase-integration-notes)
- [Dependencies](#dependencies)
- [Contributing](#contributing)
- [License](#license)

## Features

- **Account Link Section**: Easily integrate account linking for various providers, with customizable colors and accessibility support.
- **Credential Management**: Load and manage credentials for Apple, Google, and email/password logins.
- **Reauthentication Workflow**: Handle reauthentication for sensitive actions using custom alerts.
- **Social Sign-In Integration**: Seamlessly integrate [Apple Sign-In](https://developer.apple.com/documentation/authenticationservices) and [Google Sign-In](https://developers.google.com/identity/sign-in/ios) flows with reusable components.
- **Error Handling**: Robust error handling for common authentication issues.

## Installation

### Xcode Projects

To integrate `NnCredentialKit` into your Xcode project using Swift Package Manager:

1. In Xcode, go to **File > Swift Packages > Add Package Dependency**.
2. Enter the following repository URL:

   ```
   https://github.com/nikolainobadi/NnCredentialKit
   ```

3. Choose the version `3.0.0`.
4. Select the target where you want to add the package.

### Swift Package

If you are using `NnCredentialKit` in another Swift package, add it to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/nikolainobadi/NnCredentialKit", from: "3.0.0")
]
```

Then, in the target you want to use `NnCredentialKit`, add it to the list of dependencies:

```swift
.target(
    name: "YourTargetName",
    dependencies: [
        "NnCredentialKit"
    ]
)
```

## Usage

> Import `NnCredentialKit` in your Swift file and implement the required delegates to start managing authentication flows.

### Social Sign-In

`GoogleSignInHandler` and `AppleSignInCoordinator` help manage Google and Apple sign-ins.

```swift
let appleCredentialInfo = try await AppleSignInCoordinator().createAppleTokenInfo()
let googleCredentialInfo = try await GoogleSignInHandler.signIn(rootVC: viewController)
```

Alternatively, you can use `SocialCredentialManager` to handle both operations:

```swift
let socialManager = SocialCredentialManager(appleSignInScopes: [.email])
let appleCredentialInfo = try await socialManager.loadAppleCredential()
let googleCredentialInfo = try await socialManager.loadGoogleCredential()
```

The top-most `UIViewController` will be used automatically during Google Sign-In.

### Account Linking

The `AccountLinkSection` view provides a way to display and manage linked accounts within your app. It supports Apple, Google, and email/password providers. It requires an `AccountLinkSectionColorsConfig` for customizing text colors and an `AccountLinkDelegate` to perform the credential linking.

```swift
import NnCredentialKit

struct ContentView: View {
    var body: some View {
        AccountLinkSection(
            config: .init(providerNameColor: .primary, emailColor: .secondary, linkButtonColor: .blue),
            delegate: YourAccountLinkDelegate(),
            appleSignInScopes: [.email, .fullName]
        )
    }
}
```

### Firebase Integration Notes

When using **Firebase Authentication**, it's common for operations like updating sensitive user information (email, password, or account linking) to fail if the user’s sign-in session is considered too old. Firebase throws an error with the `.requiresRecentLogin` code in these cases.

**NnCredentialKit** is designed to handle this automatically by providing a **secure reauthentication flow** whenever a `.reauthRequired` result occurs. After reauthentication is successfully completed, the originally intended operation is automatically retried without any extra logic needed in your code.

This ensures smooth Firebase integration, especially for:

- Linking additional sign-in providers
- Deleting user accounts
- Updating sensitive credentials

#### Detecting `.requiresRecentLogin` Errors

When performing Firebase auth operations, you can detect if reauthentication is needed using the following helper:

```swift
func handleAuthOperation(_ operation: @escaping () async throws -> Void) async -> AccountCredentialResult {
    do {
        try await operation()
        return .success
    } catch let nsError as NSError {
        if let authError = AuthErrorCode(rawValue: nsError.code), authError == .requiresRecentLogin {
            return .reauthRequired
        }
        return .failure(nsError)
    }
}
```

#### Example: Wrapping Firebase Auth Operations

You can integrate `handleAuthOperation` inside your `AccountLinkDelegate` implementation like this:

```swift
func linkProvider(with type: CredentialType) async -> AccountCredentialResult {
    return await handleAuthOperation {
        try await delegate.link(to: type)
    }
}

func unlinkProvider(_ type: AuthProviderType) async -> AccountCredentialResult {
    return await handleAuthOperation {
        try await delegate.unlink(from: type)
    }
}
```

In these examples:
- `delegate.link(to:)` and `delegate.unlink(from:)` represent your Firebase linking/unlinking methods.
- `handleAuthOperation` ensures any `.requiresRecentLogin` Firebase error is automatically escalated to `.reauthRequired`, allowing NnCredentialKit to seamlessly handle reauthentication.

## Dependencies

`NnCredentialKit` depends on the following external libraries:

- [GoogleSignIn](https://developers.google.com/identity/sign-in/ios) (Google Sign-In)
- [AuthenticationServices](https://developer.apple.com/documentation/authenticationservices) (Apple Sign-In)

## Contributing

Any feedback or ideas to enhance NnCredentialKit would be greatly appreciated.  
Please feel free to [open an issue](https://github.com/nikolainobadi/NnCredentialKit/issues) or submit a pull request if you'd like to help improve this Swift package.

## License

`NnCredentialKit` is available under the MIT license. See the LICENSE file for more information.
