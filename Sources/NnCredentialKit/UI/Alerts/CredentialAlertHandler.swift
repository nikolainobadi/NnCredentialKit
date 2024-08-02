//
//  CredentialAlertHandler.swift
//  
//
//  Created by Nikolai Nobadi on 8/2/24.
//

import UIKit
import NnSwiftUIKit

final class CredentialAlertHandler {
    @MainActor
    func getTopVC() -> UIViewController? {
        return UIApplication.shared.getTopViewController()
    }
}


// MARK: - Alerts
extension CredentialAlertHandler {
    func loadEmailSignUpInfo() async -> EmailSignUpInfo? {
        return await withCheckedContinuation { continuation in
            showEmailPasswordAlert("Please enter your new email and password.") { info in
                continuation.resume(returning: info)
            }
        }
    }
    
    func loadPassword(_ message: String) async -> String? {
        return await withCheckedContinuation { continuation in
            showPasswordAlert(message) { password in
                continuation.resume(returning: password)
            }
        }
    }
    
    func showReauthenticationAlert(providers: [AuthProvider], completion: @escaping (Result<AuthProvider?, CredentialError>) -> Void) {
        
        Task { @MainActor in
            /// providers should NOT be empty as it should be checked before passing into this method
            let hasMultipleProviders = providers.count > 1
            let message = hasMultipleProviders ? "" : "This is a sensitive action. In order to proceed, you must reauthenticate your account."
            let alertController = UIAlertController(title: "Re-Authenticate", message: message, preferredStyle: .alert)
            
            if hasMultipleProviders {
                for provider in providers {
                    let action = UIAlertAction(title: provider.name, style: .default) { _ in
                        completion(.success(provider))
                    }
                    
                    alertController.addAction(action)
                }
            } else {
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    completion(.success(providers.first))
                }
                
                alertController.addAction(okAction)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completion(.success(nil))
            }
            
            alertController.addAction(cancelAction)
            alertController.presentInMainThread()
        }
    }
}


// MARK: - Private Methods
private extension CredentialAlertHandler {
    func showPasswordAlert(_ message: String, completion: @escaping (String?) -> Void) {
        Task { @MainActor in
            let alertController = UIAlertController(title: "Re-Authenticate", message: message, preferredStyle: .alert)
            
            alertController.addTextField { textField in
                textField.configureForPassword(isConfirm: false)
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
    
    func showEmailPasswordAlert(_ message: String, completion: @escaping (EmailSignUpInfo?) -> Void) {
        Task { @MainActor in
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            
            alertController.addTextField { textField in
                textField.configureForEmail()
            }
            
            alertController.addTextField { textField in
                textField.configureForPassword(isConfirm: false)
            }
            
            alertController.addTextField { textField in
                textField.configureForPassword(isConfirm: true)
            }
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                if let email = alertController.textFields?[0].text, let password = alertController.textFields?[1].text, let confirmPassword = alertController.textFields?[2].text {
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
    func configureForEmail() {
        placeholder = "Email"
        keyboardType = .emailAddress
        autocorrectionType = .no
        autocapitalizationType = .none
        // TODO: - add accessibilityId
    }

    func configureForPassword(isConfirm: Bool) {
        placeholder = "\(isConfirm ? "Confirm " : "")Password"
        isSecureTextEntry = true
        autocorrectionType = .no
        autocapitalizationType = .none
        // TODO: - add accessibilityId
    }
}

@MainActor
fileprivate extension UIAlertController {
    func presentInMainThread(animated: Bool = true, completion: (() -> Void)? = nil) {
        if var topController = UIApplication.shared.getTopViewController() {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.present(self, animated: animated, completion: completion)
        }
    }
}
