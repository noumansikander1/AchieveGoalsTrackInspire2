import SwiftUI

// MARK: - Color Assets Extension
extension Color {
    // Primary Colors
    static let appPrimary = Color("PrimaryColor", fallback: Color(hex: "#FFD700"))
    static let appSecondary = Color("SecondaryColor", fallback: Color(hex: "#FFF8DC"))
    static let appAccent = Color("AccentColor", fallback: Color(hex: "#FFD700"))
    
    // Background Colors
    static let appBackground = Color("BackgroundColor", fallback: Color(uiColor: .systemBackground))
    static let appCardBackground = Color("CardBackground", fallback: Color(uiColor: .secondarySystemBackground))
    
    // Text Colors
    static let appTextPrimary = Color("TextPrimary", fallback: Color.primary)
    static let appTextSecondary = Color("TextSecondary", fallback: Color.secondary)
    
    // Semantic Colors
    static let appSuccess = Color.green
    static let appWarning = Color.orange
    static let appError = Color.red
    static let appInfo = Color.blue
    
    init(_ name: String, fallback: Color) {
        if let color = UIColor(named: name) {
            self.init(uiColor: color)
        } else {
            self = fallback
        }
    }
}

