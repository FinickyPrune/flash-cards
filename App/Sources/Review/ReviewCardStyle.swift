import SwiftUI

extension View {
    /// A card in review over the folder's wash: white, or near-black in dark mode, with the
    /// palette's glow and a soft shadow.
    func reviewCardStyle(_ palette: FolderPalette) -> some View {
        background {
            CardGlow(palette: palette)
                .clipShape(.rect(cornerRadius: 34, style: .continuous))
        }
        .shadow(color: Color(light: Color(rgb: 0x1E2350, opacity: 0.12), dark: .black.opacity(0.4)), radius: 22, y: 18)
    }
}
