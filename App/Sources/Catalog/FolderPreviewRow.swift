import SwiftUI

/// How a folder will look in the catalog: its gradient tile, name and language pair, over a soft
/// wash of its palette. Shown at the top of the New Folder and Appearance sheets.
struct FolderPreviewRow: View {
    let palette: FolderPalette
    let name: String
    let learningLanguage: String?
    let backLanguage: String?

    var body: some View {
        HStack(spacing: 14) {
            FolderTile(palette: palette, size: 48)
            VStack(alignment: .leading, spacing: 2) {
                let trimmed = name.trimmed
                Text(trimmed.isEmpty ? String(localized: "New Folder") : trimmed)
                    .font(.headline)
                    .foregroundStyle(trimmed.isEmpty ? Color.secondary : Color.primary)
                    .lineLimit(1)
                    .accessibilityIdentifier(AccessibilityID.FolderForm.previewName)
                if let learningLanguage, let backLanguage {
                    Text("\(Languages.name(of: learningLanguage)) → \(Languages.name(of: backLanguage))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 8)
            Text("Preview")
                .font(.caption.weight(.semibold))
                .textCase(.uppercase)
                .foregroundStyle(palette.accent)
        }
        .padding(.vertical, 8)
        .listRowBackground(PreviewWash(palette: palette))
    }
}

/// A soft version of the folder's wash behind the preview row.
private struct PreviewWash: View {
    let palette: FolderPalette
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let isDark = colorScheme == .dark
        let colors = palette.colors(for: colorScheme)
        let stops = [(location: 0.0, opacity: 0.32), (0.4, 0.14), (0.8, 0)]
            .map { (location: $0.location, opacity: $0.opacity * (isDark ? 0.7 : 1)) }
        let radius = CGSize(width: 0.9, height: 1.4)
        ZStack {
            isDark ? Color(rgb: 0x1A1C24) : Color.white
            SoftSpot(rgb: colors.first, center: UnitPoint(x: 0, y: 0), radius: radius, stops: stops)
            SoftSpot(rgb: colors.second, center: UnitPoint(x: 1, y: 0), radius: radius, stops: stops)
        }
    }
}
