//
//  AuthService.swift
//  incident_app
//
//  Created by  on 16/5/25.
//

import Foundation

struct AuthService {
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



