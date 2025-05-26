import SwiftUI

struct FilterTabs: View {
    var activeFilter: String
    var onFilterChange: (String) -> Void
    
    private let filters = [
        Filter(id: "all", label: "Todos"),
        Filter(id: "pending", label: "Pendientes"),
        Filter(id: "in_progress", label: "En Progreso"),
        Filter(id: "resolved", label: "Resueltos"),
        Filter(id: "cancelled", label: "Cancelados")
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filters, id: \.id) { filter in
                    FilterButton(
                        title: filter.label,
                        isSelected: activeFilter == filter.id,
                        color: filterColor(filter.id)
                    ) {
                        onFilterChange(filter.id)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
    
    private func filterColor(_ filterId: String) -> Color {
        switch filterId {
        case "all":
            return .theme.primary
        case "pending":
            return .theme.pending
        case "in_progress":
            return .theme.inProgress
        case "resolved":
            return .theme.resolved
        case "cancelled":
            return .theme.cancelled
        default:
            return .theme.primary
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .theme.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? color : Color.white
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? color : Color.theme.border, lineWidth: 1)
                )
        }
    }
}

struct Filter {
    let id: String
    let label: String
}

#Preview {
    VStack {
        FilterTabs(activeFilter: "all") { newFilter in
            print("Filter changed to: \(newFilter)")
        }
    }
    .padding(.vertical)
    .background(Color.theme.background)
}
