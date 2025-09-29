# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NnCredentialKit is a Swift Package that provides comprehensive authentication workflows for iOS apps (iOS 16+). It handles email/password sign-up, social login (Apple Sign-In, Google Sign-In), account linking, and reauthentication flows with Firebase integration.

## Architecture

### Core Structure
- **Two main targets**: `NnCredentialKit` (main library) and `NnCredentialKitAccessibility` (accessibility identifiers)
- **Layered architecture**: UI → Presentation → Domain → External services
- **Delegate pattern**: Uses protocol-based delegates for extensibility and testability

### Key Components

**Presentation Layer:**
- `SocialCredentialManager`: Handles Apple and Google sign-in flows
- `CredentialManager`: Main coordinator for credential operations
- `ReauthenticationManager`: Manages reauthentication workflows
- `AccountDeleter`: Handles account deletion with reauthentication
- `AccountLinkViewModel`: SwiftUI ViewModel for account linking UI

**Domain Models:**
- `AccountCredentialResult`: Result enum with `.success`, `.reauthRequired`, `.failure(Error)`
- `CredentialType`: Enum for Apple, Google, and email/password credentials
- `AuthProvider`: Represents authentication providers with linked status

**UI Components:**
- `AccountLinkSection`: SwiftUI view for displaying and managing linked accounts
- `CredentialAlertHandler`: Handles reauthentication alerts

**External Integration:**
- `GoogleSignInHandler`: Wrapper for Google Sign-In SDK
- `AppleSignInCoordinator`: Coordinates Apple Sign-In flow
- Firebase-aware error handling for `.requiresRecentLogin` scenarios

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

### Building and Testing
```bash
# Build the package
swift build

# Run all tests
swift test

# Run tests with iOS Simulator (from Xcode)
xcodebuild -scheme NnCredentialKit -destination 'platform=iOS Simulator,name=iPhone 16' test

# Build for iOS target
swift build -c release
```

### Running Single Tests
```bash
# Run a specific test file
swift test --filter AccountLinkViewModelTests

# Run a specific test method (use test description)
swift test --filter "Links account when provider is not linked"
```

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