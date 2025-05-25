//
//  ContentView.swift
//  incident_app
//
//  Created by  on 16/5/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthService.shared
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                MainTabView()
                    .environmentObject(authService)
            } else {
                LoginView()
                    .environmentObject(authService)
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var authService: AuthService
    @State private var showNotifications = false
    @ObservedObject private var notificationService = NotificationService.shared
    
    // Count unread notifications
    private var unreadNotifications: Int {
        notificationService.notificationMessages.filter { !$0.isRead }.count
    }
    
    var body: some View {
        TabView {
            NavigationStack {
                IncidentsListView()
                    .navigationBarItems(trailing:
                        Button(action: {
                            showNotifications = true
                        }) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.theme.primary)
                                    .padding(6)
                                    .background(Color.theme.primary.opacity(0.1))
                                    .clipShape(Circle())
                                
                                if unreadNotifications > 0 {
                                    Text("\(unreadNotifications)")
                                        .font(.caption2.weight(.bold))
                                        .padding(5)
                                        .background(Color.theme.critical)
                                        .clipShape(Circle())
                                        .foregroundColor(.white)
                                        .offset(x: 8, y: -8)
                                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                }
                            }
                        }
                    )
            }
            .tabItem {
                Label("Incidencias", systemImage: "list.bullet")
            }
            .environmentObject(authService)
            
            CreateIncidentView()
                .tabItem {
                    Label("Crear", systemImage: "plus.circle.fill")
                }
                .environmentObject(authService)
            
            HistoryView()
                .tabItem {
                    Label("Historial", systemImage: "clock.fill")
                }
                .environmentObject(authService)
            
            ProfileView()
                .tabItem {
                    Label("Perfil", systemImage: "person.circle.fill")
                }
                .environmentObject(authService)
        }
        .accentColor(.theme.primary)
        .sheet(isPresented: $showNotifications) {
            NotificationsView()
                .presentationDetents([.medium, .large])
                .presentationBackground(Color.theme.background)
        }
        .onAppear {
            // Apply custom styling to tab bar
            let appearance = UITabBarAppearance()
            appearance.backgroundColor = UIColor.systemBackground
            appearance.shadowColor = UIColor.black.withAlphaComponent(0.1)
            
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
            
            // Request notification permissions when the app starts
            notificationService.requestPermission()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService.shared)
}
