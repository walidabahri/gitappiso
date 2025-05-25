//
//  IncidentsViewModel.swift
//  incident_app
//
//  Created on 25/5/2025.
//

import Foundation
import Combine

class IncidentsViewModel: ObservableObject {
    @Published var incidents: [Incident] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var refreshing = false
    
    private var apiService = APIService.shared
    private var authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load data when authenticated
        authService.$isAuthenticated
            .filter { $0 }
            .sink { [weak self] _ in
                self?.loadIncidents()
            }
            .store(in: &cancellables)
    }
    
    func loadIncidents() {
        isLoading = true
        errorMessage = nil
        
        // Use assigned incidents for operators, all incidents for managers
        let publisher: AnyPublisher<[Incident], Error> = authService.currentUser?.isManager == true
            ? apiService.getAllIncidents()
            : apiService.getAssignedIncidents()
        
        publisher
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                self?.refreshing = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] incidents in
                self?.incidents = incidents
            })
            .store(in: &cancellables)
    }
    
    func refresh() {
        refreshing = true
        loadIncidents()
    }
    
    func updateIncidentStatus(incident: Incident, status: String) {
        apiService.updateIncidentStatus(incidentId: incident.id, status: status)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] updatedIncident in
                self?.updateIncidentInList(updatedIncident)
            })
            .store(in: &cancellables)
    }
    
    private func updateIncidentInList(_ updatedIncident: Incident) {
        if let index = incidents.firstIndex(where: { $0.id == updatedIncident.id }) {
            incidents[index] = updatedIncident
        }
    }
}
