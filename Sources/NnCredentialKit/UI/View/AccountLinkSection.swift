//
//  AccountLinkSection.swift
//  
//
//  Created by Nikolai Nobadi on 8/1/24.
//

import SwiftUI
import NnSwiftUIKit
import AuthenticationServices
import NnCredentialKitAccessibility

/// A view that displays a section for managing account link/unlink operations.
public struct AccountLinkSection: View {
    @StateObject var viewModel: AccountLinkViewModel
    
    /// The configuration for customizing the colors in the section.
    let config: AccountLinkSectionColorsConfig
    
    /// Initializes the section with the specified configuration, delegate, and Apple sign-in scopes.
    /// - Parameters:
    ///   - config: The color configuration for the section.
    ///   - delegate: The delegate responsible for handling account link actions.
    ///   - appleSignInScopes: The scopes to request during Apple Sign-In.
    public init(config: AccountLinkSectionColorsConfig, delegate: AccountLinkDelegate, appleSignInScopes: [ASAuthorization.Scope]) {
        self.config = config
        self._viewModel = .init(wrappedValue: .init(delegate: delegate, appleSignInScopes: appleSignInScopes))
    }
    
    public var body: some View {
        Section("Sign-in Methods") {
            ForEach(viewModel.providers, id: \.name) { provider in
                HStack {
                    VStack(alignment: .leading) {
                        Text(provider.name)
                            .font(.title3)
                            .foregroundStyle(config.providerNameColor)
                        
                        Text(provider.linkedEmail)
                            .foregroundStyle(config.emailColor)
                            .nnOnlyShow(when: !provider.linkedEmail.isEmpty)
                    }
                    
                    Spacer()
                    
                    NnAsyncTryButton(action: { try await viewModel.linkAction(provider) }) {
                        Text(provider.isLinked ? "Unlink" : "Link")
                            .underline()
                            .foregroundStyle(config.linkButtonColor)
                    }
                    .accessibilityIdentifier(CredentialKitAccessibilityId.accountLinkButton.rawValue)
                }
            }
        }
        .onAppear {
            viewModel.loadProviders()
        }
    }
}


// MARK: - Preview
#Preview {
    class PreviewDelegate: AccountLinkDelegate {
        func loadLinkedProviders() -> [AuthProvider] { [] }
        func loadSupportedProviders() -> [AuthProvider] { [] }
        func reauthenticate(with credientialType: CredentialType) async throws { }
        func linkProvider(with: CredentialType) async -> AccountCredentialResult { .success }
        func unlinkProvider(_ type: AuthProviderType) async -> AccountCredentialResult { .success }
    }
    
    return AccountLinkSection(config: .init(), delegate: PreviewDelegate(), appleSignInScopes: [])
}
