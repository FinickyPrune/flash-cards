import SwiftUI

/// One back source in the card editor's list: a radio circle and the title, the text below. The
/// selected row has a filled check and the accent; `SelectedRowBackground` rings it in the palette.
struct BackSourceRow<Content: View>: View {
    let source: BackSource
    let isSelected: Bool
    let accent: Color
    @ViewBuilder let content: Content

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.subheadline.weight(.semibold))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(source.title)
                    .font(.subheadline.weight(.semibold))
                content
            }
        }
        // Explicit colours: inside a button `.secondary` would take the tint.
        .foregroundStyle(isSelected ? accent : Color.secondary)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
