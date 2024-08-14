//
//  EmailSignUpInfo.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

/// A structure representing the information collected during email sign-up.
struct EmailSignUpInfo {
    /// The email address provided during sign-up.
    let email: String
    
    /// The password provided during sign-up.
    let password: String
    
    /// The confirmation of the password provided during sign-up.
    let confirm: String
    
    /// A Boolean value indicating whether the provided passwords match.
    var passwordsMatch: Bool {
        return password == confirm
    }
}
