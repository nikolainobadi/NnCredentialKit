# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NnCredentialKit is a Swift Package providing authentication workflows for iOS apps (iOS 16+): email/password sign-up, Apple Sign-In, Google Sign-In, account linking, reauthentication, and account deletion with Firebase integration. For API details, consult the `NnCredentialKit` skill in `Skills/NnCredentialKit` (see **API documentation** below); for test conventions, the `swift-unit-tests` skill is the authority.

## Build & Test Policy

**IMPORTANT**: This is an iOS-only package. Build and test commands should only be run when specifically requested by the user. Do not automatically run builds or tests after making changes.

`swift build` and `swift test` fail on macOS due to iOS-only dependencies (UIKit, AuthenticationServices). Use the iOS Simulator:

```bash
# Run tests (only when explicitly requested)
xcodebuild test -scheme NnCredentialKit-Package -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Firebase Integration

The package detects Firebase's `.requiresRecentLogin` errors via the `.reauthRequired` result case, presents credential selection UI, and retries the original operation after reauthentication. When implementing the delegate protocols (`AccountLinkDelegate`, `ReauthenticationDelegate`, `DeleteAccountDelegate`), wrap Firebase auth operations with error handling that converts `AuthErrorCode.requiresRecentLogin` to `AccountCredentialResult.reauthRequired`.

## CI/CD

GitHub Actions runs tests on an iPhone simulator with a pinned Xcode version (see `.github/workflows/`). Note: the test suite uses backtick raw-identifier test names, which require Swift 6.2+ to compile.

## API documentation lives in this repo

The published `NnCredentialKit` skill — the API reference consumers install — is checked in at
`Skills/NnCredentialKit`. It is not a copy of something maintained elsewhere; this is the source.
It is served to Claude Code by the public `nn-swift-skills` marketplace as a `git-subdir` source
pinned to a release tag.

**Any PR that changes the public API must also update `Skills/`.** The `skill-docs` workflow
enforces this: a diff touching `public`/`open`/`package` declarations under `Sources/**/*.swift`
with no file touched under `Skills/**` fails the check. Waive it with the `skip-skill-check` label
only when the API diff genuinely changes no documented behavior (a rename in a private extension
that happens to match the grep, for example).

`Skills/NnCredentialKit/.claude-plugin/plugin.json` deliberately has **no `version` field**, and one
must not be reintroduced. Git-based plugin sources are cached by commit sha, so a hand-typed version
number is unverified by anything and goes stale silently — exactly the drift this arrangement exists
to end. The version that matters is the marketplace entry's `ref`.

## Releasing

The marketplace entry for this skill is pinned to a release tag, not to `main`. Two consequences:

- **Doc changes ship on release, not on merge.** Merging a correction to `Skills/` changes nothing
  for anyone reading the skill until the next tag is pushed. This is intentional — the docs a
  consumer reads always describe a version they can actually depend on — but it surprises people who
  just merged a fix and cannot see it.
- **The pin is bumped automatically.** `.github/workflows/skill-ref-bump.yml` fires on tag push,
  rewrites `ref` in `nikolainobadi/nn-swift-skills`, and opens a PR there. If that automation is
  ever removed, the bump becomes a manual cross-repo step — and an unbumped `ref` serves the
  previous release's docs forever, with nothing erroring and nothing warning.

The bump workflow authenticates with the `MARKETPLACE_TOKEN` repo secret: a fine-grained PAT named
`nn-swift-skills-ref-bump`, granting only `contents:write` and `pull-requests:write` on the
marketplace repo. **It is shared across every package repo that publishes a skill**, so when it
expires or is revoked the bump breaks in all of them at once and each needs the secret set again —
a failed bump run reading `Bad credentials` means *rotate the shared token*, not *this repo's
workflow is broken*. Its expiry is visible under GitHub → Settings → Developer settings →
Fine-grained tokens; the value itself cannot be read back from any repo once set.
