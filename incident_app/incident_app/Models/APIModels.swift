//
//  APIModels.swift
//  incident_app
//
//  Created on 25/5/2025.
//

import Foundation

// Authentication models
struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct LoginResponse: Codable {
    let access: String
    let refresh: String?
}

// Incident creation and update models
struct CreateIncidentRequest: Codable {
    let title: String
    let description: String
    let location: String
    let urgency: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case location
        case urgency
    }
}

struct UpdateIncidentStatusRequest: Codable {
    let status: String
}

struct CreateCommentRequest: Codable {
    let content: String
}

// API Error models
struct APIError: Codable, Error {
    let detail: String?
    let nonFieldErrors: [String]?
    
    enum CodingKeys: String, CodingKey {
        case detail
        case nonFieldErrors = "non_field_errors"
    }
    
    var errorDescription: String {
        if let detail = detail {
            return detail
        } else if let errors = nonFieldErrors, !errors.isEmpty {
            return errors.joined(separator: ", ")
        } else {
            return "Unknown error occurred"
        }
    }
}
