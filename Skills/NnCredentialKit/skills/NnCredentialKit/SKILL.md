---
name: NnCredentialKit
description: NnCredentialKit Swift API reference for iOS authentication workflows (sign-up, social login, account linking, reauthentication, account deletion) with Firebase integration. USE WHEN implementing Firebase auth, Apple Sign-In, Google Sign-In, account linking UI, reauthentication flows, account deletion, credential management, NnCredentialKit.
user-invocable: true
---

# NnCredentialKit

Comprehensive authentication workflows for iOS apps — email/password sign-up, Apple Sign-In, Google Sign-In, account linking, reauthentication, and account deletion with Firebase integration.

**Dependency:** `https://github.com/nikolainobadi/NnCredentialKit.git` (from: `3.3.0`)
**Platforms:** iOS 16+ | **Swift:** 6.0

## Context Files

| File | Purpose | Load When |
|------|---------|-----------|
| `CoreApi.md` | Domain models, delegate protocols, error types, accessibility IDs | Implementing delegate protocols, handling credential results, defining auth providers |
| `FeaturesApi.md` | Account linking UI, account deletion, social credential management | Building account linking views, deleting accounts, managing social credentials |
| `ProvidersApi.md` | Apple Sign-In and Google Sign-In services and credential models | Integrating Apple or Google sign-in directly, handling provider-specific credentials |

## Quick Reference

- **Delegate protocols** — Implement `AccountLinkDelegate`, `DeleteAccountDelegate`, or `ReauthenticationDelegate` to integrate with Firebase Auth
- **Account linking UI** — Use `AccountLinkSection` (SwiftUI view) or `AccountLinkViewModel` for custom UI
- **Account deletion** — Use `AccountDeleter(delegate:)` for deletion with automatic reauthentication
- **Social sign-in** — `AppleSignInService` and `GoogleSignInService` provide standalone sign-in flows
- **Reauthentication** — Automatic handling: `.reauthRequired` results trigger credential selection UI and retry
- **Debug logging** — Pass `debugEnabled: true` to any entry point to print `[NnCredentialKit]` workflow details (never logs credentials)

## Examples

**Example 1: Implement account linking UI**
```
Context: Building a settings screen with sign-in method management
-> Load FeaturesApi.md
-> Use AccountLinkSection with an AccountLinkDelegate
-> Provide a custom LinkButton view via @ViewBuilder
```

**Example 2: Implement account deletion**
```
Context: Adding a delete account button that handles reauthentication
-> Load CoreApi.md + FeaturesApi.md
-> Conform to DeleteAccountDelegate
-> Use AccountDeleter(delegate:) to handle the flow
```

**Example 3: Use social sign-in directly**
```
Context: Need Apple or Google credentials for custom auth flow
-> Load ProvidersApi.md
-> Use AppleSignInService or GoogleSignInService directly
-> Receive AppleCredentialInfo or GoogleCredentialInfo
```
