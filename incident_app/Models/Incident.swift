//
//  Incident.swift
//  incident_app
//
//  Created by  on 16/5/25.
//

import Foundation
import SwiftUI

enum IncidentStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case inProgress = "in_progress"
    case resolved = "resolved"
    case cancelled = "cancelled"
    
    var displayText: String {
        switch self {
        case .pending: return "Pendiente"
        case .inProgress: return "En Progreso"
        case .resolved: return "Resuelto"
        case .cancelled: return "Cancelado"
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

enum UrgencyLevel: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
    
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

struct Incident: Identifiable, Codable {
    let id: Int
    let title: String
    let description: String
    let location: String
    let latitude: Double?
    let longitude: Double?
    let createdAt: Date
    let updatedAt: Date
    var status: IncidentStatus
    let urgency: UrgencyLevel
    let assignedTo: Int?
    let createdBy: Int
    var comments: [Comment]?
    var attachments: [Attachment]?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, location, latitude, longitude
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case status, urgency
        case assignedTo = "assigned_to"
        case createdBy = "created_by"
        case comments, attachments
    }
}

struct Comment: Identifiable, Codable {
    let id: Int
    let text: String
    let createdAt: Date
    let userId: Int
    let userName: String
    
    enum CodingKeys: String, CodingKey {
        case id, text
        case createdAt = "created_at"
        case userId = "user_id"
        case userName = "user_name"
    }
}

struct Attachment: Identifiable, Codable {
    let id: Int
    let url: String
    let fileType: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, url
        case fileType = "file_type"
        case createdAt = "created_at"
    }
}

// Extension for previews and testing
extension Incident {
    static var sampleData: [Incident] {
        [
            Incident(
                id: 1,
                title: "Fuga de agua en tubería principal",
                description: "Se ha detectado una fuga importante en la tubería principal del sector norte. Necesita reparación inmediata.",
                location: "Sector Norte, Edificio 3",
                latitude: 37.7749,
                longitude: -122.4194,
                createdAt: Date().addingTimeInterval(-86400),
                updatedAt: Date().addingTimeInterval(-43200),
                status: .pending,
                urgency: .high,
                assignedTo: 2,
                createdBy: 1,
                comments: [
                    Comment(id: 1, text: "Equipo técnico en camino", createdAt: Date().addingTimeInterval(-43200), userId: 2, userName: "Maria García")
                ],
                attachments: [
                    Attachment(id: 1, url: "https://example.com/image1.jpg", fileType: "image/jpeg", createdAt: Date().addingTimeInterval(-86400))
                ]
            ),
            Incident(
                id: 2,
                title: "Fallos en sistema eléctrico",
                description: "Intermitencias en el suministro eléctrico del laboratorio principal.",
                location: "Laboratorio Central",
                latitude: 37.7739,
                longitude: -122.4312,
                createdAt: Date().addingTimeInterval(-172800),
                updatedAt: Date().addingTimeInterval(-86400),
                status: .inProgress,
                urgency: .medium,
                assignedTo: 3,
                createdBy: 1,
                comments: [],
                attachments: []
            ),
            Incident(
                id: 3,
                title: "Puerta de emergencia bloqueada",
                description: "La puerta de emergencia del segundo piso no se puede abrir correctamente.",
                location: "Segundo Piso, Ala Este",
                latitude: 37.7759,
                longitude: -122.4094,
                createdAt: Date().addingTimeInterval(-259200),
                updatedAt: Date().addingTimeInterval(-172800),
                status: .resolved,
                urgency: .critical,
                assignedTo: 2,
                createdBy: 4,
                comments: [],
                attachments: []
            ),
            Incident(
                id: 4,
                title: "Problemas con aire acondicionado",
                description: "El sistema de aire acondicionado está funcionando incorrectamente en sala de servidores.",
                location: "Sala de Servidores",
                latitude: 37.7729,
                longitude: -122.4194,
                createdAt: Date().addingTimeInterval(-345600),
                updatedAt: Date().addingTimeInterval(-259200),
                status: .cancelled,
                urgency: .low,
                assignedTo: nil,
                createdBy: 3,
                comments: [],
                attachments: []
            )
        ]
    }
}
