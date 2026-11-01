import SwiftUI

/// A screen's background: two hues spreading from the top corners and fading out by mid-screen,
/// over a near-white or near-black base; weaker in dark mode so the hues don't go muddy.
struct ScreenWash: View {
    let light: FolderPalette.Colors
    let dark: FolderPalette.Colors
    /// 1 for a folder screen; home's wash is a little softer.
    var strength = 1.0
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let isDark = colorScheme == .dark
        let colors = isDark ? dark : light
        let strength = strength * (isDark ? 0.55 : 1)
        let stops = [(0, 0.62), (0.14, 0.5), (0.32, 0.3), (0.52, 0.12), (0.7, 0.03), (0.85, 0)]
            .map { (location: $0.0, opacity: $0.1 * strength) }
        let radius = CGSize(width: 1.4, height: isDark ? 0.7 : 0.62)
        ZStack {
            CatalogStyle.background
            SoftSpot(rgb: colors.first, center: UnitPoint(x: 0, y: -0.08), radius: radius, stops: stops)
            SoftSpot(rgb: colors.second, center: UnitPoint(x: 1, y: -0.08), radius: radius, stops: stops)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

extension ScreenWash {
    /// A folder screen's wash, in the folder's palette.
    init(palette: FolderPalette) {
        self.init(light: palette.light, dark: palette.dark)
    }
}
