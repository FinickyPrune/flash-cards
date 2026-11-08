import SwiftUI

/// The redesigned sheets (card editor, folder sheets): white rounded rows on a light grey sheet,
/// near-black in dark mode, tinted with the folder's accent.
enum FormSheetStyle {
    static let background = Color(light: 0xF7F8FB, dark: 0x0C0D12)
}

extension View {
    /// A `Form` in the redesigned sheets' look.
    func formSheetStyle(accent: Color) -> some View {
        scrollContentBackground(.hidden)
            .background(FormSheetStyle.background)
            .tint(accent)
    }
}
