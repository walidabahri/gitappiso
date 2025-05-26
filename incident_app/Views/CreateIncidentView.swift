import SwiftUI
import CoreLocation

struct CreateIncidentView: View {
    @State private var title = ""
    @State private var description = ""
    @State private var location = ""
    @State private var urgency: UrgencyLevel = .medium
    @State private var showLocationOptions = false
    @State private var isSubmitting = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var showError = false
    @Environment(\.presentationMode) var presentationMode
    
    // Location manager properties
    @State private var locationManager: CLLocationManager?
    @State private var currentLocation: CLLocationCoordinate2D?
    @State private var isGettingLocation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Basic Information Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Información Básica")
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Título de la incidencia*")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.theme.textSecondary)
                            
                            TextField("Ej: Fuga de agua en tubería principal", text: $title)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.theme.border, lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Descripción*")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.theme.textSecondary)
                            
                            TextEditor(text: $description)
                                .frame(minHeight: 120)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.theme.border, lineWidth: 1)
                                )
                        }
                    }
                    
                    // Location Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Ubicación")
                        
                        HStack {
                            TextField("Ubicación del incidente", text: $location)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.theme.border, lineWidth: 1)
                                )
                            
                            Button(action: {
                                showLocationOptions = true
                            }) {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.white)
                                    .frame(width: 48, height: 48)
                                    .background(Color.theme.secondary)
                                    .cornerRadius(12)
                            }
                        }
                        
                        if isGettingLocation {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                Text("Obteniendo ubicación...")
                                    .font(.system(size: 14))
                                    .foregroundColor(.theme.textSecondary)
                            }
                            .padding(.vertical, 4)
                        }
                        
                        if let coordinates = currentLocation {
                            Text("Coordenadas: \(String(format: "%.6f", coordinates.latitude)), \(String(format: "%.6f", coordinates.longitude))")
                                .font(.system(size: 12))
                                .foregroundColor(.theme.textSecondary)
                        }
                    }
                    
                    // Urgency Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Nivel de Urgencia")
                        
                        UrgencySelector(selected: $urgency)
                    }
                    
                    // Error message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(.vertical, 8)
                    }
                    
                    // Submit button
                    Button(action: submitIncident) {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Reportar Incidencia")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(canSubmit ? Color.theme.primary : Color.gray.opacity(0.5))
                        .cornerRadius(12)
                    }
                    .disabled(!canSubmit || isSubmitting)
                }
                .padding()
            }
            .background(Color.theme.background)
            .navigationTitle("Reportar Incidencia")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .confirmationDialog("Ubicación", isPresented: $showLocationOptions) {
                Button("Usar mi ubicación actual") {
                    getCurrentLocation()
                }
                Button("Seleccionar en el mapa") {
                    // Would launch a map picker in a real implementation
                }
                Button("Cancelar", role: .cancel) { }
            }
            .alert("Incidencia reportada", isPresented: $showSuccess) {
                Button("Aceptar") {
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("Su incidencia ha sido reportada correctamente.")
            }
            .alert("Error", isPresented: $showError) {
                Button("Aceptar") { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                setupLocationManager()
            }
        }
    }
    
    private var canSubmit: Bool {
        return !title.isEmpty && !description.isEmpty && !location.isEmpty
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func getCurrentLocation() {
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            errorMessage = "El acceso a la ubicación está restringido. Por favor, habilítelo en los ajustes."
        case .authorizedAlways, .authorizedWhenInUse:
            isGettingLocation = true
            
            // Simulate location acquisition for preview
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.isGettingLocation = false
                self.currentLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
                self.location = "Ubicación actual detectada"
            }
            
            // In a real implementation:
            /*
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            */
        @unknown default:
            break
        }
    }
    
    private func submitIncident() {
        guard canSubmit else { return }
        
        isSubmitting = true
        errorMessage = ""
        
        // For development without backend
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSubmitting = false
            showSuccess = true
            
            // Reset form
            title = ""
            description = ""
            location = ""
            urgency = .medium
            currentLocation = nil
        }
        
        // When backend is ready, uncomment this:
        /*
        let request = IncidentCreateRequest(
            title: title,
            description: description,
            location: location,
            latitude: currentLocation?.latitude,
            longitude: currentLocation?.longitude,
            urgency: urgency.rawValue
        )
        
        IncidentService.createIncident(incident: request) { result in
            DispatchQueue.main.async {
                isSubmitting = false
                
                switch result {
                case .success(_):
                    showSuccess = true
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
        */
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.theme.textPrimary)
    }
}

#Preview {
    CreateIncidentView()
}
