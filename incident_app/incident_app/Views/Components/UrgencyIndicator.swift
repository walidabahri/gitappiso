//
//  UrgencyIndicator.swift
//  incident_app
//
//  Created on 25/5/2025.
//

import SwiftUI

enum UrgencyLevel: String, Codable {
    case low = "baja"
    case medium = "media"
    case high = "alta"
    case critical = "critica"
    
    var displayText: String {
        switch self {
        case .low: return "Baja"
        case .medium: return "Media"
        case .high: return "Alta"
        case .critical: return "Crítica"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .theme.low
        case .medium: return .theme.medium
        case .high: return .theme.high
        case .critical: return .theme.critical
        }
    }
}

struct UrgencyIndicator: View {
    let urgency: UrgencyLevel
    
    init(urgency: UrgencyLevel) {
        self.urgency = urgency
    }
    
    init(urgencyString: String) {
        if let urgency = UrgencyLevel(rawValue: urgencyString) {
            self.urgency = urgency
        } else {
            self.urgency = .medium
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(urgency.displayText)
        }
        .font(.bodySmall.weight(.semibold))
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(urgency.color)
        .clipShape(Capsule())
    }
}
