//
//  LoginViewModel.swift
//  incident_app
//
//  Created on 25/5/2025.
//

import Foundation
import Combine

class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private var authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Bind to auth service for updates
        authService.$isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        
        authService.$errorMessage
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancellables)
    }
    
    func login() {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Username and password are required"
            return
        }
        
        authService.login(username: username, password: password)
    }
    
    var isValid: Bool {
        return !username.isEmpty && !password.isEmpty
    }
}
