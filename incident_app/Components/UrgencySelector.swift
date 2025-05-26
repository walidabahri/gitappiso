import SwiftUI

struct UrgencySelector: View {
    @Binding var selected: UrgencyLevel
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(UrgencyLevel.allCases, id: \.self) { level in
                UrgencyButton(
                    level: level,
                    isSelected: selected == level,
                    action: {
                        selected = level
                    }
                )
            }
        }
    }
}

struct UrgencyButton: View {
    let level: UrgencyLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                ZStack {
                    Circle()
                        .fill(level.color)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .stroke(level.color, lineWidth: 2)
                            .frame(width: 32, height: 32)
                    }
                }
                
                Text(level.displayText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.theme.textPrimary)
                
                Spacer()
                
                Text(urgencyDescription(level))
                    .font(.system(size: 14))
                    .foregroundColor(.theme.textSecondary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.theme.card)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? level.color : Color.theme.border, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func urgencyDescription(_ level: UrgencyLevel) -> String {
        switch level {
        case .low:
            return "24-48 horas"
        case .medium:
            return "12-24 horas"
        case .high:
            return "2-6 horas"
        case .critical:
            return "Inmediato"
        }
    }
}

#Preview {
    VStack {
        UrgencySelector(selected: .constant(.medium))
    }
    .padding()
    .background(Color.theme.background)
}
