//
//  CredentialAlertHandler.swift
//  
//
//  Created by Nikolai Nobadi on 8/2/24.
//

import UIKit
import NnSwiftUIKit

final class CredentialAlertHandler { }

@MainActor
extension CredentialAlertHandler {
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
}


// MARK: - Private Methods
private extension CredentialAlertHandler {
    func showPasswordAlert(_ message: String, completion: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: "Re-Authenticate", message: message, preferredStyle: .alert)
        
        Task { @MainActor in
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
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        Task { @MainActor in
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


// MARK: - Dependencies
struct EmailSignUpInfo {
    let email: String
    let password: String
    let confirm: String
    
    var passwordsMatch: Bool {
        return password == confirm
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
