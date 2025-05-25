//
//  NotificationService.swift
//  incident_app
//
//  Created on 25/5/2025.
//

import Foundation
import UserNotifications
import Combine

class NotificationService: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()
    
    @Published var notificationPermissionGranted = false
    @Published var notificationMessages: [NotificationMessage] = []
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkNotificationPermissions()
        loadMessages()
    }
    
    // Request permission to display notifications
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.notificationPermissionGranted = granted
                if granted {
                    print("Notification permission granted")
                } else if let error = error {
                    print("Error requesting notification permission: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Check if we already have permission
    private func checkNotificationPermissions() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // Schedule a local notification
    func scheduleNotification(title: String, body: String, timeInterval: TimeInterval = 1) {
        // Only proceed if we have permission
        guard notificationPermissionGranted else {
            print("Cannot schedule notification: permission not granted")
            
            // Still add to our in-app notification center
            addNotificationMessage(title: title, body: body)
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully")
                
                // Also add to our in-app notification center
                self.addNotificationMessage(title: title, body: body)
            }
        }
    }
    
    // Notification for incident status change
    func notifyIncidentStatusChange(incident: Incident, oldStatus: String) {
        let title = "Incidencia \(incident.id) actualizada"
        let body = "La incidencia '\(incident.title)' ha cambiado de '\(statusName(oldStatus))' a '\(statusName(incident.status))'"
        
        scheduleNotification(title: title, body: body)
    }
    
    // Notification for new incident assignment
    func notifyNewIncidentAssigned(incident: Incident) {
        let title = "Nueva incidencia asignada"
        let body = "Se te ha asignado la incidencia '\(incident.title)' con urgencia \(urgencyName(incident.urgency))"
        
        scheduleNotification(title: title, body: body)
    }
    
    // Notification for new comment
    func notifyNewComment(incident: Incident, commenter: String) {
        let title = "Nuevo comentario en incidencia"
        let body = "\(commenter) ha comentado en la incidencia '\(incident.title)'"
        
        scheduleNotification(title: title, body: body)
    }
    
    // In-app notification messages
    func addNotificationMessage(title: String, body: String) {
        let message = NotificationMessage(
            id: UUID().uuidString,
            title: title,
            body: body,
            timestamp: Date()
        )
        
        notificationMessages.insert(message, at: 0)
        
        // Save the updated list
        saveMessages()
    }
    
    // Remove a notification message
    func removeNotificationMessage(id: String) {
        notificationMessages.removeAll { $0.id == id }
        saveMessages()
    }
    
    // Mark notification as read
    func markAsRead(id: String) {
        if let index = notificationMessages.firstIndex(where: { $0.id == id }) {
            notificationMessages[index].isRead = true
            saveMessages()
        }
    }
    
    // Clear all notifications
    func clearAllNotifications() {
        notificationMessages.removeAll()
        saveMessages()
    }
    
    // Save notification messages to UserDefaults
    private func saveMessages() {
        if let encoded = try? JSONEncoder().encode(notificationMessages) {
            UserDefaults.standard.set(encoded, forKey: "notificationMessages")
        }
    }
    
    // Load notification messages from UserDefaults
    private func loadMessages() {
        if let data = UserDefaults.standard.data(forKey: "notificationMessages"),
           let decoded = try? JSONDecoder().decode([NotificationMessage].self, from: data) {
            notificationMessages = decoded
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show the notification even when the app is in the foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Helper methods for status and urgency names
    private func statusName(_ status: String) -> String {
        switch status {
        case "pendiente": return "Pendiente"
        case "en_proceso": return "En Proceso"
        case "resuelta": return "Resuelta"
        case "cancelada": return "Cancelada"
        default: return status.capitalized
        }
    }
    
    private func urgencyName(_ urgency: String) -> String {
        switch urgency {
        case "baja": return "Baja"
        case "media": return "Media"
        case "alta": return "Alta"
        case "critica": return "Crítica"
        default: return urgency.capitalized
        }
    }
}

// Model for in-app notification messages
struct NotificationMessage: Identifiable, Codable {
    let id: String
    let title: String
    let body: String
    let timestamp: Date
    var isRead: Bool = false
}
