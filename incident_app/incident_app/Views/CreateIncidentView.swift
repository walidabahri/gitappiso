//
//  CreateIncidentView.swift
//  incident_app
//
//  Created on 25/5/2025.
//

import SwiftUI
import CoreLocation

struct FormField: View {
    let icon: String
    let title: String
    let placeholder: String
    @Binding var text: String
    var isMultiline: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.bodyMedium.weight(.medium))
                .foregroundColor(.theme.textPrimary)
            
            HStack(alignment: isMultiline ? .top : .center, spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.theme.secondary)
                    .frame(width: 24, height: isMultiline ? 24 : nil)
                    .padding(.top, isMultiline ? 12 : 0)
                
                if isMultiline {
                    ZStack(alignment: .topLeading) {
                        if text.isEmpty {
                            Text(placeholder)
                                .font(.bodyMedium)
                                .foregroundColor(.theme.textSecondary.opacity(0.5))
                                .padding(.top, 12)
                                .padding(.leading, 4)
                        }
                        
                        TextEditor(text: $text)
                            .frame(minHeight: 120)
                            .font(.bodyMedium)
                            .foregroundColor(.theme.textPrimary)
                    }
                } else {
                    TextField(placeholder, text: $text)
                        .font(.bodyMedium)
                        .foregroundColor(.theme.textPrimary)
                }
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.theme.border, lineWidth: 1)
            )
        }
    }
}

struct CreateIncidentView: View {
    @StateObject private var viewModel = CreateIncidentViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.theme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Nueva Incidencia")
                                .font(.titleMedium)
                                .foregroundColor(.theme.textPrimary)
                            
                            Text("Complete el formulario para crear una nueva incidencia")
                                .font(.bodyMedium)
                                .foregroundColor(.theme.textSecondary)
                                .lineLimit(2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Form fields
                        VStack(spacing: 20) {
                            // Title field
                            FormField(
                                icon: "doc.text",
                                title: "Título",
                                placeholder: "Título de la incidencia",
                                text: $viewModel.title
                            )
                            
                            // Description field
                            FormField(
                                icon: "square.and.pencil",
                                title: "Descripción",
                                placeholder: "Descripción detallada de la incidencia",
                                text: $viewModel.description,
                                isMultiline: true
                            )
                            
                            // Location field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Ubicación")
                                    .font(.bodyMedium.weight(.medium))
                                    .foregroundColor(.theme.textPrimary)
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.theme.secondary)
                                        .frame(width: 24)
                                    
                                    TextField("Ubicación", text: $viewModel.location)
                                        .font(.bodyMedium)
                                        .foregroundColor(.theme.textPrimary)
                                    
                                    Button(action: {
                                        viewModel.startLocationUpdates()
                                    }) {
                                        Image(systemName: "location.fill")
                                            .foregroundColor(.theme.secondary)
                                            .frame(width: 44, height: 44)
                                            .background(Color.theme.secondary.opacity(0.1))
                                            .clipShape(Circle())
                                    }
                                }
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.theme.border, lineWidth: 1)
                                )
                                
                                if let location = viewModel.currentLocation {
                                    HStack {
                                        Image(systemName: "mappin.and.ellipse")
                                            .foregroundColor(.theme.textSecondary)
                                        Text("Lat: \(String(format: "%.4f", location.coordinate.latitude)), Lon: \(String(format: "%.4f", location.coordinate.longitude))")
                                            .font(.bodySmall)
                                            .foregroundColor(.theme.textSecondary)
                                    }
                                    .padding(.horizontal, 4)
                                    .padding(.top, 4)
                                }
                            }
                            
                            // Urgency picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Prioridad")
                                    .font(.bodyMedium.weight(.medium))
                                    .foregroundColor(.theme.textPrimary)
                                
                                VStack(spacing: 12) {
                                    Picker("Urgencia", selection: $viewModel.urgency) {
                                        Text("Baja").tag("baja")
                                        Text("Media").tag("media")
                                        Text("Alta").tag("alta")
                                        Text("Crítica").tag("critica")
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    
                                    // Preview of the selected urgency
                                    HStack {
                                        Spacer()
                                        UrgencyIndicator(urgencyString: viewModel.urgency)
                                        Spacer()
                                    }
                                }
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.theme.border, lineWidth: 1)
                                )
                            }
                        }
                        
                        // Submit button
                        Button(action: viewModel.createIncident) {
                            HStack {
                                Spacer()
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Crear Incidencia")
                                        .font(.bodyLarge.weight(.semibold))
                                        .foregroundColor(.white)
                                }
                                Spacer()
                            }
                            .frame(height: 56)
                            .background(viewModel.isValid ? Color.theme.primary : Color.gray.opacity(0.5))
                            .cornerRadius(12)
                        }
                        .disabled(!viewModel.isValid || viewModel.isLoading)
                        .padding(.vertical, 8)
                    }
                    .padding()
                }
                
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
                
                // Success message
                if viewModel.incidentCreated {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .overlay(
                            VStack(spacing: 20) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.theme.resolved)
                                
                                Text("¡Incidencia Creada!")
                                    .font(.titleMedium)
                                    .foregroundColor(.theme.textPrimary)
                                
                                Text("La incidencia ha sido creada correctamente")
                                    .font(.bodyMedium)
                                    .foregroundColor(.theme.textSecondary)
                                    .multilineTextAlignment(.center)
                                
                                Button("Volver") {
                                    viewModel.incidentCreated = false
                                }
                                .font(.bodyMedium.weight(.semibold))
                                .foregroundColor(.white)
                                .frame(height: 50)
                                .frame(minWidth: 150)
                                .background(Color.theme.primary)
                                .cornerRadius(12)
                                .padding(.top, 10)
                            }
                            .padding(30)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.2), radius: 20)
                            .padding(30)
                        )
                        .transition(.opacity)
                        .animation(.easeInOut, value: viewModel.incidentCreated)
                }
            }
            .onAppear {
                viewModel.startLocationUpdates()
            }
        }
    }
}
