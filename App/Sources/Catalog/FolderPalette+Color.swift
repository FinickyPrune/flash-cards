import SwiftUI

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

    /// The light or the dark set, for drawings that also change strength between the modes.
    func colors(for scheme: ColorScheme) -> Colors {
        scheme == .dark ? dark : light
    }
}
