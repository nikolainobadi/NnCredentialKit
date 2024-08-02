//
//  AccountDeleterTests.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

import XCTest
import NnTestHelpers
@testable import NnCredentialKit

final class AccountDeleterTests: XCTestCase {
    func test_error_is_thrown_when_delete_account_fails() async {
        let error = TestError.network
        let sut = makeSUT(firstResult: .failure(error))
        
        await asyncAssertThrownError(expectedError: error, action: sut.deleteAccount)
    }
    
    func test_reauthenticates_when_required() async {
        let sut = makeSUT(firstResult: .reauthRequired)
        
        await asyncAssertNoErrorThrown(action: sut.deleteAccount)
    }
    
    func test_attempts_delete_account_after_successful_reauthentication() async {
        let error = TestError.secondDeleteAccountAttempt
        let sut = makeSUT(firstResult: .reauthRequired, secondResult: .failure(error))
        
        await asyncAssertThrownError(expectedError: error, action: sut.deleteAccount)
    }
    
    func test_does_not_attempt_delete_account_when_reauthentication_fails() async {
        let sut = makeSUT(firstResult: .reauthRequired, secondResult: .failure(TestError.network), throwReauthError: true)
        
        await asyncAssertThrownError(expectedError: TestError.reauth, action: sut.deleteAccount)
    }
}


// MARK: - SUT
extension AccountDeleterTests {
    func makeSUT(firstResult: AccountCredentialResult = .success, secondResult: AccountCredentialResult = .success, throwReauthError: Bool = false, file: StaticString = #filePath, line: UInt = #line) -> AccountDeleter {
        let delegate = StubDelegate(firstResult: firstResult, secondResult: secondResult)
        let auth = MockReauthenticator(throwError: throwReauthError)
        let sut = AccountDeleter(delegate: delegate, reauthenticator: auth)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}


// MARK: - Helper Classes
extension AccountDeleterTests {
    class StubDelegate: DeleteAccountDelegate {
        private let store: StubResultStore
        
        init(firstResult: AccountCredentialResult, secondResult: AccountCredentialResult) {
            self.store = .init(firstResult: firstResult, secondResult: secondResult)
        }
        
        func deleteAccount() async -> AccountCredentialResult {
            return store.getResult()
        }

        // MARK: - Unused
        func loadLinkedProviders() -> [AuthProvider] { [] }
        func reauthenticate(with credientialType: CredentialType) async throws { }
    }
}

final class MockReauthenticator: Reauthenticator {
    private let throwError: Bool
    
    init(throwError: Bool) {
        self.throwError = throwError
    }
    
    func start(actionAfterReauth: @escaping () async throws -> Void) async throws {
        if throwError { throw TestError.reauth }
        
        try await actionAfterReauth()
    }
}
