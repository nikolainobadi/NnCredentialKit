//
//  MockReauthenticator.swift
//  NnCredentialKit
//
//  Created by Nikolai Nobadi on 4/2/25.
//

@testable import NnCredentialKit

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
