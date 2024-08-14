
# NnCredentialKit
NnCredentialKit is a comprehensive Swift package designed to handle user authentication workflows, including email/password sign-up, social login (Apple, Google), and account linking. This package streamlines the process of managing credentials, reauthentication, and account deletion.

## Features
- **Account Link Section**: Easily integrate account linking for various providers, with customizable colors and accessibility support.
- **Credential Management**: Load and manage credentials for Apple, Google, and email/password logins.
- **Reauthentication Workflow**: Handle reauthentication for sensitive actions using custom alerts.
- **Social Sign-In Integration**: Seamlessly integrate Apple and Google sign-in flows with reusable components.
- **Error Handling**: Robust error handling for common authentication issues.

## Installation

### Xcode Projects
To integrate `NnCredentialKit` into your Xcode project using Swift Package Manager, follow these steps:

1. In Xcode, go to **File > Swift Packages > Add Package Dependency**.
2. Enter the following repository URL:
   ```
   https://github.com/nikolainobadi/NnCredentialKit
   ```
3. Choose the version 1.0.0.
4. Select the target where you want to add the package.

### Swift Package
If you are using `NnCredentialKit` in another Swift package, add it to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/nikolainobadi/NnCredentialKit", from: "1.0.0")
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

### Account Linking
The `AccountLinkSection` view provides a way to display and manage linked accounts within your app. It supports Apple, Google, and email/password providers.

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

### Social Sign-In
`GoogleSignInHandler` and `AppleSignInCoordinator` help manage Google and Apple sign-ins.

```swift
let googleCredentialInfo = try await GoogleSignInHandler.signIn(rootVC: viewController)
let appleCredentialInfo = try await AppleSignInCoordinator().createAppleTokenInfo()
```

## Dependencies
`NnCredentialKit` depends on the following external libraries:

- **NnSwiftUIKit**: Provides extended UI components and utilities.
- **AuthenticationServices**: Used for Apple Sign-In.

## Contributing
Any feedback or ideas to enhance NnCredentialKit would be well received. Please feel free to [open an issue](https://github.com/nikolainobadi/NnCredentialKit/issues/new) if you'd like to help improve this swift package.

## License
`NnCredentialKit` is available under the MIT license. See the LICENSE file for more information.
