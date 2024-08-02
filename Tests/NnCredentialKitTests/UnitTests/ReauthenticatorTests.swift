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
    
    func test_cancelled_error_is_thrown_when_reauthentication_is_refused() async {
        let linkedProviders = makeLinkedProviders()
        let sut = makeSUT(linkedProviders: linkedProviders).sut
        
        await asyncAssertThrownError(expectedError: CredentialError.cancelled) {
            try await sut.start(actionAfterReauth: { })
        }
    }
    
    func test_selected_credential_is_used_to_reauthenticate() async {
        let linkedProviders = makeLinkedProviders()
        let selectedCredential = makeEmailPasswordCredential()
        let (sut, delegate) = makeSUT(linkedProviders: linkedProviders, credentialType: selectedCredential)
        
        await asyncAssertNoErrorThrown {
            try await sut.start(actionAfterReauth: { })
        }
        
        XCTAssertNotNil(delegate.credentialType)
    }
    
    func test_action_is_performed_after_successful_reauthentication() async {
        let exp = expectation(description: "waiting for reauth")
        
        let linkedProviders = makeLinkedProviders()
        let selectedCredential = makeEmailPasswordCredential()
        let (sut, _) = makeSUT(linkedProviders: linkedProviders, credentialType: selectedCredential)
        
        await asyncAssertNoErrorThrown {
            try await sut.start {
                exp.fulfill()
            }
        }
        
        await fulfillment(of: [exp], timeout: 0.1)
    }
    
    func test_action_is_not_performed_when_reauthentication_failes() async {
        let exp = expectation(description: "waiting for reauth")
        
        exp.isInverted = true
        
        let linkedProviders = makeLinkedProviders()
        let selectedCredential = makeEmailPasswordCredential()
        let (sut, _) = makeSUT(linkedProviders: linkedProviders, credentialType: selectedCredential, throwDelegateError: true)
        
        try? await sut.start {
            XCTFail("unexpeted completion call")
        }
        
        await fulfillment(of: [exp], timeout: 0.1)
    }
}


// MARK: - SUT
extension ReauthenticatorTests {
    func makeSUT(linkedProviders: [AuthProvider] = [], credentialType: CredentialType? = nil, throwDelegateError: Bool = false, throwProviderError: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> (sut: ReauthenticationAdapter, delegate: MockDelegate) {
        let delegate = MockDelegate(throwError: throwDelegateError, linkedProviders: linkedProviders)
        let provider = StubProvider(throwError: throwProviderError, credentialType: credentialType)
        let sut = ReauthenticationAdapter(delegate: delegate, credentialProvider: provider)
        
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
