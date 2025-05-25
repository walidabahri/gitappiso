//
//  CreateIncidentViewModel.swift
//  incident_app
//
//  Created on 25/5/2025.
//

import Foundation
import Combine
import CoreLocation

class CreateIncidentViewModel: ObservableObject {
    @Published var title = ""
    @Published var description = ""
    @Published var location = ""
    @Published var urgency = "media" // Default to medium urgency
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var incidentCreated = false
    @Published var currentLocation: CLLocation? = nil
    
    private var apiService = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    private var locationManager: CLLocationManager?
    
    let urgencyOptions = ["baja", "media", "alta", "critica"]
    
    func createIncident() {
        guard isValid else {
            errorMessage = "Please fill in all required fields"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let request = CreateIncidentRequest(
            title: title,
            description: description,
            location: location,
            urgency: urgency
        )
        
        apiService.createIncident(request)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] _ in
                self?.incidentCreated = true
                self?.resetForm()
            })
            .store(in: &cancellables)
    }
    
    func startLocationUpdates() {
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        
        NotificationCenter.default.publisher(for: .locationUpdate)
            .compactMap { $0.object as? CLLocation }
            .sink { [weak self] location in
                self?.currentLocation = location
                self?.updateLocationString(from: location)
            }
            .store(in: &cancellables)
    }
    
    private func updateLocationString(from location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let placemark = placemarks?.first else {
                self?.location = "\(location.coordinate.latitude), \(location.coordinate.longitude)"
                return
            }
            
            let address = [
                placemark.thoroughfare,
                placemark.locality,
                placemark.administrativeArea,
                placemark.country
            ].compactMap { $0 }.joined(separator: ", ")
            
            self?.location = address
        }
    }
    
    private func resetForm() {
        title = ""
        description = ""
        // Keep the location as it might be useful for the next incident
        urgency = "media"
    }
    
    var isValid: Bool {
        return !title.isEmpty && !description.isEmpty && !location.isEmpty
    }
}

// Extension to handle location updates
extension Notification.Name {
    static let locationUpdate = Notification.Name("locationUpdate")
}
