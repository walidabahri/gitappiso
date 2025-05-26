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
                    // Header with background image
                    ZStack {
                        // Background image
                        AsyncImage(url: URL(string: "https://images.pexels.com/photos/3760529/pexels-photo-3760529.jpeg")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.theme.primary.opacity(0.8)
                        }
                        .frame(height: 240)
                        
                        // Overlay
                        Color.theme.primary
                            .opacity(0.7)
                            .frame(height: 240)
                        
                        // Title
                        Text("Gestión de Incidencias")
                            .font(.titleLarge)
                            .foregroundColor(.white)
                    }
                    .frame(height: 240)
                    
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
                        
                        if let error = viewModel.error {
                            Text(error)
                                .font(.bodyMedium)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 8)
                        }
                        
                        // Username Field
                        CustomTextField(
                            placeholder: "Usuario",
                            icon: "person.fill",
                            text: $viewModel.username
                        )
                        
                        // Password field
                        CustomTextField(
                            placeholder: "Contraseña",
                            icon: "lock.fill",
                            text: $viewModel.password,
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
