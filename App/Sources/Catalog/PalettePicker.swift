import SwiftUI

/// The palettes as round gradient swatches, four to a row; the selected one is ringed in its accent.
struct PalettePicker: View {
    @Binding var selection: FolderPalette
    @ScaledMetric private var size = 52.0

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
            ForEach(FolderPalette.allCases, id: \.self) { palette in
                Button { selection = palette } label: {
                    Circle()
                        .fill(palette.gradient)
                        .padding(4)
                        .overlay {
                            Circle().strokeBorder(palette == selection ? palette.accent : .clear, lineWidth: 2.5)
                        }
                        .frame(width: size, height: size)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(palette.title))
                .accessibilityAddTraits(palette == selection ? .isSelected : [])
                .accessibilityIdentifier(AccessibilityID.Palette.swatch(palette.rawValue))
            }
        }
        .padding(.vertical, 6)
    }
}
