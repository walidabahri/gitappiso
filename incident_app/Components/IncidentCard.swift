import SwiftUI

struct IncidentCard: View {
    let incident: Incident
    var onPress: () -> Void
    
    var body: some View {
        Button(action: onPress) {
            VStack(alignment: .leading, spacing: 12) {
                // Status and urgency indicators
                HStack {
                    StatusBadge(status: incident.status)
                    Spacer()
                    UrgencyIndicator(urgency: incident.urgency)
                }
                
                // Title
                Text(incident.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.theme.textPrimary)
                    .lineLimit(2)
                
                // Description
                Text(incident.description)
                    .font(.system(size: 14))
                    .foregroundColor(.theme.textSecondary)
                    .lineLimit(2)
                
                // Location and timestamp
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.theme.textSecondary)
                        Text(incident.location)
                            .lineLimit(1)
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.theme.textSecondary)
                    
                    Spacer()
                    
                    Text(formatDate(incident.createdAt))
                        .font(.system(size: 12))
                        .foregroundColor(.theme.textSecondary)
                }
            }
            .padding(16)
            .background(Color.theme.card)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct HistoryCard: View {
    let incident: Incident
    var onPress: () -> Void
    
    var body: some View {
        Button(action: onPress) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        // Title
                        Text(incident.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.theme.textPrimary)
                            .lineLimit(1)
                        
                        // Location
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.theme.textSecondary)
                            Text(incident.location)
                                .lineLimit(1)
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.theme.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Status badge
                    StatusBadge(status: incident.status)
                }
                
                // Date and urgency
                HStack {
                    Text(formatDate(incident.updatedAt))
                        .font(.system(size: 12))
                        .foregroundColor(.theme.textSecondary)
                    
                    Spacer()
                    
                    UrgencyIndicator(urgency: incident.urgency)
                }
            }
            .padding(16)
            .background(Color.theme.card)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
}

#Preview {
    VStack(spacing: 20) {
        IncidentCard(incident: Incident.sampleData[0]) {
            print("Tapped incident")
        }
        
        HistoryCard(incident: Incident.sampleData[2]) {
            print("Tapped history item")
        }
    }
    .padding()
    .background(Color.theme.background)
}
