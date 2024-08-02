//
//  AccountLinkSection.swift
//  
//
//  Created by Nikolai Nobadi on 8/1/24.
//

import SwiftUI
import NnSwiftUIKit

struct AccountLinkSection: View {
    @StateObject var viewModel: AccountLinkViewModel
    
    var body: some View {
        Section("Sign-in Methods") {
            ForEach(viewModel.linkItems) { item in
                LinkRow(item: item) {
                    
                }
            }
        }
    }
}


// MARK: - Row
fileprivate struct LinkRow: View {
    let item: LinkItem
    let linkAction: () async throws -> Void
    
    var body: some View {
        HStack {
            VStack {
                // TODO: - linkItem name
                // TODO: - optional email
            }
            
            NnAsyncTryButton(action: linkAction) {
                Text(item.buttonText)
                    .underline()
            }
        }
    }
}


// MARK: - Preview
//#Preview {
//    AccountLinkSection()
//}


fileprivate extension LinkItem {
    var buttonText: String {
        return isLinked ? "Unlink" : "Link"
    }
}
