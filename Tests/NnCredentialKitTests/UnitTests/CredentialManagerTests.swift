//
//  CredentialManagerTests.swift
//
//
//  Created by Nikolai Nobadi on 8/3/24.
//

import XCTest
import NnTestHelpers
@testable import NnCredentialKit

final class CredentialManagerTests: XCTestCase {
    
}


// MARK: - SUT
extension CredentialManagerTests {
    func makeSUT(info: EmailSignUpInfo? = nil, password: String? = nil, authResult: Result<AuthProvider?, CredentialError> = .success(nil), appleCredential: AppleCredentialInfo?, googleCredential: GoogleCredentialInfo?, throwProviderError: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> CredentialManager {
        let alerts = StubAlerts(info: info, password: password, authResult: authResult)
        let provider = StubProvider(throwError: throwProviderError, appleCredential: appleCredential, googleCredential: googleCredential)
        let sut = CredentialManager(alertHandler: alerts, socialCredentialProvider: provider)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}


// MARK: - Helper Classes
extension CredentialManagerTests {
    class StubAlerts: CredentialAlerts {
        private let info: EmailSignUpInfo?
        private let password: String?
        private let authResult: Result<AuthProvider?, CredentialError>
        
        init(info: EmailSignUpInfo?, password: String?, authResult: Result<AuthProvider?, CredentialError>) {
            self.info = info
            self.password = password
            self.authResult = authResult
        }
        
        func loadEmailSignUpInfo() async -> EmailSignUpInfo? {
            return info
        }
        
        func loadPassword(_ message: String) async -> String? {
            return password
        }
        
        func showReauthenticationAlert(providers: [AuthProvider], completion: @escaping (Result<AuthProvider?, CredentialError>) -> Void) {
            completion(authResult)
        }
    }
    class StubProvider: SocialCredentialProvider {
        private let throwError: Bool
        private let appleCredential: AppleCredentialInfo?
        private let googleCredential: GoogleCredentialInfo?
        
        init(throwError: Bool, appleCredential: AppleCredentialInfo?, googleCredential: GoogleCredentialInfo?) {
            self.throwError = throwError
            self.appleCredential = appleCredential
            self.googleCredential = googleCredential
        }
        
        func loadAppleCredential() async throws -> AppleCredentialInfo? {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            return appleCredential
        }
        
        func loadGoogleCredential() async throws -> GoogleCredentialInfo? {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            return googleCredential
        }
    }
}
