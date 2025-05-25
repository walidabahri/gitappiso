//
//  StatusBadge.swift
//  incident_app
//
//  Created on 25/5/2025.
//

import SwiftUI

enum IncidentStatus: String, Codable {
    case pending = "pendiente"
    case inProgress = "en_proceso"
    case resolved = "resuelta"
    case cancelled = "cancelada"
    
    var displayText: String {
        switch self {
        case .pending: return "Pendiente"
        case .inProgress: return "En Proceso"
        case .resolved: return "Resuelta"
        case .cancelled: return "Cancelada"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return .theme.pending
        case .inProgress: return .theme.inProgress
        case .resolved: return .theme.resolved
        case .cancelled: return .theme.cancelled
        }
    }
}

struct StatusBadge: View {
    let status: IncidentStatus
    
    init(status: IncidentStatus) {
        self.status = status
    }
    
    init(statusString: String) {
        if let status = IncidentStatus(rawValue: statusString) {
            self.status = status
        } else {
            self.status = .pending
        }
    }
    
    var body: some View {
        Text(status.displayText)
            .font(.bodySmall.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(status.color)
            .clipShape(Capsule())
    }
}
