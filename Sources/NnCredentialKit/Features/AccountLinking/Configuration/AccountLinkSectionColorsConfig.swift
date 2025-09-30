//
//  AccountLinkSectionColorsConfig.swift
//
//
//  Created by Nikolai Nobadi on 8/3/24.
//

import SwiftUI

/// A configuration structure for customizing the colors of the account link section.
public struct AccountLinkSectionColorsConfig {
    /// The color of the provider's name text.
    public let providerNameColor: Color
    
    /// The color of the email text.
    public let emailColor: Color
    
    /// Initializes the configuration with optional custom colors.
    /// - Parameters:
    ///   - providerNameColor: The color for the provider name. Default is `.primary`.
    ///   - emailColor: The color for the email text. Default is `.secondary`.
    public init(providerNameColor: Color = .primary, emailColor: Color = .secondary) {
        self.providerNameColor = providerNameColor
        self.emailColor = emailColor
    }
}
