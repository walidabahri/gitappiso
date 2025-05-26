import SwiftUI

struct IncidentDetailView: View {
    let incidentId: Int
    @State private var incident: Incident?
    @State private var isLoading = true
    @State private var errorMessage = ""
    @State private var showingStatusOptions = false
    @State private var newComment = ""
    @State private var isSubmittingComment = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .padding(.top, 100)
                    Spacer()
                }
                .frame(minHeight: 300)
            } else if let incident = incident {
                VStack(alignment: .leading, spacing: 16) {
                    // Header with status and urgency
                    HStack {
                        StatusBadge(status: incident.status)
                        Spacer()
                        UrgencyIndicator(urgency: incident.urgency)
                    }
                    
                    // Title
                    Text(incident.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.theme.textPrimary)
                    
                    // Location
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.theme.textSecondary)
                        Text(incident.location)
                            .font(.system(size: 16))
                            .foregroundColor(.theme.textSecondary)
                    }
                    
                    // Divider
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Description section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Descripción")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.theme.textPrimary)
                        
                        Text(incident.description)
                            .font(.system(size: 16))
                            .foregroundColor(.theme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // Divider
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Details section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Detalles")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.theme.textPrimary)
                        
                        // Creation date
                        DetailRow(icon: "calendar", title: "Fecha de creación", value: formatDate(incident.createdAt))
                        
                        // Last update
                        DetailRow(icon: "clock", title: "Última actualización", value: formatDate(incident.updatedAt))
                        
                        // Assigned to
                        DetailRow(icon: "person.fill", title: "Asignado a", value: incident.assignedTo != nil ? "ID: \(incident.assignedTo!)" : "Sin asignar")
                        
                        // Created by
                        DetailRow(icon: "person.badge.shield.checkmark", title: "Creado por", value: "ID: \(incident.createdBy)")
                    }
                    
                    // Action buttons
                    if incident.status != .resolved && incident.status != .cancelled {
                        HStack(spacing: 16) {
                            // Update status button
                            Button(action: {
                                showingStatusOptions = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("Cambiar estado")
                                }
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.theme.primary)
                                .cornerRadius(12)
                            }
                            
                            // Assign button
                            Button(action: {
                                // Assign action
                            }) {
                                HStack {
                                    Image(systemName: "person.badge.plus")
                                    Text("Asignar")
                                }
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.theme.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.theme.primary, lineWidth: 1)
                                )
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Divider
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Comments section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Comentarios")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.theme.textPrimary)
                        
                        if let comments = incident.comments, !comments.isEmpty {
                            ForEach(comments) { comment in
                                CommentView(comment: comment)
                            }
                        } else {
                            Text("No hay comentarios")
                                .font(.system(size: 16))
                                .foregroundColor(.theme.textSecondary)
                                .padding(.vertical, 8)
                        }
                        
                        // Add comment field
                        VStack(spacing: 12) {
                            TextField("Añadir un comentario...", text: $newComment)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.theme.border, lineWidth: 1)
                                )
                            
                            Button(action: submitComment) {
                                HStack {
                                    if isSubmittingComment {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text("Enviar comentario")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(newComment.isEmpty ? Color.gray.opacity(0.5) : Color.theme.primary)
                                .cornerRadius(12)
                            }
                            .disabled(newComment.isEmpty || isSubmittingComment)
                        }
                    }
                }
                .padding()
                .confirmationDialog("Cambiar estado", isPresented: $showingStatusOptions, titleVisibility: .visible) {
                    Button("Pendiente") { updateStatus(.pending) }
                    Button("En progreso") { updateStatus(.inProgress) }
                    Button("Resuelto") { updateStatus(.resolved) }
                    Button("Cancelado") { updateStatus(.cancelled) }
                    Button("Cancelar", role: .cancel) { }
                }
            } else if !errorMessage.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.theme.pending)
                        .padding(.top, 60)
                    
                    Text(errorMessage)
                        .font(.system(size: 16))
                        .foregroundColor(.theme.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    Button(action: loadIncident) {
                        Text("Reintentar")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.theme.primary)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Detalles de incidencia")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.theme.background)
        .onAppear {
            loadIncident()
        }
    }
    
    private func loadIncident() {
        isLoading = true
        errorMessage = ""
        
        // For development without backend
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.incident = IncidentService.getSampleIncident(id: self.incidentId)
            if self.incident == nil {
                self.errorMessage = "No se pudo encontrar la incidencia"
            }
            self.isLoading = false
        }
        
        // When backend is ready, uncomment this:
        /*
        IncidentService.getIncident(id: incidentId) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let incident):
                    self.incident = incident
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
        */
    }
    
    private func updateStatus(_ newStatus: IncidentStatus) {
        guard var updatedIncident = incident else { return }
        updatedIncident.status = newStatus
        incident = updatedIncident
        
        // When backend is ready, uncomment this:
        /*
        let updates = IncidentUpdateRequest(status: newStatus.rawValue, assignedTo: nil)
        IncidentService.updateIncident(id: incidentId, updates: updates) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedIncident):
                    self.incident = updatedIncident
                case .failure(let error):
                    // Show error and revert to original status
                    print("Error updating status: \(error.localizedDescription)")
                    self.loadIncident()
                }
            }
        }
        */
    }
    
    private func submitComment() {
        guard !newComment.isEmpty, let incident = incident else { return }
        
        isSubmittingComment = true
        
        // For development without backend
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            let newCommentObj = Comment(
                id: Int.random(in: 100...1000),
                text: self.newComment,
                createdAt: Date(),
                userId: 1,
                userName: "Usuario Actual"
            )
            
            var updatedIncident = incident
            if updatedIncident.comments == nil {
                updatedIncident.comments = []
            }
            updatedIncident.comments?.append(newCommentObj)
            self.incident = updatedIncident
            self.newComment = ""
            self.isSubmittingComment = false
        }
        
        // When backend is ready, uncomment this:
        /*
        IncidentService.addComment(incidentId: incident.id, text: newComment) { result in
            DispatchQueue.main.async {
                self.isSubmittingComment = false
                
                switch result {
                case .success(_):
                    self.newComment = ""
                    self.loadIncident() // Reload to get updated comments
                case .failure(let error):
                    print("Error submitting comment: \(error.localizedDescription)")
                    // Show error toast
                }
            }
        }
        */
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.theme.textSecondary)
                .frame(width: 22)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.theme.textSecondary)
                
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.theme.textPrimary)
            }
        }
    }
}

struct CommentView: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(comment.userName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.theme.textPrimary)
                
                Spacer()
                
                Text(formatDate(comment.createdAt))
                    .font(.system(size: 12))
                    .foregroundColor(.theme.textSecondary)
            }
            
            Text(comment.text)
                .font(.system(size: 14))
                .foregroundColor(.theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.theme.border, lineWidth: 1)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationView {
        IncidentDetailView(incidentId: 1)
    }
}
