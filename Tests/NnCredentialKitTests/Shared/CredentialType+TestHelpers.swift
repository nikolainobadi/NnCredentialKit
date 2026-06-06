//
//  CredentialType+TestHelpers.swift
//  NnCredentialKit
//
//  Created by Nikolai Nobadi on 6/6/26.
//

@testable import NnCredentialKit

extension CredentialType {
    var id: String {
        switch self {
        case .apple:
            return "apple"
        case .google:
            return "google"
        case .emailPassword:
            return "emailPassword"
        }
    }
}
