import SwiftUI

/// The top of review and its summary: Close, a chip with the folder name and the "3 / 20"
/// counter, and the session's progress under them.
struct ReviewTopBar: View {
    let folderName: String
    let isPractice: Bool
    let position: Int
    let cardCount: Int
    let accent: Color
    let close: () -> Void
    /// Close's glyph area, and the room kept for Close's whole button beside the chip.
    @ScaledMetric private var glyphSize = 30
    @ScaledMetric private var buttonSize = 44

    var body: some View {
        VStack(spacing: 14) {
            // The chip is centred on the whole bar, clear of Close on either side.
            chip
                .padding(.horizontal, buttonSize + 8)
                .frame(maxWidth: .infinity, minHeight: buttonSize)
                .overlay(alignment: .leading) {
                    Button(action: close) {
                        Label("Close", systemImage: "xmark")
                            .labelStyle(.iconOnly)
                            .font(.body.weight(.semibold))
                            .frame(width: glyphSize, height: glyphSize)
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                    .accessibilityIdentifier(AccessibilityID.Review.close)
                }
            ProgressBar(
                fraction: Double(position) / Double(max(cardCount, 1)),
                color: accent,
                height: 4,
                track: Color(light: .white.opacity(0.7), dark: .white.opacity(0.1))
            )
            .padding(.horizontal, 16)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }

    private var chip: some View {
        HStack(spacing: 8) {
            Text(folderName)
                .foregroundStyle(accent)
                .lineLimit(1)
            if isPractice {
                Text("Practice")
                    .foregroundStyle(.secondary)
                    .fixedSize()
            }
            Text("\(position) / \(cardCount)")
                .fontDesign(.rounded)
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .fixedSize()
                .accessibilityIdentifier(AccessibilityID.Review.position)
        }
        .font(.subheadline.weight(.semibold))
        .padding(.horizontal, 14)
        .frame(minHeight: 36)
        .glassEffect(.regular, in: .capsule)
    }
}
