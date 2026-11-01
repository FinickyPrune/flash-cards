import SwiftUI

/// A root folder on home: a tile in its palette, the name, the language pair and the cards due
/// today in its accent; on the right a ring of learned / all cards in the subtree. The due line
/// hides at 0 and the ring while the subtree has no cards.
struct FolderRow: View {
    let folder: Folder
    let now: Date
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let palette = folder.resolvedPalette
        let progress = folder.progress
        let tile = FolderTile(palette: palette, size: 48)
        let ring = progress.total > 0 ? ProgressRing(progress: progress, accent: palette.accent) : nil
        Group {
            // At accessibility sizes the text gets the full width, under the tile and the ring.
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        tile
                        Spacer(minLength: 0)
                        ring
                    }
                    details(palette: palette)
                }
            } else {
                HStack(spacing: 14) {
                    tile
                    details(palette: palette)
                    Spacer(minLength: 0)
                    ring
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func details(palette: FolderPalette) -> some View {
        let due = folder.dueCount(at: now)
        return VStack(alignment: .leading, spacing: 1) {
            Text(folder.name)
                .font(.headline)
            if let learning = folder.resolvedLearningLanguage, let back = folder.resolvedBackLanguage {
                Text("\(Languages.name(of: learning)) → \(Languages.name(of: back))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if due > 0 {
                Text("\(due) due")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(palette.accent)
                    .padding(.top, 1)
            }
        }
        .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
    }
}
