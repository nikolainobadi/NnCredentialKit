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
