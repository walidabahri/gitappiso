import SwiftUI

struct StatusBadge: View {
    let status: IncidentStatus
    
    var body: some View {
        Text(status.displayText)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(status.color)
            .clipShape(Capsule())
    }
}

struct UrgencyIndicator: View {
    let urgency: UrgencyLevel
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 10))
            Text(urgency.displayText)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(urgency.color)
        .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 10) {
            StatusBadge(status: .pending)
            StatusBadge(status: .inProgress)
            StatusBadge(status: .resolved)
            StatusBadge(status: .cancelled)
        }
        
        HStack(spacing: 10) {
            UrgencyIndicator(urgency: .low)
            UrgencyIndicator(urgency: .medium)
            UrgencyIndicator(urgency: .high)
            UrgencyIndicator(urgency: .critical)
        }
    }
    .padding()
    .previewLayout(.sizeThatFits)
}
