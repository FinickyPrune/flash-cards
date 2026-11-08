import SwiftUI

extension View {
    /// A `Form` in the redesigned sheets' look (card editor, folder sheets): white rounded rows on
    /// a light grey sheet, near-black in dark mode, tinted with the folder's accent.
    func formSheetStyle(accent: Color) -> some View {
        scrollContentBackground(.hidden)
            .background(CatalogStyle.sheetBackground)
            .tint(accent)
    }
}
