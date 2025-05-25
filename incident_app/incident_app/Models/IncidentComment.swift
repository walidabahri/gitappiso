//
//  IncidentComment.swift
//  incident_app
//
//  Created on 25/5/2025.
//

import Foundation

struct IncidentComment: Identifiable, Codable {
    let id: Int
    let incidentId: Int
    let user: User
    let content: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case incidentId = "incident_id"
        case user
        case content
        case createdAt = "created_at"
    }
    
    var formattedDate: String {
        // In a real implementation, we would format the date here
        return createdAt
    }
}
