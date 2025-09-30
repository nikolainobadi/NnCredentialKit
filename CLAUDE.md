# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NnCredentialKit is a Swift Package that provides comprehensive authentication workflows for iOS apps (iOS 16+). It handles email/password sign-up, social login (Apple Sign-In, Google Sign-In), account linking, and reauthentication flows with Firebase integration.

## Architecture

### Folder Structure
The package follows a feature-based, domain-driven architecture:

```
Sources/NnCredentialKit/
├── Core/                              # Domain layer - pure business logic
│   ├── Models/                        # Domain models
│   │   ├── CredentialType.swift
│   │   ├── AuthProvider.swift
│   │   ├── AccountCredentialResult.swift
│   │   └── EmailSignUpInfo.swift
│   ├── Protocols/                     # Core protocols & delegates
│   │   ├── PublicDelegates.swift     # Public API protocols
│   │   └── InternalDelegates.swift   # Internal protocols
│   └── Errors/
│       └── CredentialError.swift
│
├── Features/                          # Feature-based organization
│   ├── Authentication/                # Core auth workflows
│   │   ├── Managers/
│   │   │   ├── CredentialManager.swift
│   │   │   ├── SocialCredentialManager.swift
│   │   │   └── ReauthenticationManager.swift
│   │   └── Services/
│   │       └── AccountDeleter.swift
│   │
│   ├── AccountLinking/                # Account linking feature
│   │   ├── ViewModels/
│   │   │   └── AccountLinkViewModel.swift
│   │   ├── Views/
│   │   │   └── AccountLinkSection.swift
│   │   ├── Configuration/
│   │   │   └── AccountLinkSectionColorsConfig.swift
│   │   └── Extensions/
│   │
│   └── Reauthentication/              # Reauthentication feature
│       ├── Alerts/
│       │   └── CredentialAlertHandler.swift
│       └── Extensions/
│
├── Providers/                         # External provider integrations
│   ├── Apple/                         # Apple Sign-In
│   │   ├── Models/
│   │   ├── Services/
│   │   └── Errors/
│   └── Google/                        # Google Sign-In
│       ├── Models/
│       └── Services/
│
└── Infrastructure/                    # Cross-cutting concerns
    ├── Extensions/
    └── Resources/
```

### Key Components

**Core Layer:**
- Domain models: `CredentialType`, `AuthProvider`, `AccountCredentialResult`
- Public protocols: `AccountLinkDelegate`, `ReauthenticationDelegate`, `DeleteAccountDelegate`
- Domain errors: `CredentialError`

**Features Layer:**
- **Authentication**: `CredentialManager`, `SocialCredentialManager`, `ReauthenticationManager`
- **Account Linking**: `AccountLinkViewModel`, `AccountLinkSection` view
- **Reauthentication**: `CredentialAlertHandler`, reauth extensions

**Providers Layer:**
- **Apple**: `AppleSignInService`, `AppleCredentialInfo`, nonce handling
- **Google**: `GoogleSignInService`, `GoogleCredentialInfo`

**Infrastructure Layer:**
- Platform extensions: `UIApplication+Extensions`
- Resources: Image assets for provider logos

### Key Patterns

**Reauthentication Flow:**
The package automatically handles Firebase's `.requiresRecentLogin` errors by:
1. Detecting when reauthentication is needed
2. Presenting appropriate credential selection UI
3. Retrying the original operation after successful reauthentication

**Delegate Protocols:**
- `AccountLinkDelegate`: For linking/unlinking providers
- `ReauthenticationDelegate`: For reauthentication operations
- `DeleteAccountDelegate`: For account deletion workflows

## Development Commands

**IMPORTANT**: This is an iOS-only package. Build and test commands should only be run when specifically requested by the user. Do not automatically run builds or tests after making changes.

### Building and Testing (iOS Only - Run Only When Requested)
```bash
# Build the package (iOS-only, will fail on macOS due to iOS dependencies)
# Only run when user explicitly asks to build
swift build

# Run tests with iOS Simulator (requires Xcode)
# Only run when user explicitly asks to test
xcodebuild -scheme NnCredentialKit -destination 'platform=iOS Simulator,name=iPhone 16' test

# Build for release
swift build -c release
```

### Running Single Tests (Only When Requested)
```bash
# Run a specific test file
swift test --filter AccountLinkViewModelTests

# Run a specific test method (use test description)
swift test --filter "Links account when provider is not linked"
```

**Note**: Due to iOS-specific dependencies (UIKit, AuthenticationServices), standard `swift build` and `swift test` commands may fail on macOS. Use Xcode or iOS Simulator for proper testing.

## Testing Architecture

### Test Framework
- Uses **Swift Testing** framework (`import Testing`, `@Test("description")`)
- **NOT XCTest** - all tests use the new Swift Testing syntax
- Tests are behavior-driven with descriptive test names

### Test Structure
- Tests use `@MainActor` when testing UI components
- `makeSUT` pattern for creating System Under Test with dependencies
- Mock objects implement the same protocols as production code
- Shared test utilities in `Tests/Shared/` directory

### Test Conventions
- Test descriptions focus on behavior, not implementation
- Use `#expect()` and `#require()` for assertions
- Async testing with `await #expect(throws:)` pattern
- Memory leak tracking when needed

### Key Test Files
- `AccountLinkViewModelTests.swift`: Tests account linking UI logic
- `CredentialManagerTests.swift`: Tests credential management workflows
- `ReauthenticatorTests.swift`: Tests reauthentication flows
- `AccountDeleterTests.swift`: Tests account deletion workflows

## Firebase Integration Notes

The package is designed to work seamlessly with Firebase Authentication:
- Automatically detects `.requiresRecentLogin` errors
- Maps them to `.reauthRequired` results
- Provides reauthentication UI flow
- Retries original operations after successful reauthentication

When implementing Firebase delegates, wrap auth operations with error handling that converts `AuthErrorCode.requiresRecentLogin` to `AccountCredentialResult.reauthRequired`.

## Dependencies

- **GoogleSignIn-iOS** (8.0.0+): For Google Sign-In functionality
- **AuthenticationServices**: For Apple Sign-In (iOS framework)
- **Swift 6.0+**: Uses modern Swift concurrency features

## CI/CD

- GitHub Actions workflow runs on `macos-14` with Xcode 16.2
- Tests run on iPhone 16 simulator
- Uses SwiftPM dependency caching
- Includes `xcpretty` for formatted output