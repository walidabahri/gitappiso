//
//  HistoryView.swift
//  incident_app
//
//  Created on 25/5/2025.
//

import SwiftUI
import Combine

class HistoryViewModel: ObservableObject {
    @Published var resolvedIncidents: [Incident] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var dateFilter: DateFilter = .lastWeek
    
    private var apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    
    enum DateFilter: String, CaseIterable, Identifiable {
        case today = "Hoy"
        case lastWeek = "Última semana"
        case lastMonth = "Último mes"
        case all = "Todas"
        
        var id: String { self.rawValue }
    }
    
    func loadResolvedIncidents() {
        isLoading = true
        errorMessage = nil
        
        // In a real implementation, we would include date filter parameters in the API call
        // For now, we'll filter client-side
        apiService.getAllIncidents()
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] incidents in
                // Filter incidents that are resolved and match the date filter
                self?.resolvedIncidents = incidents.filter { incident in
                    // Filter by status
                    let isResolved = incident.status == "resuelta"
                    
                    // Apply date filter if needed
                    guard isResolved, let self = self else { return false }
                    
                    // Skip date filtering if "all" is selected
                    if self.dateFilter == .all { return true }
                    
                    // Parse the date
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    
                    guard let incidentDate = dateFormatter.date(from: incident.createdAt) else {
                        return true // Include if we can't parse the date
                    }
                    
                    let calendar = Calendar.current
                    let now = Date()
                    
                    switch self.dateFilter {
                    case .today:
                        return calendar.isDateInToday(incidentDate)
                    case .lastWeek:
                        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
                        return incidentDate >= oneWeekAgo
                    case .lastMonth:
                        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
                        return incidentDate >= oneMonthAgo
                    case .all:
                        return true
                    }
                }
            })
            .store(in: &cancellables)
    }
}

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // Date filter picker
                    Picker("Filtrar por fecha", selection: $viewModel.dateFilter) {
                        ForEach(HistoryViewModel.DateFilter.allCases) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .onChange(of: viewModel.dateFilter) { _ in
                        viewModel.loadResolvedIncidents()
                    }
                    
                    if viewModel.resolvedIncidents.isEmpty && !viewModel.isLoading {
                        // Empty state
                        VStack(spacing: 20) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No hay incidencias resueltas")
                                .font(.headline)
                            
                            Text("Las incidencias resueltas aparecerán aquí")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button(action: viewModel.loadResolvedIncidents) {
                                Text("Recargar")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 10)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            .padding(.top)
                        }
                        .padding()
                    } else {
                        // List of resolved incidents
                        List {
                            ForEach(viewModel.resolvedIncidents) { incident in
                                NavigationLink(destination: IncidentDetailView(incidentId: incident.id)) {
                                    HistoryIncidentRow(incident: incident)
                                }
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                        .refreshable {
                            viewModel.loadResolvedIncidents()
                        }
                    }
                }
                
                // Error overlay
                if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Spacer()
                        
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                            Text(errorMessage)
                            Spacer()
                            Button(action: {
                                viewModel.errorMessage = nil
                            }) {
                                Image(systemName: "xmark.circle.fill")
                            }
                        }
                        .padding()
                        .background(Color.red.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                    }
                }
                
                // Loading overlay
                if viewModel.isLoading {
                    Color.black.opacity(0.1)
                        .edgesIgnoringSafeArea(.all)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                }
            }
            .navigationTitle("Historial")
            .navigationBarItems(
                trailing: Button(action: {
                    viewModel.loadResolvedIncidents()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            )
            .onAppear {
                viewModel.loadResolvedIncidents()
            }
        }
    }
}

struct HistoryIncidentRow: View {
    let incident: Incident
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(incident.title)
                    .font(.headline)
                Spacer()
                Text("Resuelta")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(6)
            }
            
            Text(incident.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                Text(incident.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}
