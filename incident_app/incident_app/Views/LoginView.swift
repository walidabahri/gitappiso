//
//  LoginView.swift
//  incident_app
//
//  Created by  on 16/5/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject private var authService: AuthService
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Header Image with Overlay
                    ZStack {
                        // Placeholder color if image fails to load
                        Color.theme.primary.opacity(0.8)
                            .frame(height: 240)
                        
                        // Background image with overlay
                        Image(systemName: "building.2.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100)
                            .foregroundColor(.white.opacity(0.3))
                        
                        // Title
                        VStack(spacing: 8) {
                            Text("Gestión de Incidencias")
                                .font(.titleLarge)
                                .foregroundColor(.white)
                            
                            Text("Acceso de Operarios")
                                .font(.bodyLarge)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    // Login Form
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bienvenido")
                                .font(.titleMedium)
                                .foregroundColor(.theme.textPrimary)
                            
                            Text("Inicie sesión para continuar")
                                .font(.bodyLarge)
                                .foregroundColor(.theme.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.bodyMedium)
                                .foregroundColor(.red)
                                .padding(12)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        // Username field
                        CustomTextField(
                            text: $viewModel.username,
                            placeholder: "Usuario",
                            icon: "person.fill"
                        )
                        
                        // Password field
                        CustomTextField(
                            text: $viewModel.password,
                            placeholder: "Contraseña",
                            icon: "lock.fill",
                            isSecure: true
                        )
                        
                        Button("¿Olvidó su contraseña?")
                        {
                            // Handle forgot password
                        }
                        .font(.bodyMedium)
                        .foregroundColor(.theme.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        // Login button
                        Button(action: viewModel.login) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Iniciar Sesión")
                                    .font(.bodyLarge.weight(.semibold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(viewModel.isValid ? Color.theme.primary : Color.gray.opacity(0.5))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .disabled(!viewModel.isValid || viewModel.isLoading)
                        
                        // App version or copyright
                        Text("© 2025 Gestión de Incidencias v1.0")
                            .font(.caption)
                            .foregroundColor(.theme.textSecondary)
                            .padding(.top, 24)
                    }
                    .padding(24)
                    .background(Color.theme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .offset(y: -24)
                }
            }
            .ignoresSafeArea(edges: .top)
            .background(Color.theme.background)
        }
    }
}
