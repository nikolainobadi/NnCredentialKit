//
//  CredentialType.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

import Foundation

/// An enum representing the different types of credentials used for authentication.
public enum CredentialType {
    case apple(AppleCredentialInfo)
    case google(GoogleCredentialInfo)
    case emailPassword(email: String, password: String)
}


// MARK: - Helpers
extension CredentialType {
    /// Initializes the enum with an optional Apple credential.
    /// - Parameter appleCredential: The Apple credential to use, if available.
    init?(appleCredential: AppleCredentialInfo?) {
        guard let appleCredential = appleCredential else { return nil }
        self = .apple(appleCredential)
    }
    
    /// Initializes the enum with an optional Google credential.
    /// - Parameter googleCredential: The Google credential to use, if available.
    init?(googleCredential: GoogleCredentialInfo?) {
        guard let googleCredential = googleCredential else { return nil }
        self = .google(googleCredential)
    }
}
