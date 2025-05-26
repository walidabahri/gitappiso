//
//  AuthService.swift
//  incident_app
//
//  Created by  on 16/5/25.
//

import Foundation
import SwiftUI

class AuthService {
    // Base URL for API calls
    static let baseURL = "http://localhost:8000/api/" // Updated with trailing slash to match Vue.js implementation
    
    // Token storage keys
    private static let accessTokenKey = "access"
    private static let refreshTokenKey = "refresh"
    private static let userDataKey = "user_data"
    
    // Authentication endpoints
    static func login(username: String, password: String, completion: @escaping (Result<User, AuthError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/token/") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = ["username": username, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.serverError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let accessToken = json["access"] as? String,
                   let refreshToken = json["refresh"] as? String {
                    // Extract user information from token response
                    let userId = json["user_id"] as? Int
                    let username = json["username"] as? String
                    let userRole = json["user_role"] as? String
                    
                    // Save tokens
                    saveTokens(access: accessToken, refresh: refreshToken)
                    
                    // If we have user information in the token response, create a User object
                    if let userId = userId, let username = username, let userRole = userRole {
                        let user = User(id: userId, username: username, role: userRole)
                        saveUserData(user: user)
                        completion(.success(user))
                    } else {
                        // Fallback to getting user profile if token response doesn't include user info
                        getUserProfile { result in
                            switch result {
                            case .success(let user):
                                completion(.success(user))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    }
                } else {
                    completion(.failure(.invalidCredentials))
                }
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    // Get user profile after login
    static func getUserProfile(completion: @escaping (Result<User, AuthError>) -> Void) {
        guard let token = getAccessToken() else {
            completion(.failure(.notAuthenticated))
            return
        }
        
        guard let url = URL(string: "\(baseURL)/users/current/") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 401 {
                    // Token expired, try refresh
                    refreshAccessToken { success in
                        if success {
                            getUserProfile(completion: completion)
                        } else {
                            completion(.failure(.notAuthenticated))
                        }
                    }
                    return
                }
                completion(.failure(.serverError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let user = try decoder.decode(User.self, from: data)
                
                // Save user data for offline access
                saveUserData(user: user)
                
                completion(.success(user))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    // Refresh token when access token expires
    static func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = getRefreshToken() else {
            completion(false)
            return
        }
        
        guard let url = URL(string: "\(baseURL)/token/refresh/") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = ["refresh": refreshToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil,
                  let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let newAccessToken = json["access"] as? String else {
                // If refresh fails, user needs to login again
                logout()
                completion(false)
                return
            }
            
            // Save new access token
            UserDefaults.standard.set(newAccessToken, forKey: accessTokenKey)
            completion(true)
        }.resume()
    }
    
    // Logout user
    static func logout() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
        UserDefaults.standard.removeObject(forKey: userDataKey)
    }
    
    // Check if user is logged in
    static func isLoggedIn() -> Bool {
        return getAccessToken() != nil
    }
    
    // Get current user if available
    static func getCurrentUser() -> User? {
        guard let userData = UserDefaults.standard.data(forKey: userDataKey) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(User.self, from: userData)
        } catch {
            print("Error decoding user data: \(error)")
            return nil
        }
    }
    
    // Save tokens to UserDefaults
    private static func saveTokens(access: String, refresh: String) {
        UserDefaults.standard.set(access, forKey: accessTokenKey)
        UserDefaults.standard.set(refresh, forKey: refreshTokenKey)
    }
    
    // Get access token
    static func getAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: accessTokenKey)
    }
    
    // Get refresh token
    private static func getRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: refreshTokenKey)
    }
    
    // Save user data for offline access
    private static func saveUserData(user: User) {
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let userData = try encoder.encode(user)
            UserDefaults.standard.set(userData, forKey: userDataKey)
        } catch {
            print("Error encoding user data: \(error)")
        }
    }
    
    // Helper method to create authorized request
    static func createAuthorizedRequest(url: URL, method: String = "GET") -> URLRequest? {
        guard let token = getAccessToken() else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
}

// Authentication errors
enum AuthError: Error, LocalizedError {
    case invalidURL
    case noData
    case invalidResponse
    case invalidCredentials
    case networkError(Error)
    case serverError(Int)
    case decodingError(Error)
    case notAuthenticated
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .noData:
            return "No se recibieron datos del servidor"
        case .invalidResponse:
            return "Respuesta inválida del servidor"
        case .invalidCredentials:
            return "Usuario o contraseña incorrectos"
        case .networkError(let error):
            return "Error de red: \(error.localizedDescription)"
        case .serverError(let code):
            return "Error del servidor (\(code))"
        case .decodingError:
            return "Error al procesar la respuesta del servidor"
        case .notAuthenticated:
            return "Sesión expirada. Por favor, inicie sesión nuevamente"
        }
    }
}
