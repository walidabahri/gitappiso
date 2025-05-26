//
//  StatusButton.swift
//  incident_app
//
//  Created on 25/5/2025.
//

import SwiftUI

struct StatusButton: View {
    let status: String
    let label: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    init(status: String, label: String, color: Color, isSelected: Bool, action: @escaping () -> Void) {
        self.status = status
        self.label = label
        self.color = color
        self.isSelected = isSelected
        self.action = action
    }
    
    // Convenience initializer using predefined status
    init(status: String, currentStatus: String, action: @escaping () -> Void) {
        let isSelected = status == currentStatus
        let statusColor: Color
        let statusLabel: String
        
        switch status {
        case "pending", "pendiente":
            statusColor = .theme.pending
            statusLabel = "Pendiente"
        case "in_progress", "en_proceso":
            statusColor = .theme.inProgress
            statusLabel = "En Progreso"
        case "resolved", "resuelta":
            statusColor = .theme.resolved
            statusLabel = "Resuelto"
        case "cancelled", "cancelada":
            statusColor = .theme.cancelled
            statusLabel = "Cancelado"
        default:
            statusColor = .gray
            statusLabel = status.capitalized
        }
        
        self.init(status: status, label: statusLabel, color: statusColor, isSelected: isSelected, action: action)
    }
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.bodyMedium.weight(.medium))
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(isSelected ? color : Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color, lineWidth: 1)
                )
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isSelected)
        .opacity(isSelected ? 1 : 0.8)
    }
}

struct StatusButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 10) {
            StatusButton(status: "pendiente", currentStatus: "pendiente") {}
            StatusButton(status: "en_proceso", currentStatus: "pendiente") {}
            StatusButton(status: "resuelta", currentStatus: "pendiente") {}
            StatusButton(status: "cancelada", currentStatus: "pendiente") {}
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
