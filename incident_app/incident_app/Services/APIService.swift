//
//  APIService.swift
//  incident_app
//
//  Created on 25/5/2025.
//

import Foundation
import Combine

class APIService {
    static let shared = APIService()
    
    // MARK: - Properties
    private let baseURL = "http://localhost:8000/api" // Update this with your Django backend URL
    @Published var isAuthenticated = false
    
    // MARK: - Authentication
    
    func login(username: String, password: String) -> AnyPublisher<LoginResponse, Error> {
        let url = URL(string: "\(baseURL)/token/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginRequest = LoginRequest(username: username, password: password)
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(loginRequest)
            request.httpBody = data
            
            return URLSession.shared.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: LoginResponse.self, decoder: JSONDecoder())
                .map { response -> LoginResponse in
                    // Store the token
                    UserDefaults.standard.set(response.access, forKey: "access")
                    if let refresh = response.refresh {
                        UserDefaults.standard.set(refresh, forKey: "refresh")
                    }
                    self.isAuthenticated = true
                    return response
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "access")
        UserDefaults.standard.removeObject(forKey: "refresh")
        isAuthenticated = false
    }
    
    // MARK: - Incidents
    
    func getAssignedIncidents() -> AnyPublisher<[Incident], Error> {
        guard let token = UserDefaults.standard.string(forKey: "access") else {
            return Fail(error: NSError(domain: "APIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])).eraseToAnyPublisher()
        }
        
        let url = URL(string: "\(baseURL)/incidents/assigned/")!
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [Incident].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getAllIncidents() -> AnyPublisher<[Incident], Error> {
        guard let token = UserDefaults.standard.string(forKey: "access") else {
            return Fail(error: NSError(domain: "APIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])).eraseToAnyPublisher()
        }
        
        let url = URL(string: "\(baseURL)/incidents/")!
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [Incident].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getIncidentDetail(id: Int) -> AnyPublisher<Incident, Error> {
        guard let token = UserDefaults.standard.string(forKey: "access") else {
            return Fail(error: NSError(domain: "APIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])).eraseToAnyPublisher()
        }
        
        let url = URL(string: "\(baseURL)/incidents/\(id)/")!
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: Incident.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func createIncident(_ incident: CreateIncidentRequest) -> AnyPublisher<Incident, Error> {
        guard let token = UserDefaults.standard.string(forKey: "access") else {
            return Fail(error: NSError(domain: "APIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])).eraseToAnyPublisher()
        }
        
        let url = URL(string: "\(baseURL)/incidents/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(incident)
            request.httpBody = data
            
            return URLSession.shared.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: Incident.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    func updateIncidentStatus(incidentId: Int, status: String) -> AnyPublisher<Incident, Error> {
        guard let token = UserDefaults.standard.string(forKey: "access") else {
            return Fail(error: NSError(domain: "APIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])).eraseToAnyPublisher()
        }
        
        let url = URL(string: "\(baseURL)/incidents/\(incidentId)/")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let updateRequest = UpdateIncidentStatusRequest(status: status)
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(updateRequest)
            request.httpBody = data
            
            return URLSession.shared.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: Incident.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    // MARK: - Comments
    
    func getComments(forIncidentId id: Int) -> AnyPublisher<[IncidentComment], Error> {
        guard let token = UserDefaults.standard.string(forKey: "access") else {
            return Fail(error: NSError(domain: "APIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])).eraseToAnyPublisher()
        }
        
        let url = URL(string: "\(baseURL)/incidents/\(id)/comments/")!
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [IncidentComment].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func addComment(to incidentId: Int, comment: String) -> AnyPublisher<IncidentComment, Error> {
        guard let token = UserDefaults.standard.string(forKey: "access") else {
            return Fail(error: NSError(domain: "APIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])).eraseToAnyPublisher()
        }
        
        let url = URL(string: "\(baseURL)/incidents/\(incidentId)/comments/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let commentRequest = CreateCommentRequest(content: comment)
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(commentRequest)
            request.httpBody = data
            
            return URLSession.shared.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: IncidentComment.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    // MARK: - User Profile
    
    func getCurrentUser() -> AnyPublisher<User, Error> {
        guard let token = UserDefaults.standard.string(forKey: "access") else {
            return Fail(error: NSError(domain: "APIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])).eraseToAnyPublisher()
        }
        
        let url = URL(string: "\(baseURL)/users/me/")!
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: User.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
