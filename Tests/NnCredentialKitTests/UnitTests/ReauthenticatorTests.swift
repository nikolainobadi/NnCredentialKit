//
//  ReauthenticatorTests.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

import XCTest
import NnTestHelpers
@testable import NnCredentialKit

final class ReauthenticatorTests: XCTestCase {
    func test_starting_values_are_empty() {
        let (_, delegate) = makeSUT()
        
        XCTAssertNil(delegate.credentialType)
    }
    
    func test_error_is_thrown_when_no_linked_providers_exist() async {
        let sut = makeSUT().sut
        
        await asyncAssertThrownError(expectedError: CredentialError.emptyAuthProviders) {
            try await sut.start(actionAfterReauth: { })
        }
    }
}


// MARK: - SUT
extension ReauthenticatorTests {
    func makeSUT(linkedProviders: [AuthProvider] = [], credentialType: CredentialType? = nil, throwError: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> (sut: Reauthenticator, delegate: MockDelegate) {
        let delegate = MockDelegate(throwError: throwError, linkedProviders: linkedProviders)
        let provider = StubProvider(throwError: throwError, credentialType: credentialType)
        let sut = Reauthenticator(delegate: delegate, credentialProvider: provider)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, delegate)
    }
}


// MARK: - Helper Classes
extension ReauthenticatorTests {
    class MockDelegate: ReauthenticationDelegate {
        private let throwError: Bool
        private let linkedProviders: [AuthProvider]
        private(set) var credentialType: CredentialType?
        
        init(throwError: Bool, linkedProviders: [AuthProvider]) {
            self.throwError = throwError
            self.linkedProviders = linkedProviders
        }
        
        func loadLinkedProviders() -> [AuthProvider] {
            return linkedProviders
        }
        
        func reauthenticate(with credientialType: CredentialType) async throws {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            self.credentialType = credientialType
        }
    }
    
    class StubProvider: CredentialReauthenticationProvider {
        private let throwError: Bool
        private let credentialType: CredentialType?
        
        
        init(throwError: Bool, credentialType: CredentialType?) {
            self.throwError = throwError
            self.credentialType = credentialType
        }
        
        func loadReauthCredential(linkedProviders: [AuthProvider]) async throws -> CredentialType? {
            if throwError { throw NSError(domain: "Test", code: 0) }
            
            return credentialType
        }
    }
}
