//
//  ProfileViewModel.swift
//  incident_app
//
//  Created on 25/5/2025.
//

import SwiftUI
import Combine

class ProfileViewModel: ObservableObject {
    // User preferences
    @Published var notificationsEnabled: Bool = true
    @Published var darkModeEnabled: Bool = false
    @Published var useMobileData: Bool = true
    
    // User statistics
    @Published var reportedIncidents: Int = 0
    @Published var resolvedIncidents: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService = APIService.shared
    
    init() {
        loadUserPreferences()
        loadUserStatistics()
    }
    
    private func loadUserPreferences() {
        // In a real app, these would be loaded from UserDefaults or a server
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        darkModeEnabled = UserDefaults.standard.bool(forKey: "darkModeEnabled")
        useMobileData = UserDefaults.standard.bool(forKey: "useMobileData")
        
        // Set up observers for saving preferences
        $notificationsEnabled
            .dropFirst()
            .sink { [weak self] value in
                UserDefaults.standard.set(value, forKey: "notificationsEnabled")
                self?.updateUserPreferences()
            }
            .store(in: &cancellables)
        
        $darkModeEnabled
            .dropFirst()
            .sink { [weak self] value in
                UserDefaults.standard.set(value, forKey: "darkModeEnabled")
                self?.updateUserPreferences()
            }
            .store(in: &cancellables)
        
        $useMobileData
            .dropFirst()
            .sink { [weak self] value in
                UserDefaults.standard.set(value, forKey: "useMobileData")
                self?.updateUserPreferences()
            }
            .store(in: &cancellables)
    }
    
    private func loadUserStatistics() {
        // In a real app, this would be loaded from an API
        apiService.getUserStatistics()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching user statistics: \(error.localizedDescription)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] stats in
                self?.reportedIncidents = stats.reportedIncidents
                self?.resolvedIncidents = stats.resolvedIncidents
            })
            .store(in: &cancellables)
    }
    
    private func updateUserPreferences() {
        // In a real app, this would sync with a server
        // For now, we'll just simulate a server update
        print("User preferences updated")
    }
}
