//
//  NotificationsView.swift
//  incident_app
//
//  Created on 25/5/2025.
//

import SwiftUI

struct NotificationsView: View {
    @ObservedObject private var notificationService = NotificationService.shared
    @State private var showingConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if notificationService.notificationMessages.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No hay notificaciones")
                            .font(.headline)
                        
                        Text("Las notificaciones sobre incidencias aparecerán aquí")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                } else {
                    // List of notifications
                    List {
                        ForEach(notificationService.notificationMessages) { message in
                            NotificationRow(message: message)
                                .onTapGesture {
                                    notificationService.markAsRead(id: message.id)
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        notificationService.removeNotificationMessage(id: message.id)
                                    } label: {
                                        Label("Eliminar", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Notificaciones")
            .navigationBarItems(
                trailing: Button(action: {
                    if !notificationService.notificationMessages.isEmpty {
                        showingConfirmation = true
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(notificationService.notificationMessages.isEmpty ? .gray : .red)
                }
                .disabled(notificationService.notificationMessages.isEmpty)
            )
            .alert("¿Borrar todas las notificaciones?", isPresented: $showingConfirmation) {
                Button("Cancelar", role: .cancel) { }
                Button("Borrar", role: .destructive) {
                    notificationService.clearAllNotifications()
                }
            } message: {
                Text("Esta acción no se puede deshacer.")
            }
        }
    }
}

struct NotificationRow: View {
    let message: NotificationMessage
    
    var body: some View {
        HStack(alignment: .top) {
            // Unread indicator
            if !message.isRead {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
                    .padding(.top, 6)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 10, height: 10)
                    .padding(.top, 6)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(message.title)
                    .font(.headline)
                    .fontWeight(message.isRead ? .regular : .semibold)
                
                Text(message.body)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(timeAgo(from: message.timestamp))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
    
    // Format the timestamp as a relative time string
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
