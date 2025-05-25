//
//  IncidentDetailView.swift
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

struct IncidentDetailView: View {
    @StateObject private var viewModel: IncidentDetailViewModel
    
    init(incidentId: Int) {
        _viewModel = StateObject(wrappedValue: IncidentDetailViewModel(incidentId: incidentId))
    }
    
    var body: some View {
        ScrollView {
            ZStack {
                // Background
                Color.theme.background
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 16) {
                    if let incident = viewModel.incident {
                        // Incident header
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                Text(incident.title)
                                    .font(.titleMedium)
                                    .foregroundColor(.theme.textPrimary)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Spacer(minLength: 8)
                                
                                StatusBadge(statusString: incident.status)
                            }
                            
                            HStack(spacing: 8) {
                                UrgencyIndicator(urgencyString: incident.urgency)
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.theme.textSecondary)
                                    Text(incident.formattedDate)
                                        .font(.bodySmall)
                                        .foregroundColor(.theme.textSecondary)
                                }
                            }
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Asignado a")
                                    .font(.bodySmall)
                                    .foregroundColor(.theme.textSecondary)
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.theme.secondary)
                                        .padding(8)
                                        .background(Color.theme.secondary.opacity(0.1))
                                        .clipShape(Circle())
                                    
                                    if let assignedTo = incident.assignedTo {
                                        Text(assignedTo.fullName)
                                            .font(.bodyMedium)
                                            .foregroundColor(.theme.textPrimary)
                                    } else {
                                        Text("Sin asignar")
                                            .font(.bodyMedium)
                                            .foregroundColor(.theme.textSecondary)
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        // Incident details
                        VStack(alignment: .leading, spacing: 16) {
                            // Description
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Descripción")
                                    .font(.bodyMedium.weight(.semibold))
                                    .foregroundColor(.theme.textPrimary)
                                
                                Text(incident.description)
                                    .font(.bodyMedium)
                                    .foregroundColor(.theme.textPrimary)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(12)
                                    .background(Color.theme.background)
                                    .cornerRadius(12)
                            }
                            
                            // Location
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Ubicación")
                                    .font(.bodyMedium.weight(.semibold))
                                    .foregroundColor(.theme.textPrimary)
                                
                                HStack(spacing: 8) {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.theme.secondary)
                                    
                                    Text(incident.location)
                                        .font(.bodyMedium)
                                        .foregroundColor(.theme.textPrimary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.theme.background)
                                .cornerRadius(12)
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        // Status update section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Actualizar Estado")
                                .font(.bodyMedium.weight(.semibold))
                                .foregroundColor(.theme.textPrimary)
                            
                            HStack(spacing: 8) {
                                Spacer()
                                StatusButton(status: "pendiente", currentStatus: incident.status) {
                                    viewModel.updateStatus(status: "pendiente")
                                }
                                
                                StatusButton(status: "en_proceso", currentStatus: incident.status) {
                                    viewModel.updateStatus(status: "en_proceso")
                                }
                                
                                StatusButton(status: "resuelta", currentStatus: incident.status) {
                                    viewModel.updateStatus(status: "resuelta")
                                }
                                
                                StatusButton(status: "cancelada", currentStatus: incident.status) {
                                    viewModel.updateStatus(status: "cancelada")
                                }
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        // Comments section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Comentarios")
                                .font(.bodyMedium.weight(.semibold))
                                .foregroundColor(.theme.textPrimary)
                            
                            if viewModel.isCommentsLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color.theme.primary))
                                        .scaleEffect(1.2)
                                    Spacer()
                                }
                                .padding()
                            } else if viewModel.comments.isEmpty {
                                VStack {
                                    Image(systemName: "text.bubble")
                                        .font(.system(size: 40))
                                        .foregroundColor(.theme.textSecondary.opacity(0.3))
                                        .padding(.bottom, 8)
                                    
                                    Text("No hay comentarios")
                                        .font(.bodyMedium)
                                        .foregroundColor(.theme.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(viewModel.comments) { comment in
                                        CommentView(comment: comment)
                                    }
                                }
                            }
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            // Add comment
                            HStack(spacing: 12) {
                                Image(systemName: "text.bubble")
                                    .foregroundColor(.theme.secondary)
                                    .padding(8)
                                
                                TextField("Añadir comentario...", text: $viewModel.newComment)
                                    .font(.bodyMedium)
                                    .foregroundColor(.theme.textPrimary)
                                
                                Button(action: viewModel.addComment) {
                                    Image(systemName: "paperplane.fill")
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(viewModel.newComment.isEmpty ? Color.gray.opacity(0.5) : Color.theme.primary)
                                        .clipShape(Circle())
                                }
                                .disabled(viewModel.newComment.isEmpty)
                            }
                            .padding(12)
                            .background(Color.theme.background)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.theme.border, lineWidth: 1)
                            )
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    } else if !viewModel.isLoading {
                        // No incident data available
                        VStack(spacing: 16) {
                            Spacer()
                            
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.theme.textSecondary.opacity(0.5))
                            
                            Text("No se pudo cargar la información de la incidencia")
                                .font(.titleSmall)
                                .foregroundColor(.theme.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Button("Reintentar") {
                                viewModel.loadIncident()
                            }
                            .font(.bodyMedium.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.theme.primary)
                            .clipShape(Capsule())
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                }
                .padding(16)
                
                // Error message
                if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.white)
                            
                            Text(errorMessage)
                                .font(.bodyMedium)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.errorMessage = nil
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .padding(16)
                        .background(Color.theme.critical)
                        .cornerRadius(12)
                        .padding(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(), value: viewModel.errorMessage != nil)
                    .zIndex(1)
                }
                
                // Loading overlay
                if viewModel.isLoading {
                    Color.black.opacity(0.05)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.theme.primary))
                        .scaleEffect(1.5)
                        .background(Color.white.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
            }
        }
        .navigationTitle("Detalles de Incidencia")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StatusButton: View {
    let status: String
    let currentStatus: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(statusText)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(status == currentStatus ? .white : statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(status == currentStatus ? statusColor : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(statusColor, lineWidth: 1)
                )
                .cornerRadius(6)
        }
        .disabled(status == currentStatus)
    }
    
    var statusText: String {
        switch status {
        case "pendiente": return "Pendiente"
        case "en_proceso": return "En Proceso"
        case "resuelta": return "Resuelta"
        case "cancelada": return "Cancelada"
        default: return status.capitalized
        }
    }
    
    var statusColor: Color {
        switch status {
        case "pendiente": return .yellow
        case "en_proceso": return .blue
        case "resuelta": return .green
        case "cancelada": return .gray
        default: return .gray
        }
    }
}

struct CommentView: View {
    let comment: IncidentComment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(comment.user.fullName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(comment.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(comment.content)
                .font(.body)
                .padding(.vertical, 4)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
