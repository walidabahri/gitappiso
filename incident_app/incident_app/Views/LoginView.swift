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
    @AppStorage("access") var accessToken: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Incident Login").font(.largeTitle)
            
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !errorMessage.isEmpty {
                Text(errorMessage).foregroundColor(.red)
            }
            
            Button("Login") {
                login()
            }
            .padding()
        }
        .padding()
    }
    
    func login() {
        AuthService.login(username: username, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    accessToken = token
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
