//
//  Incident.swift
//  incident_app
//
//  Created by  on 16/5/25.
//

import Foundation

struct Incident: Identifiable, Codable {
    let id: Int
    let title: String
    let description: String
    let location: String
    let urgency: String // "baja", "media", "alta", "critica"
    let status: String  // "pendiente", "en_proceso", "resuelta", "cancelada"
    let assignedTo: User?
    let createdBy: User
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case location
        case urgency
        case status
        case assignedTo = "assigned_to"
        case createdBy = "created_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Helper properties for UI
    var urgencyColor: String {
        switch urgency {
        case "baja": return "green"
        case "media": return "blue"
        case "alta": return "orange"
        case "critica": return "red"
        default: return "gray"
        }
    }
    
    var statusColor: String {
        switch status {
        case "pendiente": return "yellow"
        case "en_proceso": return "blue"
        case "resuelta": return "green"
        case "cancelada": return "gray"
        default: return "gray"
        }
    }
    
    var formattedDate: String {
        // Convert string date to more user-friendly format
        // For a real implementation, use DateFormatter
        return createdAt
    }
}
