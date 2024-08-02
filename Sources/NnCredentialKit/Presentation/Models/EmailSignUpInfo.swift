//
//  EmailSignUpInfo.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

struct EmailSignUpInfo {
    let email: String
    let password: String
    let confirm: String
    
    var passwordsMatch: Bool {
        return password == confirm
    }
}
