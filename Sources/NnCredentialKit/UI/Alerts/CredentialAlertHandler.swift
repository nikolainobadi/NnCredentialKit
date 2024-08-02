//
//  File.swift
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
            showEmailPasswordAlert("", withConfirmation: true) { info in
                continuation.resume(returning: info)
            }
        }
    }
}


// MARK: - Private Methods
private extension CredentialAlertHandler {
    func showEmailPasswordAlert(_ message: String, withConfirmation: Bool, completion: @escaping (EmailSignUpInfo?) -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        Task { @MainActor in
            alertController.addTextField { textField in
                textField.configureForEmail()
            }
            
            alertController.addTextField { textField in
                textField.configureForPassword(isConfirm: false)
            }
            
            if withConfirmation {
                alertController.addTextField { textField in
                    textField.configureForPassword(isConfirm: true)
                }
            }
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                guard let email = alertController.textFields?[0].text, let password = alertController.textFields?[1].text else {
                    completion(nil)
                    return
                }
                
                if withConfirmation {
                    guard let confirmPassword = alertController.textFields?[2].text else {
                        completion(nil)
                        return
                    }
                    
                    completion(.init(email: email, password: password, confirm: confirmPassword))
                } else {
                    completion(.init(email: email, password: password, confirm: ""))
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
