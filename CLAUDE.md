# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NnCredentialKit is a Swift Package providing authentication workflows for iOS apps (iOS 16+): email/password sign-up, Apple Sign-In, Google Sign-In, account linking, reauthentication, and account deletion with Firebase integration. For API details, consult the `NnCredentialKit` plugin skill; for test conventions, the `swift-unit-tests` skill is the authority.

## Build & Test Policy

**IMPORTANT**: This is an iOS-only package. Build and test commands should only be run when specifically requested by the user. Do not automatically run builds or tests after making changes.

`swift build` and `swift test` fail on macOS due to iOS-only dependencies (UIKit, AuthenticationServices). Use the iOS Simulator:

```bash
# Run tests (only when explicitly requested)
xcodebuild -scheme NnCredentialKit -destination 'platform=iOS Simulator,name=iPhone 16' test
```

## Firebase Integration

The package detects Firebase's `.requiresRecentLogin` errors via the `.reauthRequired` result case, presents credential selection UI, and retries the original operation after reauthentication. When implementing the delegate protocols (`AccountLinkDelegate`, `ReauthenticationDelegate`, `DeleteAccountDelegate`), wrap Firebase auth operations with error handling that converts `AuthErrorCode.requiresRecentLogin` to `AccountCredentialResult.reauthRequired`.

## CI/CD

GitHub Actions runs tests on an iPhone simulator with a pinned Xcode version (see `.github/workflows/`). Note: the test suite uses backtick raw-identifier test names, which require Swift 6.2+ to compile.
