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


// MARK: - LinkAccount
extension AccountLinkViewModelTests {
    func test_links_account_when_provider_is_not_linked() async {
        let provider = makeAuthProvider(.emailPassword)
        let credential = makeEmailPasswordCredential()
        let (sut, delegate) = makeSUT(credentialType: credential)
        
        await asyncAssertNoErrorThrown {
            try await sut.linkAction(provider)
        }
        
        XCTAssertNil(delegate.providerType)
        
        assertProperty(delegate.credentialType) { credentialType in
            switch credentialType {
            case .emailPassword:
                XCTAssert(true)
            default:
                XCTFail("unexpected credential type")
            }
        }
    }
    
    func test_rethrows_error_thrown_by_credential_provider() async {
        let provider = makeAuthProvider(.emailPassword)
        let (sut, delegate) = makeSUT(throwProviderError: true)
        
        await asyncAssertThrownError(expectedError: TestError.credentialTypeProvider) {
            try await sut.linkAction(provider)
        }
        
        XCTAssertNil(delegate.providerType)
        XCTAssertNil(delegate.credentialType)
    }
    
    func test_does_not_link_account_if_provider_returns_nil_credentials() async {
        let provider = makeAuthProvider(.emailPassword)
        let (sut, delegate) = makeSUT()
        
        await asyncAssertNoErrorThrown {
            try await sut.linkAction(provider)
        }
        
        XCTAssertNil(delegate.providerType)
        XCTAssertNil(delegate.credentialType)
    }

    func test_throws_error_when_reauthorization_fails() async {
        let error = TestError.reauth
        let provider = makeAuthProvider(.emailPassword)
        let credential = makeEmailPasswordCredential()
        let (sut, _) = makeSUT(credentialType: credential, firstResult: .failure(error))
        
        await asyncAssertThrownError(expectedError: error) {
            try await sut.linkAction(provider)
        }
    }
    
    func test_attempts_account_link_again_after_successful_reauthorization() async {
        let error = TestError.postReauthorizationAction
        let provider = makeAuthProvider(.emailPassword)
        let credential = makeEmailPasswordCredential()
        let (sut, _) = makeSUT(credentialType: credential, firstResult: .reauthRequired, secondResult: .failure(error))
        
        await asyncAssertThrownError(expectedError: error) {
            try await sut.linkAction(provider)
        }
    }
}


// MARK: - UnlinkAccount
extension AccountLinkViewModelTests {
    func test_unlinks_account_when_provider_is_linked() async {
        let provider = makeAuthProvider(.emailPassword, email: "tester@gmail.com")
        let secondProvider = makeAuthProvider(.apple, email: "tester@apple.com")
        let (sut, delegate) = makeSUT(providers: [provider, secondProvider])
        
        await asyncAssertNoErrorThrown {
            try await sut.linkAction(provider)
        }
        
        assertPropertyEquality(delegate.providerType, expectedProperty: provider.type)
    }
    
    func test_throws_error_when_attempting_to_unlink_with_only_one_existing_provider() async {
        
        let provider = makeAuthProvider(.emailPassword, email: "tester@gmail.com")
        let (sut, delegate) = makeSUT(providers: [provider])
        
        await asyncAssertThrownError(expectedError: CredentialError.cannotUnlinkOnlyProvider) {
            try await sut.linkAction(provider)
        }
    }
}


// MARK: - SUT
extension AccountLinkViewModelTests {
    func makeSUT(providers: [AuthProvider] = [], credentialType: CredentialType? = nil, firstResult: AccountCredentialResult = .success, secondResult: AccountCredentialResult = .success, throwProviderError: Bool = false, throwReauthError: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> (sut: AccountLinkViewModel, delegate: MockDelegate) {
        let delegate = MockDelegate(firstResult: firstResult, secondResult: secondResult)
        let auth = MockReauthenticator(throwError: throwReauthError)
        let provider = StubProvider(credentialType: credentialType, throwError: throwProviderError)
        let sut = AccountLinkViewModel(providers: providers, delegate: delegate, reauthenticator: auth, credentialProvider: provider)
        
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
