//
//  IncidentsListView.swift
//  incident_app
//
//  Created on 25/5/2025.
//

import SwiftUI

struct IncidentsListView: View {
    @StateObject private var viewModel = IncidentsViewModel()
    @EnvironmentObject private var authService: AuthService
    
    var body: some View {
        ZStack {
            // Background
            Color.theme.background
                .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    if let user = authService.currentUser {
                        Text("Hola, \(user.firstName)")
                            .font(.titleMedium)
                            .foregroundColor(.theme.textPrimary)
                            .padding(.horizontal)
                        
                        Text("Tus incidencias asignadas")
                            .font(.bodyLarge)
                            .foregroundColor(.theme.textSecondary)
                            .padding(.horizontal)
                    } else {
                        Text("Mis Incidencias")
                            .font(.titleMedium)
                            .foregroundColor(.theme.textPrimary)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if viewModel.incidents.isEmpty && !viewModel.isLoading {
                    // Empty state
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.theme.textSecondary.opacity(0.5))
                        
                        Text("No hay incidencias asignadas")
                            .font(.titleSmall)
                            .foregroundColor(.theme.textPrimary)
                        
                        Text("Las incidencias asignadas aparecerán aquí")
                            .font(.bodyMedium)
                            .foregroundColor(.theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: viewModel.loadIncidents) {
                            Text("Recargar")
                                .font(.bodyMedium.weight(.semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(Color.theme.primary)
                                .clipShape(Capsule())
                        }
                        .padding(.top, 16)
                    }
                    .padding()
                    
                    Spacer()
                } else {
                    // List of incidents
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.incidents) { incident in
                                NavigationLink(destination: IncidentDetailView(incidentId: incident.id)) {
                                    IncidentCard(incident: incident)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                    .refreshable {
                        viewModel.refresh()
                    }
                }
            }
            
            // Error overlay
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
        .navigationBarItems(
            trailing: Button(action: {
                viewModel.loadIncidents()
            }) {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.theme.primary)
            }
        )
        .onAppear {
            viewModel.loadIncidents()
        }
    }
}
