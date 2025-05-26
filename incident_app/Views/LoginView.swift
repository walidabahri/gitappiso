//
//  LoginView.swift
//  incident_app
//
//  Created by  on 16/5/25.
//

import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showForgotPassword = false
    @AppStorage("access") var accessToken: String?
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Header Image with Title
                    ZStack {
                        // Background image with overlay
                        Image("header_background")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 240)
                            .clipped()
                            .overlay(
                                Color.theme.primary
                                    .opacity(0.7)
                            )
                        
                        // Title
                        Text("Gestión de Incidencias")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(height: 240)
                    
                    // Login Form
                    VStack(spacing: 24) {
                        // Welcome text
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Bienvenido")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.theme.textPrimary)
                            
                            Text("Inicie sesión para continuar")
                                .font(.system(size: 16))
                                .foregroundColor(.theme.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Error message
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Username field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Usuario")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.theme.textSecondary)
                            
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.theme.textSecondary)
                                    .frame(width: 24)
                                
                                TextField("", text: $username)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.theme.border, lineWidth: 1)
                            )
                        }
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Contraseña")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.theme.textSecondary)
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.theme.textSecondary)
                                    .frame(width: 24)
                                
                                SecureField("", text: $password)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.theme.border, lineWidth: 1)
                            )
                        }
                        
                        // Forgot password
                        Button(action: {
                            showForgotPassword = true
                        }) {
                            Text("¿Olvidó su contraseña?")
                                .font(.system(size: 14))
                                .foregroundColor(.theme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        // Login button
                        Button(action: login) {
                            ZStack {
                                Rectangle()
                                    .fill(Color.theme.primary)
                                    .cornerRadius(12)
                                    .frame(height: 56)
                                
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Iniciar Sesión")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .disabled(isLoading)
                    }
                    .padding(24)
                    .background(Color.theme.background)
                    .cornerRadius(24, corners: [.topLeft, .topRight])
                    .offset(y: -20)
                }
            }
            .ignoresSafeArea(edges: [.top])
        }
        .background(Color.theme.background)
        .alert(isPresented: $showForgotPassword) {
            Alert(
                title: Text("Recuperar contraseña"),
                message: Text("Póngase en contacto con el administrador del sistema para recuperar su contraseña."),
                dismissButton: .default(Text("Entendido"))
            )
        }
    }
    
    func login() {
        guard !username.isEmpty && !password.isEmpty else {
            errorMessage = "Por favor, introduzca su usuario y contraseña"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        AuthService.login(username: username, password: password) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let user):
                    // Store the user in UserDefaults or another persistence mechanism
                    print("Successfully logged in as \(user.fullName)")
                    // This value will trigger navigation in the main app view
                    accessToken = AuthService.getAccessToken()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// Extension to create rounded corners for specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    LoginView()
}
