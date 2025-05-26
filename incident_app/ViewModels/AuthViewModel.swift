//
//  AuthViewModel.swift
//  incident_app
//

import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var token: String? = nil
    @Published var refreshToken: String? = nil
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    init() {
        loadUserData() // Load data on app start
    }
    
    func login(username: String, password: String) {
        isLoading = true
        error = nil
        
        guard let url = URL(string: "http://localhost:8000/api/token/") else {
            self.error = "Invalid URL"
            self.isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginData = ["username": username, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: loginData)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.error = error.localizedDescription
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.error = "Invalid response"
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    self.error = "Server error: \(httpResponse.statusCode)"
                    return
                }
                
                guard let data = data else {
                    self.error = "No data received"
                    return
                }
                
                do {
                    // First try to parse the response as JSON
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let accessToken = json["access"] as? String,
                       let refreshToken = json["refresh"] as? String {
                        
                        // Store tokens
                        self.token = accessToken
                        self.refreshToken = refreshToken
                        
                        // Try to extract user info from token response
                        if let userId = json["user_id"] as? Int,
                           let username = json["username"] as? String,
                           let userRole = json["user_role"] as? String {
                            
                            let user = User(id: userId, username: username, role: userRole)
                            self.user = user
                            self.saveUserData()
                        } else {
                            // If user info not in token, fetch profile
                            self.getUserProfile()
                        }
                    } else {
                        self.error = "Invalid credentials or response format"
                    }
                }
            }
        }.resume()
    }
    
    func getUserProfile() {
        guard let token = token else {
            self.error = "Not authenticated"
            return
        }
        
        guard let url = URL(string: "http://localhost:8000/api/users/current/") else {
            self.error = "Invalid URL"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.error = error.localizedDescription
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.error = "Invalid response"
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    if httpResponse.statusCode == 401 {
                        // Token expired, try refresh
                        self.refreshAccessToken()
                    } else {
                        self.error = "Server error: \(httpResponse.statusCode)"
                    }
                    return
                }
                
                guard let data = data else {
                    self.error = "No data received"
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let user = try decoder.decode(User.self, from: data)
                    self.user = user
                    self.saveUserData()
                } catch {
                    self.error = "Error decoding user data: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func refreshAccessToken() {
        guard let refreshToken = refreshToken else {
            logout()
            return
        }
        
        guard let url = URL(string: "http://localhost:8000/api/token/refresh/") else {
            logout()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let refreshData = ["refresh": refreshToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: refreshData)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard error == nil,
                      let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let newAccessToken = json["access"] as? String else {
                    // If refresh fails, logout
                    self.logout()
                    return
                }
                
                // Save new access token
                self.token = newAccessToken
                UserDefaults.standard.set(newAccessToken, forKey: "access")
                
                // Retry the operation that failed due to expired token
                self.getUserProfile()
            }
        }.resume()
    }
    
    func logout() {
        self.user = nil
        self.token = nil
        self.refreshToken = nil
        UserDefaults.standard.removeObject(forKey: "user")
        UserDefaults.standard.removeObject(forKey: "access")
        UserDefaults.standard.removeObject(forKey: "refresh")
    }
    
    private func saveUserData() {
        if let user = user, let encodedUser = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encodedUser, forKey: "user")
        }
        
        if let token = token {
            UserDefaults.standard.set(token, forKey: "access")
        }
        
        if let refreshToken = refreshToken {
            UserDefaults.standard.set(refreshToken, forKey: "refresh")
        }
    }
    
    private func loadUserData() {
        if let savedUser = UserDefaults.standard.data(forKey: "user"),
           let decodedUser = try? JSONDecoder().decode(User.self, from: savedUser) {
            self.user = decodedUser
        }
        
        self.token = UserDefaults.standard.string(forKey: "access")
        self.refreshToken = UserDefaults.standard.string(forKey: "refresh")
    }
    
    // Check if user is logged in
    var isLoggedIn: Bool {
        return token != nil
    }
}
