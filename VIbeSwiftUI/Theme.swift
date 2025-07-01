import SwiftUI

/// Theme system for the VIbeSwiftUI application
internal struct AppTheme {

    // MARK: - Colors

    /// Background colors for different contexts
    internal struct Background {
        static let primary = Color.customLightBlue
        static let secondary = Color(.systemGroupedBackground)
        static let card = Color(.systemBackground)
    }

    /// Text colors with accessibility support
    internal struct Text {
        static let primary = Color.primary
        static let secondary = Color.secondary
        static let accent = Color.blue
        static let destructive = Color.red
    }

    /// Chart-specific colors
    internal struct Chart {
        static let background = Color.customLightBlue
        static let gridLines = Color.gray.opacity(0.3)
        static let dataColors: [Color] = [
            .blue, .green, .orange, .purple, .pink, .cyan, .mint, .teal
        ]
    }

    // MARK: - Spacing

    internal struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    // MARK: - Corner Radius

    internal struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
    }

    // MARK: - Animation

    internal struct Animation {
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
    }
}

// MARK: - Color Extensions

internal extension Color {
    /// Custom light blue that adapts to dark mode
    static let customLightBlue = Color(
        light: Color(red: 0.88, green: 0.94, blue: 1.0),
        dark: Color(red: 0.15, green: 0.25, blue: 0.35)
    )

    /// Initializer for creating adaptive colors
    init(light: Color, dark: Color) {
        self = Color(.init { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}
