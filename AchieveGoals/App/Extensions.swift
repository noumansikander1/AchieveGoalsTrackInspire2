import SwiftUI
import Foundation

// MARK: - Date Extensions
extension Date {
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    func timeAgo() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day, .hour, .minute], from: self, to: now)
        
        if let days = components.day, days > 0 {
            return days == 1 ? "1 день назад" : "\(days) дн. назад"
        } else if let hours = components.hour, hours > 0 {
            return hours == 1 ? "1 час назад" : "\(hours) ч. назад"
        } else if let minutes = components.minute, minutes > 0 {
            return minutes == 1 ? "1 мин. назад" : "\(minutes) мин. назад"
        } else {
            return "только что"
        }
    }
}

// MARK: - String Extensions
extension String {
    var isValidURL: Bool {
        guard let url = URL(string: self) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    func extractWebLink(withToken token: String) -> String? {
        let components = self.components(separatedBy: token)
        if components.count >= 2 {
            return components[1]
        }
        return nil
    }
}

// MARK: - View Extensions
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), 
                                       to: nil, from: nil, for: nil)
    }
    
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Device Info
struct DeviceInfo {
    static var osVersion: String {
        UIDevice.current.systemVersion
    }
    
    static var deviceModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    static var language: String {
        Locale.current.language.languageCode?.identifier ?? "en"
    }
    
    static var country: String {
        Locale.current.region?.identifier ?? "US"
    }
}

