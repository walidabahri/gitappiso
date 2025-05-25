//
//  AuthService.swift
//  incident_app
//
//  Created by  on 16/5/25.
//

import Foundation
import Combine

class AuthService: ObservableObject {
    static let shared = AuthService()
    private var cancellables = Set<AnyCancellable>()
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    init() {
        // Check if we have a stored token and set authentication state
        if let token = UserDefaults.standard.string(forKey: "access") {
            isAuthenticated = true
            loadCurrentUser()
        }
    }
    
    func login(username: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        APIService.shared.login(username: username, password: password)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    if let apiError = error as? APIError {
                        self?.errorMessage = apiError.errorDescription
                    } else {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }, receiveValue: { [weak self] _ in
                self?.isAuthenticated = true
                self?.loadCurrentUser()
            })
            .store(in: &cancellables)
    }
    
    func logout() {
        APIService.shared.logout()
        currentUser = nil
        isAuthenticated = false
    }
    
    private func loadCurrentUser() {
        APIService.shared.getCurrentUser()
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    print("Failed to load user: \(error)")
                    // If we can't load the user, consider them logged out
                    self?.logout()
                }
            }, receiveValue: { [weak self] user in
                self?.currentUser = user
            })
            .store(in: &cancellables)
    }
    
    // For backwards compatibility
    static func login(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "http://localhost:8000/api/token/") else {
            completion(.failure(AuthError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = ["username": username, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(AuthError.noData))
                return
            }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let token = json["access"] as? String {
                completion(.success(token))
            } else {
                completion(.failure(AuthError.invalidCredentials))
            }
        }.resume()
    }
    
    enum AuthError: Error, LocalizedError {
        case invalidURL, noData, invalidCredentials
        
        var errorDescription: String? {
            switch self {
            case .invalidURL: return "invalid url"
            case .noData: return "no data returned"
            case .invalidCredentials: return "invalid username or password"
            }
        }
    }
}
