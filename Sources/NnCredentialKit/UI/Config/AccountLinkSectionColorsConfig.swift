//
//  AccountLinkSectionColorsConfig.swift
//
//
//  Created by Nikolai Nobadi on 8/3/24.
//

import SwiftUI

public struct AccountLinkSectionColorsConfig {
    public let providerNameColor: Color
    public let emailColor: Color
    public let linkButtonColor: Color
    
    public init(providerNameColor: Color = .primary, emailColor: Color = .secondary, linkButtonColor: Color = .blue) {
        self.providerNameColor = providerNameColor
        self.emailColor = emailColor
        self.linkButtonColor = linkButtonColor
    }
}
