//
//  AccountLinkViewModel.swift
//
//
//  Created by Nikolai Nobadi on 8/1/24.
//

import Foundation

final class AccountLinkViewModel: ObservableObject {
    @Published var linkItems: [LinkItem] = []
    @Published var shouldReauthenticate = false
    @Published var showingEmailSignUpAlert = false
}


// MARK: - Actions
extension AccountLinkViewModel {
    func linkAction(_ item: LinkItem) async throws {
        if item.isLinked {
            try await unlinkAccount(item)
        } else {
            try await linkAccount(item)
        }
    }
}


// MARK: - Private Methods
private extension AccountLinkViewModel {
    func linkAccount(_ item: LinkItem) async throws {
        if item.isLinked {
            await showEmailAlert()
        } else {
            // TODO: - perform accountLink
        }
    }
    
    func unlinkAccount(_ item: LinkItem) async throws {
        // TODO: - perform unlink
    }
}


// MARK: - MainActor
@MainActor
private extension AccountLinkViewModel {
    func showEmailAlert() {
        showingEmailSignUpAlert = true
    }
}

struct LinkItem: Identifiable {
    let id: String

}

extension LinkItem {
    var isEmailItem: Bool {
        return false
    }
    
    var isLinked: Bool {
        return false
    }
}
