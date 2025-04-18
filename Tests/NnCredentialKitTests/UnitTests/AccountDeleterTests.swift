//
//  AccountDeleterTests.swift
//
//
//  Created by Nikolai Nobadi on 8/2/24.
//

import Testing
@testable import NnCredentialKit

@MainActor
struct AccountDeleterTests {
    @Test("Throws error when delete account fails")
    func throwsErrorOnDeleteAccountFail() async throws {
        let error = TestError.network
        let sut = makeSUT(firstResult: .failure(error))

        await #expect(throws: TestError.network) {
            try await sut.deleteAccount()
        }
    }

    @Test("Throws error after successful reauthentication attempt")
    func throwsErrorAfterSuccessfulReauth() async throws {
        let error = TestError.postReauthorizationAction
        let sut = makeSUT(firstResult: .reauthRequired, secondResult: .failure(error))

        await #expect(throws: TestError.postReauthorizationAction) {
            try await sut.deleteAccount()
        }
    }

    @Test("Throws error when reauthentication fails")
    func throwsErrorWhenReauthenticationFails() async throws {
        let sut = makeSUT(firstResult: .reauthRequired, secondResult: .failure(TestError.network), throwReauthError: true)

        await #expect(throws: TestError.reauth) {
            try await sut.deleteAccount()
        }
    }
}


// MARK: - SUT
private extension AccountDeleterTests {
    func makeSUT(firstResult: AccountCredentialResult = .success, secondResult: AccountCredentialResult = .success, throwReauthError: Bool = false) -> AccountDeleter {
        let delegate = StubDelegate(firstResult: firstResult, secondResult: secondResult)
        let auth = MockReauthenticator(throwError: throwReauthError)
        
        return AccountDeleter(delegate: delegate, reauthenticator: auth)
    }
}


// MARK: - Helper Classes
private extension AccountDeleterTests {
    final class StubDelegate: DeleteAccountDelegate, @unchecked Sendable {
        private let store: StubResultStore

        init(firstResult: AccountCredentialResult, secondResult: AccountCredentialResult) {
            self.store = StubResultStore(firstResult: firstResult, secondResult: secondResult)
        }

        func deleteAccount() async -> AccountCredentialResult {
            store.getResult()
        }

        func loadLinkedProviders() -> [AuthProvider] { [] }

        func reauthenticate(with credientialType: CredentialType) async throws { }
    }
}
