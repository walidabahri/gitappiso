import SwiftUI

// Extension to create colors from hex values
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    static let theme = ThemeColors()
}

struct ThemeColors {
    // Primary Colors
    let primary = Color(hex: "#264653")
    let secondary = Color(hex: "#2A9D8F")
    
    // Status Colors
    let pending = Color(hex: "#F4A261")    // Yellow
    let inProgress = Color(hex: "#457B9D") // Blue
    let resolved = Color(hex: "#2A9D8F")   // Green
    let cancelled = Color(hex: "#A0AEC0")  // Gray
    
    // Urgency Colors
    let low = Color(hex: "#2A9D8F")       // Green
    let medium = Color(hex: "#457B9D")    // Blue
    let high = Color(hex: "#F4A261")      // Orange
    let critical = Color(hex: "#E76F51")  // Red
    
    // Background Colors
    let background = Color(hex: "#F5F7FA")
    let card = Color.white
    let border = Color(hex: "#E0E4EC")
    
    // Text Colors
    let textPrimary = Color(hex: "#264653")
    let textSecondary = Color(hex: "#4A6572")
}
