//
//  ContentView.swift
//  incident_app
//
//  Created by  on 16/5/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("access") private var accessToken: String?
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if accessToken == nil {
                // User is not logged in
                LoginView()
            } else {
                // User is logged in
                TabView(selection: $selectedTab) {
                    // Active Incidents Tab
                    NavigationView {
                        IncidentsListView()
                    }
                    .tabItem {
                        Label("Incidencias", systemImage: "exclamationmark.triangle")
                    }
                    .tag(0)
                    
                    // Create Incident Tab
                    NavigationView {
                        CreateIncidentView()
                    }
                    .tabItem {
                        Label("Reportar", systemImage: "plus.circle")
                    }
                    .tag(1)
                    
                    // History Tab
                    NavigationView {
                        HistoryView()
                    }
                    .tabItem {
                        Label("Historial", systemImage: "clock")
                    }
                    .tag(2)
                    
                    // Profile Tab
                    NavigationView {
                        ProfileView()
                    }
                    .tabItem {
                        Label("Perfil", systemImage: "person")
                    }
                    .tag(3)
                }
                .accentColor(.theme.primary)
            }
        }
    }
}

// Placeholder for History View
struct HistoryView: View {
    @State private var incidents: [Incident] = []
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            } else {
                if incidents.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 50))
                            .foregroundColor(.theme.textSecondary.opacity(0.5))
                        
                        Text("No hay incidencias resueltas")
                            .font(.system(size: 16))
                            .foregroundColor(.theme.textSecondary)
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(incidents) { incident in
                                HistoryCard(incident: incident) {
                                    // Navigate to incident detail
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
        .navigationTitle("Historial")
        .background(Color.theme.background)
        .onAppear {
            // Load resolved incidents
            loadResolvedIncidents()
        }
    }
    
    private func loadResolvedIncidents() {
        isLoading = true
        
        // For development without backend
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.incidents = IncidentService.getSampleIncidents().filter { 
                $0.status == .resolved || $0.status == .cancelled 
            }
            self.isLoading = false
        }
    }
}

// Placeholder for Profile View
struct ProfileView: View {
    @AppStorage("access") private var accessToken: String?
    @State private var currentUser: User? = nil
    
    var body: some View {
        VStack(spacing: 24) {
            // Profile header
            VStack(spacing: 16) {
                // Profile image
                ZStack {
                    Circle()
                        .fill(Color.theme.primary.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Text(userInitials)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.theme.primary)
                }
                
                // User name
                Text(userName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.theme.textPrimary)
                
                // User role
                Text(userRole)
                    .font(.system(size: 16))
                    .foregroundColor(.theme.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Color.theme.primary.opacity(0.1))
                    .cornerRadius(20)
            }
            .padding(.top, 32)
            
            // Divider
            Divider()
                .padding(.horizontal)
            
            // User details
            VStack(spacing: 20) {
                ProfileDetailRow(icon: "envelope", title: "Email", value: userEmail)
                ProfileDetailRow(icon: "person.badge.key", title: "Usuario", value: username)
                ProfileDetailRow(icon: "building.2", title: "Departamento", value: "Operaciones")
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Logout button
            Button(action: logout) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Cerrar sesión")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.theme.primary)
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.bottom, 32)
        }
        .navigationTitle("Perfil")
        .background(Color.theme.background)
        .onAppear {
            // Load user profile
            loadUserProfile()
        }
    }
    
    private var userInitials: String {
        if let user = currentUser {
            let firstInitial = user.firstName?.prefix(1).map { String($0) } ?? ""
            let lastInitial = user.lastName?.prefix(1).map { String($0) } ?? ""
            
            if !firstInitial.isEmpty || !lastInitial.isEmpty {
                return "\(firstInitial)\(lastInitial)"
            } else {
                return user.username.prefix(2).uppercased()
            }
        }
        return "--"
    }
    
    private var userName: String {
        currentUser?.fullName ?? "Usuario"
    }
    
    private var userRole: String {
        guard let role = currentUser?.role else { return "--" }
        
        // Convert role string to display format
        switch role.lowercased() {
        case "worker", "operator":
            return "Operador"
        case "manager":
            return "Supervisor"
        case "admin":
            return "Administrador"
        default:
            return role.capitalized
        }
    }
    
    private var userEmail: String {
        currentUser?.email ?? "--"
    }
    
    private var username: String {
        currentUser?.username ?? "--"
    }
    
    private func loadUserProfile() {
        // For development without backend
        currentUser = User.sampleData[0]
        
        // When backend is ready, uncomment this:
        /*
        if let user = AuthService.getCurrentUser() {
            currentUser = user
        } else {
            AuthService.getUserProfile { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let user):
                        currentUser = user
                    case .failure(let error):
                        print("Error loading profile: \(error)")
                    }
                }
            }
        }
        */
    }
    
    private func logout() {
        // Clear the access token to log out
        AuthService.logout()
        accessToken = nil
    }
}

struct ProfileDetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.theme.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.theme.textSecondary)
                
                Text(value)
                    .font(.system(size: 16))
                    .foregroundColor(.theme.textPrimary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    ContentView()
}
