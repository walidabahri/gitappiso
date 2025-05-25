//
//  StatusButton.swift
//  incident_app
//
//  Created on 25/5/2025.
//

import SwiftUI

struct StatusButton: View {
    let status: String
    let currentStatus: String
    let action: () -> Void
    
    private var isSelected: Bool {
        status == currentStatus
    }
    
    private var buttonColor: Color {
        switch status {
        case "pendiente":
            return .theme.warning
        case "en_proceso":
            return .theme.info
        case "resuelta":
            return .theme.success
        case "cancelada":
            return .theme.critical
        default:
            return .gray
        }
    }
    
    private var statusText: String {
        switch status {
        case "pendiente":
            return "Pendiente"
        case "en_proceso":
            return "En Proceso"
        case "resuelta":
            return "Resuelta"
        case "cancelada":
            return "Cancelada"
        default:
            return status.capitalized
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(statusText)
                .font(.bodySmall.weight(.semibold))
                .foregroundColor(isSelected ? .white : buttonColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    isSelected ? 
                    buttonColor : 
                    buttonColor.opacity(0.1)
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(buttonColor, lineWidth: isSelected ? 0 : 1)
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
