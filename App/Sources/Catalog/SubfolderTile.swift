import SwiftUI

/// A subfolder on its parent's screen: a card in its own palette's glow, with the folder glyph and
/// name in its accent and learned / all cards in its subtree (nothing while it has no cards).
struct SubfolderTile: View {
    let folder: Folder
    @ScaledMetric private var minHeight = 92.0

    var body: some View {
        let palette = folder.resolvedPalette
        let progress = folder.progress
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Image(systemName: "folder.fill")
                    .font(.subheadline)
                Text(folder.name)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
            }
            .foregroundStyle(palette.accent)
            Spacer(minLength: 0)
            if progress.total > 0 {
                Text("\(progress.learned) / \(progress.total) learned")
                    .font(.footnote)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
        .background { CardGlow(palette: palette).clipShape(.rect(cornerRadius: 24, style: .continuous)) }
        .shadow(color: Color(rgb: 0x1E2350, opacity: 0.07), radius: 11, y: 8)
    }
}
