# Changelog

## [Unreleased]

## [3.0.1] - 2025-01-08
### Changed
- Improved documentation in README.md

### Removed
- Package.resolved dependency lock file

## [3.0.0] - 2025-01-08
### Added
- GitHub Actions CI workflow for automated testing
- Swift 6.0 support with full concurrency compliance
- MainActor annotations for thread-safe UI operations

### Changed
- Upgraded to GoogleSignIn v8.0.0
- Migrated unit tests to Swift Testing framework
- Improved concurrency handling with Sendable conformance for delegates
- Reorganized internal file structure for better maintainability

### Removed
- MainActor annotations from some protocols for more flexible usage

## [2.1.1] - 2024-10-31
### Changed
- Reduced minimum platform requirement to iOS 16
- Lowered Swift version requirement to 5.7

## [2.1.0] - 2024-10-31
### Changed
- Updated to latest NnTestKit v1.1.0

## [2.0.1] - 2024-10-31
### Added
- New AccountLinkButtonDelegate protocol for generic LinkButton support

### Changed
- AccountLinkSection now accepts generic LinkButton views for improved error handling flexibility

### Fixed
- Access modifier on CredentialError now properly exposed

### Removed
- NnSwiftUIKit dependency - functionality refactored into the package

## [1.0.0] - 2024-10-27
### Added
- Initial release of NnCredentialKit
- Apple Sign In integration with AppleSignInCoordinator
- Google Sign In integration with GoogleSignInHandler
- AccountLinkSection SwiftUI component for authentication UI
- AccountLinkViewModel for managing authentication state
- ReauthenticationManager for secure account operations
- AccountDeleter for safe account deletion with reauthentication
- SocialCredentialManager for unified social authentication
- Comprehensive error handling with CredentialError types
- Alert handler for user-friendly error messages