import SwiftUI

/// A folder's icon: a rounded tile in its palette's gradient with a white folder glyph.
struct FolderTile: View {
    let palette: FolderPalette
    @ScaledMetric private var size = 32.0

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
            .fill(palette.gradient)
            .frame(width: size, height: size)
            .overlay {
                Image(systemName: "folder.fill")
                    .font(.system(size: size * 0.5))
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)
    }
}
