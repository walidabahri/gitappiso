//
//  incident_appApp.swift
//  incident_app
//
//  Created by  on 16/5/25.
//

import SwiftUI

@main
struct incident_appApp: App {
    @AppStorage("access") var accessToken: String?
    
    var body: some Scene {
        WindowGroup {
            if accessToken == nil {
                LoginView()
            }else{
                Text("Logged in")
            }
        }
    }
}
