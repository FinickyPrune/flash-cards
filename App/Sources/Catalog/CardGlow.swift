import SwiftUI

/// A card's fill: white, or near-black in dark mode, with the palette's two hues glowing up from
/// under its bottom edge.
struct CardGlow: View {
    let palette: FolderPalette
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let isDark = colorScheme == .dark
        let colors = palette.colors(for: colorScheme)
        let stops = isDark
            ? [(location: 0.0, opacity: 0.3), (0.34, 0.14), (0.62, 0.04), (0.82, 0)]
            : [(location: 0.0, opacity: 0.5), (0.3, 0.28), (0.58, 0.08), (0.8, 0)]
        let radius = isDark ? CGSize(width: 0.7, height: 0.34) : CGSize(width: 0.75, height: 0.6)
        let y = isDark ? 1.06 : 1.12
        ZStack {
            isDark ? Color(rgb: 0x1A1C24) : Color.white
            SoftSpot(rgb: colors.first, center: UnitPoint(x: isDark ? 0.2 : 0.18, y: y), radius: radius, stops: stops)
            SoftSpot(rgb: colors.second, center: UnitPoint(x: isDark ? 0.8 : 0.82, y: y), radius: radius, stops: stops)
        }
    }
}
