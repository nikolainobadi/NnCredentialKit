//
//  AccountLinkViewModelTests.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

import XCTest
import NnTestHelpers
@testable import NnCredentialKit

final class AccountLinkViewModelTests: XCTestCase {
    func test_starting_values_are_empty() {
        let (sut, delegate) = makeSUT()
        
        XCTAssert(sut.providers.isEmpty)
        XCTAssertNil(delegate.providerType)
        XCTAssertNil(delegate.credentialType)
    }
}


// MARK: - SUT
extension AccountLinkViewModelTests {
    func makeSUT(credentialType: CredentialType? = nil, firstResult: AccountCredentialResult = .success, secondResult: AccountCredentialResult = .success, throwProviderError: Bool = false, throwReauthError: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> (sut: AccountLinkViewModel, delegate: MockDelegate) {
        let delegate = MockDelegate(firstResult: firstResult, secondResult: secondResult)
        let auth = MockReauthenticator(throwError: throwReauthError)
        let provider = StubProvider(credentialType: credentialType, throwError: throwProviderError)
        let sut = AccountLinkViewModel(delegate: delegate, reauthenticator: auth, credentialProvider: provider)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, delegate)
    }
}


// MARK: - Helper Classes
extension AccountLinkViewModelTests {
    class StubProvider: CredentialTypeProvider {
        private let throwError: Bool
        private let credentialType: CredentialType?
        
        init(credentialType: CredentialType?, throwError: Bool) {
            self.throwError = throwError
            self.credentialType = credentialType
        }
        
        func loadCredential(_ type: AuthProviderType) async throws -> CredentialType? {
            if throwError { throw TestError.credentialTypeProvider }
            
            return credentialType
        }
    }
    
    class MockDelegate: AccountLinkDelegate {
        private let store: StubResultStore
        private(set) var credentialType: CredentialType?
        private(set) var providerType: AuthProviderType?
        
        init(firstResult: AccountCredentialResult, secondResult: AccountCredentialResult) {
            self.store = .init(firstResult: firstResult, secondResult: secondResult)
        }
        
        func linkProvider(with type: CredentialType) async -> AccountCredentialResult {
            credentialType = type
            return store.getResult()
        }
        
        func unlinkProvider(_ type: AuthProviderType) async -> AccountCredentialResult {
            providerType = type
            return store.getResult()
        }
        
        // MARK: - Unused
        func loadLinkedProviders() -> [AuthProvider] { [] }
        func reauthenticate(with credientialType: CredentialType) async throws { }
    }
}
