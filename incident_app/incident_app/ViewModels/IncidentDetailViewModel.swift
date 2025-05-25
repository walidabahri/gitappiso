//
//  IncidentDetailViewModel.swift
//  incident_app
//
//  Created on 25/5/2025.
//

import SwiftUI
import Combine

class IncidentDetailViewModel: ObservableObject {
    @Published var incident: Incident?
    @Published var comments: [IncidentComment] = []
    @Published var isLoading = false
    @Published var isCommentsLoading = false
    @Published var errorMessage: String? = nil
    @Published var newComment = ""
    
    private let incidentId: Int
    private let apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(incidentId: Int) {
        self.incidentId = incidentId
        loadIncident()
        loadComments()
    }
    
    func loadIncident() {
        isLoading = true
        errorMessage = nil
        
        apiService.getIncidentDetail(id: incidentId)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] incident in
                self?.incident = incident
            })
            .store(in: &cancellables)
    }
    
    func loadComments() {
        isCommentsLoading = true
        
        apiService.getComments(forIncidentId: incidentId)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isCommentsLoading = false
                if case .failure(let error) = completion {
                    print("Error loading comments: \(error.localizedDescription)")
                    // Don't show error for comments, it's not critical
                }
            }, receiveValue: { [weak self] comments in
                self?.comments = comments
            })
            .store(in: &cancellables)
    }
    
    func updateStatus(status: String) {
        isLoading = true
        errorMessage = nil
        
        apiService.updateIncidentStatus(incidentId: incidentId, status: status)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] incident in
                self?.incident = incident
            })
            .store(in: &cancellables)
    }
    
    func addComment() {
        guard !newComment.isEmpty else { return }
        
        isCommentsLoading = true
        
        apiService.addComment(to: incidentId, comment: newComment)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isCommentsLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = "Error al añadir comentario: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] comment in
                self?.comments.append(comment)
                self?.newComment = ""
            })
            .store(in: &cancellables)
    }
}
