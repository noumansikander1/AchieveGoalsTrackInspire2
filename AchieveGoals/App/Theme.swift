import SwiftUI

struct AppTheme {
    // MARK: - Colors
    struct Colors {
        static let primary = Color("PrimaryColor")
        static let secondary = Color("SecondaryColor")
        static let background = Color("BackgroundColor")
        static let cardBackground = Color("CardBackground")
        static let textPrimary = Color("TextPrimary")
        static let textSecondary = Color("TextSecondary")
        static let accent = Color.yellow
        
        // Fallback colors if assets are not defined
        static let primaryFallback = Color(hex: "#FFD700")
        static let secondaryFallback = Color(hex: "#FFF8DC")
        static let backgroundFallback = Color(uiColor: .systemBackground)
        static let cardBackgroundFallback = Color(uiColor: .secondarySystemBackground)
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .medium, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 17, weight: .regular, design: .default)
        static let callout = Font.system(size: 16, weight: .regular, design: .default)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
        static let footnote = Font.system(size: 13, weight: .regular, design: .default)
        static let caption = Font.system(size: 12, weight: .regular, design: .default)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
    }
    
    // MARK: - Shadows
    struct Shadow {
        static let light = ShadowStyle(radius: 4, y: 2)
        static let medium = ShadowStyle(radius: 8, y: 4)
        static let heavy = ShadowStyle(radius: 16, y: 8)
    }
}

// MARK: - Shadow Style
struct ShadowStyle {
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    init(radius: CGFloat, x: CGFloat = 0, y: CGFloat) {
        self.radius = radius
        self.x = x
        self.y = y
    }
}

// MARK: - Color Extension for Hex
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
}

// MARK: - View Modifiers
struct CardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding(AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .fill(Color(uiColor: .secondarySystemBackground))
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), 
                           radius: 8, x: 0, y: 4)
            )
    }
}

extension View {
    func cardStyle() -> some View {
        self.modifier(CardModifier())
    }
    
    func fadeInAnimation(delay: Double = 0) -> some View {
        self.opacity(1)
            .transition(.opacity)
            .animation(.easeIn(duration: 0.3).delay(delay), value: UUID())
    }
}

