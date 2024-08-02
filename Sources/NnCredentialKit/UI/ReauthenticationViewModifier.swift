//
//  ReauthenticationViewModifier.swift
//
//
//  Created by Nikolai Nobadi on 8/1/24.
//

import SwiftUI

struct ReauthenticationViewModifier: ViewModifier {
    @Binding var shouldReauthenticate: Bool
    
    func body(content: Content) -> some View {
        content
            .onChange(of: shouldReauthenticate) { _, newValue in
                
            }
    }
}

extension View {
    func withReauthentication(shouldReauthenticate: Binding<Bool>) -> some View {
        modifier(ReauthenticationViewModifier(shouldReauthenticate: shouldReauthenticate))
    }
}


final class ReauthenticationManager: ObservableObject {
    @Published var existingProvidersToSelect: [String] = []
    @Published var showingPasswordVerificationAlert = false
    
    private let delegate: ReauthenticationDelegate
    
    init(delegate: ReauthenticationDelegate) {
        self.delegate = delegate
    }
}

extension ReauthenticationManager {
    func reauthenticate(_ shouldReauthenticate: Bool) async throws {
        guard shouldReauthenticate else { return }
        
        let providers = delegate.loadLinkedProviders()
        
        if providers.count > 1 {
            existingProvidersToSelect = providers
        } else {
            guard let provider = providers.first else { return }
            
            // TODO: - if provider is email/password, show password alert
            try await reauthenticate(provider)
        }
    }
    
    func reauthenticateEmailAndPassword() async throws {
        // TODO: -
    }
}


// MARK: - Private Methods
private extension ReauthenticationManager {
    @MainActor func showPasswordAlert() {
        showingPasswordVerificationAlert = true
    }
    
    func reauthenticate(_ provider: String) async throws {
        // TODO: - use provide to reauthenticate
        try await delegate.reauthenticate()
    }
}


// TODO: -
protocol ReauthenticationDelegate {
    func loadLinkedProviders() -> [String]
    func reauthenticate() async throws
}
