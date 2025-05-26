import SwiftUI

struct IncidentsListView: View {
    @State private var incidents: [Incident] = []
    @State private var isLoading = true
    @State private var errorMessage = ""
    @State private var activeFilter = "all"
    @State private var isRefreshing = false
    @State private var unreadNotifications = 3 // Placeholder value
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Incidencias activas")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.theme.textPrimary)
                    
                    Spacer()
                    
                    NavigationLink(destination: NotificationsView()) {
                        ZStack {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.theme.textPrimary)
                            
                            // Notification badge
                            if unreadNotifications > 0 {
                                Text("\(unreadNotifications)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(Color.theme.critical)
                                    .clipShape(Circle())
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.theme.background)
                
                // Filter tabs
                FilterTabs(activeFilter: activeFilter) { newFilter in
                    activeFilter = newFilter
                }
                
                if isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                    Spacer()
                } else if !errorMessage.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.theme.pending)
                        
                        Text(errorMessage)
                            .font(.system(size: 16))
                            .foregroundColor(.theme.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: fetchIncidents) {
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
                    Spacer()
                } else {
                    // Incidents list
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredIncidents) { incident in
                                IncidentCard(incident: incident) {
                                    // Navigate to incident detail
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        await refresh()
                    }
                    
                    // Empty state
                    if filteredIncidents.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "tray")
                                .font(.system(size: 50))
                                .foregroundColor(.theme.textSecondary.opacity(0.5))
                            
                            Text(activeFilter == "all" ? 
                                 "No hay incidencias activas" : 
                                 "No hay incidencias en estado \(getFilterDisplayName(activeFilter))")
                                .font(.system(size: 16))
                                .foregroundColor(.theme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        Spacer()
                    }
                }
            }
            .background(Color.theme.background)
            .navigationBarHidden(true)
        }
        .onAppear {
            fetchIncidents()
        }
    }
    
    private var filteredIncidents: [Incident] {
        if activeFilter == "all" {
            return incidents
        } else {
            return incidents.filter { $0.status.rawValue == activeFilter }
        }
    }
    
    private func getFilterDisplayName(_ filter: String) -> String {
        switch filter {
        case "pending": return "pendiente"
        case "in_progress": return "en progreso"
        case "resolved": return "resuelto"
        case "cancelled": return "cancelado"
        default: return ""
        }
    }
    
    private func fetchIncidents() {
        isLoading = true
        errorMessage = ""
        
        // For development without backend
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.incidents = IncidentService.getSampleIncidents()
            self.isLoading = false
        }
        
        // When backend is ready, uncomment this:
        /*
        IncidentService.getIncidents { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let incidents):
                    self.incidents = incidents
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
        */
    }
    
    private func refresh() async {
        isRefreshing = true
        
        // Simulate network request
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        // For development without backend
        incidents = IncidentService.getSampleIncidents()
        
        isRefreshing = false
    }
}

// Placeholder for NotificationsView
struct NotificationsView: View {
    var body: some View {
        Text("Notifications View")
            .navigationTitle("Notificaciones")
    }
}

#Preview {
    IncidentsListView()
}
