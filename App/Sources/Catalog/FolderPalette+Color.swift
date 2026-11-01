import SwiftUI
import UIKit

extension FolderPalette {
    /// The accent; follows light and dark mode.
    var accent: Color {
        Color(light: light.accent, dark: dark.accent)
    }

    /// The two hues corner to corner, as the folder tile and the swatches show them.
    var gradient: LinearGradient {
        LinearGradient(
            colors: [Color(light: light.first, dark: dark.first), Color(light: light.second, dark: dark.second)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private extension Color {
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            UIColor(rgb: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

private extension UIColor {
    convenience init(rgb: UInt32) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }
}
