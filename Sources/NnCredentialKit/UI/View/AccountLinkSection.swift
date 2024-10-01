//
//  AccountLinkSection.swift
//  
//
//  Created by Nikolai Nobadi on 8/1/24.
//

import SwiftUI
import AuthenticationServices
import NnCredentialKitAccessibility

/// A view that displays a section for managing account link/unlink operations.
public struct AccountLinkSection<LinkButton: View>: View {
    @StateObject var viewModel: AccountLinkViewModel
    
    /// The configuration for customizing the colors in the section.
    let config: AccountLinkSectionColorsConfig
    
    public typealias LinkAction = () async throws -> Void
    let linkButton: (LinkAction) -> LinkButton
    
    /// Initializes the section with the specified configuration, delegate, and Apple sign-in scopes.
    /// - Parameters:
    ///   - config: The color configuration for the section.
    ///   - delegate: The delegate responsible for handling account link actions.
    ///   - appleSignInScopes: The scopes to request during Apple Sign-In.
    public init(config: AccountLinkSectionColorsConfig, delegate: AccountLinkDelegate, appleSignInScopes: [ASAuthorization.Scope], @ViewBuilder linkButton: @escaping (LinkAction) -> LinkButton) {
        self.config = config
        self.linkButton = linkButton
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
                        
                        if !provider.linkedEmail.isEmpty {
                            Text(provider.linkedEmail)
                                .foregroundStyle(config.emailColor)
                        }
                    }
                    
                    Spacer()
                    
                    linkButton {
                        try await viewModel.linkAction(provider)
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
    
    return AccountLinkSection(config: .init(), delegate: PreviewDelegate(), appleSignInScopes: []) { _ in
        Button("Link", action: { })
    }
}
