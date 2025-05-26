//
//  IncidentService.swift
//  incident_app
//
//  Created by  on 16/5/25.
//

import SwiftUI

class IncidentService {
    // Base URL is shared with AuthService
    private static let baseURL = AuthService.baseURL
    
    // MARK: - Incident Fetching
    
    /// Get all incidents
    static func getIncidents(completion: @escaping (Result<[Incident], IncidentError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/incidents/") else {
            completion(.failure(.invalidURL))
            return
        }
        
        guard let request = AuthService.createAuthorizedRequest(url: url) else {
            completion(.failure(.notAuthenticated))
            return
        }
        
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
                    AuthService.refreshAccessToken { success in
                        if success {
                            getIncidents(completion: completion)
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
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                let incidents = try decoder.decode([Incident].self, from: data)
                completion(.success(incidents))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    /// Get a specific incident by ID
    static func getIncident(id: Int, completion: @escaping (Result<Incident, IncidentError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/incidents/\(id)/") else {
            completion(.failure(.invalidURL))
            return
        }
        
        guard let request = AuthService.createAuthorizedRequest(url: url) else {
            completion(.failure(.notAuthenticated))
            return
        }
        
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
                if httpResponse.statusCode == 404 {
                    completion(.failure(.notFound))
                    return
                }
                if httpResponse.statusCode == 401 {
                    // Token expired, try refresh
                    AuthService.refreshAccessToken { success in
                        if success {
                            getIncident(id: id, completion: completion)
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
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                let incident = try decoder.decode(Incident.self, from: data)
                completion(.success(incident))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    // MARK: - Incident Creation
    
    /// Create a new incident
    static func createIncident(incident: IncidentCreateRequest, completion: @escaping (Result<Incident, IncidentError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/incidents/") else {
            completion(.failure(.invalidURL))
            return
        }
        
        guard var request = AuthService.createAuthorizedRequest(url: url, method: "POST") else {
            completion(.failure(.notAuthenticated))
            return
        }
        
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            request.httpBody = try encoder.encode(incident)
        } catch {
            completion(.failure(.encodingError(error)))
            return
        }
        
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
                    AuthService.refreshAccessToken { success in
                        if success {
                            createIncident(incident: incident, completion: completion)
                        } else {
                            completion(.failure(.notAuthenticated))
                        }
                    }
                    return
                }
                if httpResponse.statusCode == 400 {
                    // Handle validation errors
                    if let data = data,
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        completion(.failure(.validationError(json)))
                    } else {
                        completion(.failure(.serverError(httpResponse.statusCode)))
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
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                let incident = try decoder.decode(Incident.self, from: data)
                completion(.success(incident))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    // MARK: - Incident Updates
    
    /// Update an incident
    static func updateIncident(id: Int, updates: IncidentUpdateRequest, completion: @escaping (Result<Incident, IncidentError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/incidents/\(id)/") else {
            completion(.failure(.invalidURL))
            return
        }
        
        guard var request = AuthService.createAuthorizedRequest(url: url, method: "PATCH") else {
            completion(.failure(.notAuthenticated))
            return
        }
        
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            request.httpBody = try encoder.encode(updates)
        } catch {
            completion(.failure(.encodingError(error)))
            return
        }
        
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
                if httpResponse.statusCode == 404 {
                    completion(.failure(.notFound))
                    return
                }
                if httpResponse.statusCode == 401 {
                    // Token expired, try refresh
                    AuthService.refreshAccessToken { success in
                        if success {
                            updateIncident(id: id, updates: updates, completion: completion)
                        } else {
                            completion(.failure(.notAuthenticated))
                        }
                    }
                    return
                }
                if httpResponse.statusCode == 400 {
                    // Handle validation errors
                    if let data = data,
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        completion(.failure(.validationError(json)))
                    } else {
                        completion(.failure(.serverError(httpResponse.statusCode)))
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
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                let incident = try decoder.decode(Incident.self, from: data)
                completion(.success(incident))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    // MARK: - Comments
    
    /// Add a comment to an incident
    static func addComment(incidentId: Int, text: String, completion: @escaping (Result<Comment, IncidentError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/incidents/\(incidentId)/comments/") else {
            completion(.failure(.invalidURL))
            return
        }
        
        guard var request = AuthService.createAuthorizedRequest(url: url, method: "POST") else {
            completion(.failure(.notAuthenticated))
            return
        }
        
        let commentData = ["text": text]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: commentData)
        } catch {
            completion(.failure(.encodingError(error)))
            return
        }
        
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
                if httpResponse.statusCode == 404 {
                    completion(.failure(.notFound))
                    return
                }
                if httpResponse.statusCode == 401 {
                    // Token expired, try refresh
                    AuthService.refreshAccessToken { success in
                        if success {
                            addComment(incidentId: incidentId, text: text, completion: completion)
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
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                let comment = try decoder.decode(Comment.self, from: data)
                completion(.success(comment))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
    
    // MARK: - Offline support - for development without backend
    
    /// Get sample incidents for development
    static func getSampleIncidents() -> [Incident] {
        return Incident.sampleData
    }
    
    /// Get a sample incident by ID for development
    static func getSampleIncident(id: Int) -> Incident? {
        return Incident.sampleData.first { $0.id == id }
    }
}

// MARK: - Request models

/// Model for creating a new incident
struct IncidentCreateRequest: Codable {
    let title: String
    let description: String
    let location: String
    let latitude: Double?
    let longitude: Double?
    let urgency: String
}

/// Model for updating an incident
struct IncidentUpdateRequest: Codable {
    var status: String?
    var assignedTo: Int?
}

// MARK: - Error handling

enum IncidentError: Error, LocalizedError {
    case invalidURL
    case noData
    case invalidResponse
    case networkError(Error)
    case serverError(Int)
    case decodingError(Error)
    case encodingError(Error)
    case notAuthenticated
    case notFound
    case validationError([String: Any])
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .noData:
            return "No se recibieron datos del servidor"
        case .invalidResponse:
            return "Respuesta inválida del servidor"
        case .networkError(let error):
            return "Error de red: \(error.localizedDescription)"
        case .serverError(let code):
            return "Error del servidor (\(code))"
        case .decodingError:
            return "Error al procesar la respuesta del servidor"
        case .encodingError:
            return "Error al preparar los datos para enviar"
        case .notAuthenticated:
            return "Sesión expirada. Por favor, inicie sesión nuevamente"
        case .notFound:
            return "Incidencia no encontrada"
        case .validationError(let errors):
            return "Error de validación: \(errors)"
        }
    }
}
