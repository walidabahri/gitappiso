//
//  incident_appApp.swift
//  incident_app
//
//  Created by  on 16/5/25.
//

import SwiftUI

@main
struct incident_appApp: App {
    // Create a shared instance of AuthService
    @StateObject private var authService = AuthService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .onAppear {
                    // Set up any additional configuration here
                    setupAppearance()
                }
        }
    }
    
    private func setupAppearance() {
        // Configure navigation bar appearance with Bolt design system colors
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor(Color.theme.textPrimary)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.theme.textPrimary)]
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.05)
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(Color.theme.primary)
        
        // Set tab bar tint color to match the primary color from Bolt design
        UITabBar.appearance().tintColor = UIColor(Color.theme.primary)
    }
}
