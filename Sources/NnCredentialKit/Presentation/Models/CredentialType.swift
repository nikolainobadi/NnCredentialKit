//
//  CredentialType.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

public enum CredentialType {
    case apple(AppleCredentialInfo)
    case google(GoogleCredentialInfo)
    case emailPassword(email: String, password: String)
}


// MARK: - Helpers
extension CredentialType {
    init?(appleCredential: AppleCredentialInfo?) {
        guard let appleCredential else { return nil }
        
        self = .apple(appleCredential)
    }
    
    init?(googleCredential: GoogleCredentialInfo?) {
        guard let googleCredential else { return nil }
        
        self = .google(googleCredential)
    }
}
