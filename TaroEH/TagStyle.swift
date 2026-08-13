import SwiftUI
import UIKit

/// Visual styling for gallery tags: a soft background color per E-Hentai
/// namespace (adapted from JHenTai's palette) plus a readable text color.
enum TagStyle {
    static let defaultBackground = Color(red: 0.92, green: 0.90, blue: 0.98)

    private static let palette: [String: Color] = [
        "language": Color(red: 0.96, green: 0.87, blue: 0.96),
        "artist": Color(red: 0.80, green: 0.85, blue: 0.80),
        "character": Color(red: 0.78, green: 0.78, blue: 0.90),
        "female": Color(red: 0.86, green: 0.81, blue: 0.93),
        "male": Color(red: 0.99, green: 0.84, blue: 0.84),
        "parody": Color(red: 0.93, green: 0.83, blue: 0.77),
        "group": Color(red: 0.87, green: 0.84, blue: 0.97),
        "mixed": Color(red: 0.84, green: 0.88, blue: 0.97),
        "cosplayer": Color(red: 0.96, green: 0.86, blue: 0.95),
        "reclass": Color(red: 0.96, green: 0.86, blue: 0.91),
        "temp": Color(red: 0.91, green: 0.86, blue: 0.98),
        "location": Color(red: 0.96, green: 0.87, blue: 0.96),
        "other": Color(red: 0.98, green: 0.86, blue: 0.86)
    ]

    /// Background color for a tag chip based on its namespace.
    static func background(for namespace: String) -> Color {
        palette[namespace.lowercased()] ?? defaultBackground
    }

    /// Foreground color that stays readable on the namespace background.
    static func foreground(for namespace: String) -> Color {
        background(for: namespace).isLight ? Color.black.opacity(0.8) : Color.white
    }
}

extension Color {
    /// Whether the color reads as light; used to pick contrasting text.
    var isLight: Bool {
        guard let components = UIColor(self).getRedGreenBlue() else { return true }
        return (0.299 * components.r + 0.587 * components.g + 0.114 * components.b) > 0.6
    }
}

private extension UIColor {
    func getRedGreenBlue() -> (r: CGFloat, g: CGFloat, b: CGFloat)? {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        return (r, g, b)
    }
}
