//
//  User.swift
//  incident_app
//
//  Created by  on 16/5/25.
//

import Foundation

struct User: Identifiable, Codable {
    let id: Int
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let role: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case role
    }
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    var isManager: Bool {
        return role == "manager"
    }
}
