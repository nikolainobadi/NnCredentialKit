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
        self._viewModel = .init(wrappedValue: .init(delegate: delegate, credentialProvider: CredentialTypeProviderAdapter()))
    }
    
    public var body: some View {
        Section("Sign-in Methods") {
            ForEach(viewModel.providers) { provider in
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
        func linkProvider(with: CredentialType) async throws { }
        func unlinkProvider(_ type: AuthProviderType) async throws { }
        func reauthenticate(with credientialType: CredentialType) async throws { }
    }
    
    return AccountLinkSection(delegate: PreviewDelegate())
}
