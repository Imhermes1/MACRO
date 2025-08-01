import Foundation
import SwiftUI

// MARK: - String Extensions
extension String {
    /// Check if string is not empty after trimming whitespace
    var isNotEmptyTrimmed: Bool {
        !trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Get trimmed version of string
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Check if string contains any of the given substrings (case insensitive)
    func containsAny(of substrings: [String]) -> Bool {
        let lowercased = self.lowercased()
        return substrings.contains { lowercased.contains($0.lowercased()) }
    }
    
    /// Safe regex matching
    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return results.compactMap { result in
                guard let range = Range(result.range, in: self) else { return nil }
                return String(self[range])
            }
        } catch {
            return []
        }
    }
}

// MARK: - View Extensions
extension View {
    /// Apply glassmorphism effect
    func glassEffect(
        cornerRadius: CGFloat = UIConstants.cardCornerRadius,
        strokeOpacity: Double = UIConstants.strokeOpacity
    ) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(strokeOpacity), lineWidth: 1)
            )
    }
    
    /// Apply standard padding
    func standardPadding() -> some View {
        self.padding(UIConstants.defaultPadding)
    }
    
    /// Apply chat bubble styling
    func chatBubbleStyle(
        cornerRadius: CGFloat = UIConstants.chatBubbleCornerRadius,
        maxWidth: CGFloat = UIConstants.chatBubbleMaxWidth
    ) -> some View {
        self
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: maxWidth, alignment: .leading)
    }
    
    /// Conditional modifier
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Color Extensions
extension Color {
    /// Create color from hex string
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

// MARK: - Date Extensions
extension Date {
    /// Check if date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// Get formatted time string
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    /// Get formatted date string
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
    
    /// Check if date is in same day as another date
    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }
}

// MARK: - Array Extensions
extension Array where Element: Identifiable {
    /// Remove element by ID
    mutating func remove(by id: Element.ID) {
        removeAll { $0.id == id }
    }
    
    /// Find element by ID
    func first(by id: Element.ID) -> Element? {
        first { $0.id == id }
    }
}

// MARK: - Double Extensions
extension Double {
    /// Format as integer string
    var intString: String {
        String(Int(self))
    }
    
    /// Format with one decimal place
    var oneDecimalString: String {
        String(format: "%.1f", self)
    }
    
    /// Format as calories string
    var caloriesString: String {
        "\(Int(self)) cal"
    }
    
    /// Format as grams string
    var gramsString: String {
        "\(oneDecimalString)g"
    }
}

// MARK: - Binding Extensions
extension Binding {
    /// Create a binding that ignores writes
    static func constant(_ value: Value) -> Binding<Value> {
        Binding(
            get: { value },
            set: { _ in }
        )
    }
}

// MARK: - Animation Extensions
extension Animation {
    static var standardSpring: Animation {
        .spring(response: 0.4, dampingFraction: 0.7)
    }
    
    static var quickEase: Animation {
        .easeOut(duration: 0.2)
    }
    
    static var standardEase: Animation {
        .easeOut(duration: UIConstants.defaultAnimationDuration)
    }
}