//
//  ProfileView.swift
//  incident_app
//
//  Created on 25/5/2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color.theme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile header with avatar
                        if let user = authService.currentUser {
                            VStack(spacing: 16) {
                                // Avatar
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.theme.primary)
                                    .background(Color.theme.background)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.theme.primary.opacity(0.2), lineWidth: 4)
                                    )
                                    .padding(.top, 10)
                                
                                // User name
                                VStack(spacing: 5) {
                                    Text("\(user.firstName) \(user.lastName)")
                                        .font(.titleLarge)
                                        .foregroundColor(.theme.textPrimary)
                                    
                                    Text(user.role)
                                        .font(.bodyMedium)
                                        .foregroundColor(.theme.secondary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 6)
                                        .background(Color.theme.secondary.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            
                            // User Information Section
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Información Personal")
                                    .font(.titleSmall)
                                    .foregroundColor(.theme.textPrimary)
                                    .padding(.bottom, 10)
                                
                                ProfileInfoRow(title: "Nombre de Usuario", value: user.username)
                                ProfileInfoRow(title: "Correo Electrónico", value: user.email)
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        } else {
                            // Loading state
                            VStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color.theme.primary))
                                    .scaleEffect(1.5)
                                    .padding()
                                
                                Text("Cargando información...")
                                    .font(.bodyMedium)
                                    .foregroundColor(.theme.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(40)
                            .background(Color.white)
                            .cornerRadius(16)
                        }
                        
                        // Preferences Section
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Preferencias")
                                .font(.titleSmall)
                                .foregroundColor(.theme.textPrimary)
                                .padding(.bottom, 10)
                            
                            VStack(spacing: 10) {
                                ProfileToggleRow(title: "Notificaciones", isOn: $viewModel.notificationsEnabled, icon: "bell.fill")
                                Divider()
                                ProfileToggleRow(title: "Modo Oscuro", isOn: $viewModel.darkModeEnabled, icon: "moon.fill")
                                Divider()
                                ProfileToggleRow(title: "Datos Móviles", isOn: $viewModel.useMobileData, icon: "network")
                            }
                            .padding(.vertical, 5)
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        // Statistics Section
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Estadísticas")
                                .font(.titleSmall)
                                .foregroundColor(.theme.textPrimary)
                                .padding(.bottom, 10)
                            
                            HStack(spacing: 15) {
                                // Reported incidents
                                StatisticCard(
                                    value: viewModel.reportedIncidents,
                                    title: "Reportados",
                                    iconName: "exclamationmark.triangle.fill",
                                    color: .theme.warning
                                )
                                
                                // Resolved incidents
                                StatisticCard(
                                    value: viewModel.resolvedIncidents,
                                    title: "Resueltos",
                                    iconName: "checkmark.circle.fill",
                                    color: .theme.success
                                )
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        // Logout Button
                        Button(action: {
                            authService.logout()
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Cerrar Sesión")
                                    .font(.bodyMedium.weight(.semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.theme.critical)
                            .cornerRadius(12)
                            .shadow(color: Color.theme.critical.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.vertical, 10)
                    }
                    .padding(16)
                } else {
                    // Loading or error state
                    VStack {
                        ProgressView()
                        Text("Cargando información de usuario...")
                            .padding()
                    }
                }
            }
            .navigationTitle("Mi Perfil")
        }
    }
}

struct ProfileOptionRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}
