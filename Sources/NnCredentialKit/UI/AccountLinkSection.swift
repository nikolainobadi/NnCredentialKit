//
//  AccountLinkSection.swift
//  
//
//  Created by Nikolai Nobadi on 8/1/24.
//

import SwiftUI
import NnSwiftUIKit

struct AccountLinkSection: View {
    
    var body: some View {
        Section("Sign-in Methods") {
            
        }
    }
}


// MARK: - Row
fileprivate struct LinkRow: View {
    var body: some View {
        HStack {
            VStack {
                
            }
            
            NnAsyncTryButton("", action: { })
        }
    }
}


// MARK: - Preview
#Preview {
    AccountLinkSection()
}

final class AccountLinkViewModel: ObservableObject {
    
}
