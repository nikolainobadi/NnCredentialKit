//
//  CredentialAlertHandler.swift
//  
//
//  Created by Nikolai Nobadi on 8/2/24.
//

import UIKit
import NnCredentialKitAccessibility

/// A class responsible for handling credential-related alerts.
final class CredentialAlertHandler {
    /// Retrieves the top-most view controller in the current view hierarchy.
    /// - Returns: The top-most `UIViewController` if available, otherwise `nil`.
    @MainActor
    func getTopVC() -> UIViewController? {
        return UIApplication.shared.getTopViewController()
    }
}


// MARK: - Alerts
extension CredentialAlertHandler: CredentialAlerts {
    /// Shows an alert to collect email and password information for signing up.
    /// - Returns: The collected `EmailSignUpInfo` or `nil` if the user cancels.
    func loadEmailSignUpInfo() async -> EmailSignUpInfo? {
        return await withCheckedContinuation { continuation in
            showEmailPasswordAlert("Please enter your new email and password.") { info in
                continuation.resume(returning: info)
            }
        }
    }

    /// Shows an alert to collect a password.
    /// - Parameter message: The message to display in the alert.
    /// - Returns: The collected password as a `String` or `nil` if the user cancels.
    func loadPassword(_ message: String) async -> String? {
        return await withCheckedContinuation { continuation in
            showPasswordAlert(message) { password in
                continuation.resume(returning: password)
            }
        }
    }

    /// Shows a reauthentication alert for the user to reauthenticate with a specific provider.
    /// - Parameters:
    ///   - providers: A list of authentication providers to choose from.
    ///   - completion: A completion handler with the selected provider or `nil` if the user cancels.
    func showReauthenticationAlert(providers: [AuthProvider], completion: @escaping (AuthProvider?) -> Void) {
        Task { @MainActor in
            // Ensure that providers are not empty.
            let hasMultipleProviders = providers.count > 1
            let message = hasMultipleProviders ? "" : "This is a sensitive action. In order to proceed, you must reauthenticate your account."
            let alertController = UIAlertController(title: "Re-Authenticate", message: message, preferredStyle: .alert)

            if hasMultipleProviders {
                for provider in providers {
                    let action = UIAlertAction(title: provider.name, style: .default) { _ in
                        completion(provider)
                    }
                    alertController.addAction(action)
                }
            } else {
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    completion(providers.first)
                }
                alertController.addAction(okAction)
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completion(nil)
            }
            alertController.addAction(cancelAction)
            alertController.presentInMainThread()
        }
    }
}


// MARK: - Private Methods
private extension CredentialAlertHandler {
    /// Shows an alert to collect a password.
    /// - Parameters:
    ///   - message: The message to display in the alert.
    ///   - completion: A completion handler with the collected password or `nil` if the user cancels.
    func showPasswordAlert(_ message: String, completion: @escaping (String?) -> Void) {
        Task { @MainActor in
            let alertController = UIAlertController(title: "Re-Authenticate", message: message, preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.configureForPassword(isConfirm: false, accessId: .reauthPasswordField)
            }
            alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                guard let password = alertController.textFields?[0].text, !password.isEmpty else {
                    completion(nil)
                    return
                }
                completion(password)
            })
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completion(nil)
            })
            alertController.presentInMainThread()
        }
    }

    /// Shows an alert to collect email and password information for sign-up.
    /// - Parameters:
    ///   - message: The message to display in the alert.
    ///   - completion: A completion handler with the collected `EmailSignUpInfo` or `nil` if the user cancels.
    func showEmailPasswordAlert(_ message: String, completion: @escaping (EmailSignUpInfo?) -> Void) {
        Task { @MainActor in
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.configureForEmail()
            }
            alertController.addTextField { textField in
                textField.configureForPassword(isConfirm: false, accessId: .passwordField)
            }
            alertController.addTextField { textField in
                textField.configureForPassword(isConfirm: true, accessId: .confirmField)
            }
            alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                if let email = alertController.textFields?[0].text,
                   let password = alertController.textFields?[1].text,
                   let confirmPassword = alertController.textFields?[2].text {
                    completion(.init(email: email, password: password, confirm: confirmPassword))
                } else {
                    completion(nil)
                }
            })
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completion(nil)
            })
            alertController.presentInMainThread()
        }
    }
}


// MARK: - Extension Dependencies
fileprivate extension UITextField {
    /// Configures the text field for email input.
    func configureForEmail() {
        placeholder = "Email"
        keyboardType = .emailAddress
        autocorrectionType = .no
        autocapitalizationType = .none
        accessibilityIdentifier = CredentialKitAccessibilityId.emailField.rawValue
    }
    
    /// Configures the text field for password input.
    /// - Parameters:
    ///   - isConfirm: A Boolean value indicating whether the text field is for confirming a password.
    ///   - accessId: The accessibility identifier to use.
    func configureForPassword(isConfirm: Bool, accessId: CredentialKitAccessibilityId) {
        placeholder = "\(isConfirm ? "Confirm " : "")Password"
        autocorrectionType = .no
        autocapitalizationType = .none
        accessibilityIdentifier = accessId.rawValue
    }
}

@MainActor
fileprivate extension UIAlertController {
    /// Presents the alert controller on the main thread.
    /// - Parameters:
    ///   - animated: A Boolean value indicating whether the presentation is animated.
    ///   - completion: A completion handler to execute after the presentation finishes.
    func presentInMainThread(animated: Bool = true, completion: (() -> Void)? = nil) {
        if var topController = UIApplication.shared.getTopViewController() {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(self, animated: animated, completion: completion)
        }
    }
}
