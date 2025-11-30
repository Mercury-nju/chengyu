import SwiftUI

extension Color {
    static let neonBlack = Color(red: 0.05, green: 0.05, blue: 0.05)
    static let zenGray = Color(red: 0.2, green: 0.2, blue: 0.2)
    static let anchorWhite = Color(red: 0.95, green: 0.95, blue: 0.95)
    static let dopamineBlue = Color(red: 0.1, green: 0.4, blue: 0.9) // Subtle accent
    
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
}

struct Theme {
    static let background = Color.neonBlack
    static let text = Color.anchorWhite
    static let secondaryText = Color.zenGray
    static let zenGray = Color.zenGray
    static let dopamineBlue = Color.dopamineBlue

    
    // Minimalist font modifiers
    static func fontTitle() -> Font {
        return .system(size: 28, weight: .bold, design: .rounded)
    }
    
    static func fontBody() -> Font {
        return .system(size: 16, weight: .medium, design: .default)
    }
    
    static func fontCaption() -> Font {
        return .system(size: 12, weight: .regular, design: .monospaced)
    }
}

// MARK: - Shared Button Styles

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
