
# NnCredentialKit

NnCredentialKit is a comprehensive Swift package designed to handle user authentication workflows, including email/password sign-up, social login (Apple, Google), and account linking. This package streamlines the process of managing credentials, reauthentication, and account deletion.

## Features

- **Account Link Section**: Easily integrate account linking for various providers, with customizable colors and accessibility support.
- **Credential Management**: Load and manage credentials for Apple, Google, and email/password logins.
- **Reauthentication Workflow**: Handle reauthentication for sensitive actions using custom alerts.
- **Social Sign-In Integration**: Seamlessly integrate Apple and Google sign-in flows with reusable components.
- **Error Handling**: Robust error handling for common authentication issues.

## Installation

To integrate `NnCredentialKit` into your project, you can use Swift Package Manager:

1. In Xcode, go to **File > Swift Packages > Add Package Dependency**.
2. Enter the repository URL.
3. Select the version or branch you want to use.

## Usage
### Account Linking

The `AccountLinkSection` view provides a way to display and manage linked accounts within your app. It supports Apple, Google, and email/password providers.

```swift
import CredentialKit

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
`CredentialKit` depends on the following external libraries:

- **NnSwiftUIKit**: Provides extended UI components and utilities.
- **AuthenticationServices**: Used for Apple Sign-In.


## Contributing
Contributions are welcome! If you have ideas for new features or improvements, feel free to open an issue or submit a pull request.


## License
`CredentialKit` is available under the MIT license. See the LICENSE file for more information.
