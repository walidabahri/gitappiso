//
//  IncidentCard.swift
//  incident_app
//
//  Created on 25/5/2025.
//

import SwiftUI

struct IncidentCard: View {
    let incident: Incident
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                StatusBadge(statusString: incident.status)
                Spacer()
                UrgencyIndicator(urgencyString: incident.urgency)
            }
            
            Text(incident.title)
                .font(.titleSmall)
                .foregroundColor(.theme.textPrimary)
            
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.theme.textSecondary)
                Text(incident.location)
                    .foregroundColor(.theme.textSecondary)
            }
            .font(.bodyMedium)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.theme.textSecondary)
                Text(incident.formattedDate)
                    .foregroundColor(.theme.textSecondary)
                
                Spacer()
                
                if let assignedTo = incident.assignedTo {
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .foregroundColor(.theme.textSecondary)
                        Text(assignedTo.fullName)
                            .foregroundColor(.theme.textSecondary)
                    }
                }
            }
            .font(.bodySmall)
        }
        .padding(16)
        .background(Color.theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
    }
}
