//
//  Typography.swift
//  incident_app
//
//  Created on 25/5/2025.
//

import SwiftUI

extension Font {
    static func sfProText(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
    
    static let titleLarge = sfProText(28, weight: .bold)
    static let titleMedium = sfProText(24, weight: .bold)
    static let titleSmall = sfProText(18, weight: .semibold)
    
    static let bodyLarge = sfProText(16)
    static let bodyMedium = sfProText(14)
    static let bodySmall = sfProText(12)
}
