//
//  CredentialManagerTests.swift
//
//
//  Created by Nikolai Nobadi on 8/3/24.
//

import XCTest
import NnTestHelpers
@testable import NnCredentialKit

final class CredentialManagerTests: XCTestCase { }


// MARK: - CredentialTypeProvider Tests
extension CredentialManagerTests {
    func test_returns_nil_when_user_cancels_sign_in() async {
        for providerType in AuthProviderType.allCases {
            let sut = makeSUT()
            
            await asyncAssertNoErrorThrown {
                let result = try await sut.loadCredential(providerType)
                
                XCTAssertNil(result)
            }
        }
    }
    
    func test_loads_apple_credential_for_apple_auth_type_provider() async {
        let credential = makeAppleCredential()
        let sut = makeSUT(appleCredential: credential)
        
        await asyncAssertNoErrorThrown {
            let result = try await sut.loadCredential(.apple)
            
            switch result {
            case .apple:
               break
            default:
                XCTFail("unexpected credential")
            }
        }
    }
    
    func test_loads_google_credential_for_google_auth_type_provider() async {
        let credential = makeGoogleCredential()
        let sut = makeSUT(googleCredential: credential)
        
        await asyncAssertNoErrorThrown {
            let result = try await sut.loadCredential(.google)
            
            switch result {
            case .google:
               break
            default:
                XCTFail("unexpected credential")
            }
        }
    }
    
    func test_loads_email_password_credential_for_email_password_auth_type_provider() async {
        let info = makeEmailInfo()
        let sut = makeSUT(info: info)
        
        await asyncAssertNoErrorThrown {
            let result = try await sut.loadCredential(.emailPassword)
            
            switch result {
            case .emailPassword:
               break
            default:
                XCTFail("unexpected credential")
            }
        }
    }
    
    func test_throws_error_for_email_credential_when_passwords_do_not_match() async {
        let info = makeEmailInfo(password: "tester", confirm: "123456")
        let sut = makeSUT(info: info)
        
        await asyncAssertThrownError(expectedError: CredentialError.passwordsMustMatch) {
            let _ = try await sut.loadCredential(.emailPassword)
        }
    }
}


// MARK: - CredentialReauthenticationProvider Tests
extension CredentialManagerTests {
    func test_returns_nil_reauthentication_credential_when_user_cancels() async {
        let linkedProviders = makeLinkedProviders()
        for providerType in AuthProviderType.allCases {
            let sut = makeSUT(selectedProvider: .init(linkedEmail: "", type: providerType))
            
            await asyncAssertNoErrorThrown {
                let result = try await sut.loadReauthCredential(linkedProviders: linkedProviders)
                
                XCTAssertNil(result)
            }
        }
    }
    
    func test_throws_error_during_reauthentication_if_no_linked_providers_exist() async {
        let sut = makeSUT()
        
        await asyncAssertThrownError(expectedError: CredentialError.emptyAuthProviders) {
            let _ = try await sut.loadReauthCredential(linkedProviders: [])
        }
    }
    
    func test_loads_apple_credential_for_reauthentication_when_apple_auth_type_provider_is_selected() async {
        let credential = makeAppleCredential()
        let linkedProviders = makeLinkedProviders()
        let selectedProvider = makeAuthProvider(.apple)
        let sut = makeSUT(selectedProvider: selectedProvider, appleCredential: credential)
        
        await asyncAssertNoErrorThrown {
            let result = try await sut.loadReauthCredential(linkedProviders: linkedProviders)
            
            switch result {
            case .apple:
               break
            default:
                XCTFail("unexpected credential")
            }
        }
    }
    
    func test_loads_google_credential_for_reauthentication_when_google_auth_type_provider_is_selected() async {
        let credential = makeGoogleCredential()
        let linkedProviders = makeLinkedProviders()
        let selectedProvider = makeAuthProvider(.google)
        let sut = makeSUT(selectedProvider: selectedProvider, googleCredential: credential)
        
        await asyncAssertNoErrorThrown {
            let result = try await sut.loadReauthCredential(linkedProviders: linkedProviders)
            
            switch result {
            case .google:
               break
            default:
                XCTFail("unexpected credential")
            }
        }
    }
    
    func test_loads_email_password_credential_for_reauthentication_when_email_password_auth_type_provider_is_selected() async {
        let linkedProviders = makeLinkedProviders()
        let selectedProvider = makeAuthProvider(.emailPassword)
        let sut = makeSUT(password: "tester", selectedProvider: selectedProvider)
        
        await asyncAssertNoErrorThrown {
            let result = try await sut.loadReauthCredential(linkedProviders: linkedProviders)
            
            switch result {
            case .emailPassword:
               break
            default:
                XCTFail("unexpected credential")
            }
        }
    }
}


// MARK: - SUT
extension CredentialManagerTests {
    func makeSUT(info: EmailSignUpInfo? = nil, password: String? = nil, selectedProvider: AuthProvider? = nil, appleCredential: AppleCredentialInfo? = nil, googleCredential: GoogleCredentialInfo? = nil, throwProviderError: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> CredentialManager {
        let alerts = StubAlerts(info: info, password: password, selectedProvider: selectedProvider)
        let provider = StubProvider(throwError: throwProviderError, appleCredential: appleCredential, googleCredential: googleCredential)
        let sut = CredentialManager(alertHandler: alerts, socialCredentialProvider: provider)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    func makeAppleCredential() -> AppleCredentialInfo {
        return .init(email: "", displayName: "", idTokenString: "", nonce: "")
    }
    
    func makeGoogleCredential() -> GoogleCredentialInfo {
        return .init(email: "", displayName: "", tokenId: "", accessTokenId: "")
    }
    
    func makeEmailInfo(email: String = "tester@gmail.com", password: String = "tester", confirm: String? = nil) -> EmailSignUpInfo {
        return .init(email: email, password: password, confirm: confirm ?? password)
    }
}


// MARK: - Helper Classes
extension CredentialManagerTests {
    class StubAlerts: CredentialAlerts {
        private let info: EmailSignUpInfo?
        private let password: String?
        private let selectedProvider: AuthProvider?
        
        init(info: EmailSignUpInfo?, password: String?, selectedProvider: AuthProvider?) {
            self.info = info
            self.password = password
            self.selectedProvider = selectedProvider
        }
        
        func loadEmailSignUpInfo() async -> EmailSignUpInfo? {
            return info
        }
        
        func loadPassword(_ message: String) async -> String? {
            return password
        }
        
        func showReauthenticationAlert(providers: [AuthProvider], completion: @escaping (AuthProvider?) -> Void) {
            completion(selectedProvider)
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
