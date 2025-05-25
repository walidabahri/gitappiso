//
//  Incident.swift
//  incident_app
//
//  Created by  on 16/5/25.
//

struct Incident : Identifiable , Decodable {
    let id : Int
    let description : String
    let urgency : String
    let status : String
}
