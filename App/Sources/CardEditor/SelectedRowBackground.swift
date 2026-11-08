import SwiftUI

/// The selected back source's background: white with the palette's glow, ringed in the accent,
/// inset from the list's own card.
struct SelectedRowBackground: View {
    let palette: FolderPalette

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)
        ZStack {
            Color(.secondarySystemGroupedBackground)
            CardGlow(palette: palette)
                .clipShape(shape)
                .overlay { shape.strokeBorder(palette.accent, lineWidth: 2) }
                .padding(4)
        }
    }
}
