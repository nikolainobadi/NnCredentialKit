//
//  AccountLinkSection.swift
//  
//
//  Created by Nikolai Nobadi on 8/1/24.
//

import SwiftUI
import NnSwiftUIKit

public struct AccountLinkSection: View {
    @StateObject var viewModel: AccountLinkViewModel
    
    public init(delegate: AccountLinkDelegate) {
        self._viewModel = .init(wrappedValue: .customInit(delegate))
    }
    
    public var body: some View {
        Section("Sign-in Methods") {
            ForEach(viewModel.providers, id: \.name) { provider in
                LinkRow(provider: provider) {
                    try await viewModel.linkAction(provider)
                }
            }
        }
    }
}


// MARK: - Row
fileprivate struct LinkRow: View {
    let provider: AuthProvider
    let linkAction: () async throws -> Void
    
    var body: some View {
        HStack {
            VStack {
                Text(provider.name)
                    .font(.title3)
//                    .foregroundColor(config.titleColor)
                
                Text(provider.linkedEmail)
//                    .foregroundColor(config.emailColor)
                    .nnOnlyShow(when: !provider.linkedEmail.isEmpty)
            }
            
            NnAsyncTryButton(action: linkAction) {
                Text(provider.isLinked ? "Unlink" : "Link")
                    .underline()
            }
        }
    }
}


// MARK: - Preview
#Preview {
    class PreviewDelegate: AccountLinkDelegate {
        func loadLinkedProviders() -> [AuthProvider] { [] }
        func reauthenticate(with credientialType: CredentialType) async throws { }
        func linkProvider(with: CredentialType) async -> AccountCredentialResult { .success }
        func unlinkProvider(_ type: AuthProviderType) async -> AccountCredentialResult { .success }
    }
    
    return AccountLinkSection(delegate: PreviewDelegate())
}


// MARK: - Extension Dependencies
fileprivate extension AccountLinkViewModel {
    static func customInit(_ delegate: AccountLinkDelegate) -> AccountLinkViewModel {
        let credentialProvider = CredentialTypeProviderAdapter()
        let reauthenticator = Reauthenticator(delegate: delegate, credentialProvider: credentialProvider)
        
        return .init(delegate: delegate, reauthenticator: reauthenticator, credentialProvider: credentialProvider)
    }
}
