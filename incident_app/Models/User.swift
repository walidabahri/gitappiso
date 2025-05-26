//
//  User.swift
//  incident_app
//
//  Created by  on 16/5/25.
//

import Foundation

enum UserRole: String, Codable, CaseIterable {
    case worker = "worker"
    case manager = "manager"
    case admin = "admin"
    
    var displayText: String {
        switch self {
        case .worker: return "Operador"
        case .manager: return "Supervisor"
        case .admin: return "Administrador"
        }
    }
}

struct User: Identifiable, Codable {
    let id: Int
    let username: String
    let email: String?
    let firstName: String?
    let lastName: String?
    var role: String
    let profileImage: String?
    
    init(id: Int, username: String, role: String, email: String? = nil, firstName: String? = nil, lastName: String? = nil, profileImage: String? = nil) {
        self.id = id
        self.username = username
        self.role = role
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.profileImage = profileImage
    }
    
    enum CodingKeys: String, CodingKey {
        case id, username, email, role
        case firstName = "first_name"
        case lastName = "last_name"
        case profileImage = "profile_image"
    }
    
    var fullName: String {
        if let firstName = firstName, let lastName = lastName {
            return "\(firstName) \(lastName)"
        } else if let firstName = firstName {
            return firstName
        } else {
            return username
        }
    }
}

// Extension for previews and testing
extension User {
    static var sampleData: [User] {
        [
            User(id: 1, username: "jperez", email: "juan.perez@example.com", firstName: "Juan", lastName: "Pérez", role: .admin, profileImage: nil),
            User(id: 2, username: "mgarcia", email: "maria.garcia@example.com", firstName: "María", lastName: "García", role: .manager, profileImage: nil),
            User(id: 3, username: "alopez", email: "antonio.lopez@example.com", firstName: "Antonio", lastName: "López", role: .worker, profileImage: nil),
            User(id: 4, username: "srodriguez", email: "sofia.rodriguez@example.com", firstName: "Sofía", lastName: "Rodríguez", role: .worker, profileImage: nil)
        ]
    }
    
    static var currentUser: User {
        sampleData[0]
    }
}
