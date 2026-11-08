import SwiftUI
import UIKit

extension Color {
    /// An sRGB colour from `0xRRGGBB`.
    init(rgb: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255,
            opacity: opacity
        )
    }

    /// One colour for light mode and another for dark mode.
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            UIColor(traits.userInterfaceStyle == .dark ? dark : light)
        })
    }

    init(light: UInt32, dark: UInt32) {
        self.init(light: Color(rgb: light), dark: Color(rgb: dark))
    }
}
