import SwiftUI

/// The top of a folder screen: cards due today, learned / all with a bar, and Play. Shown only
/// while the subtree has cards.
struct FolderSummaryCard: View {
    let palette: FolderPalette
    let due: Int
    let progress: FolderProgress
    let play: () -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline))
        VStack(alignment: .leading, spacing: 14) {
            layout {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(due, format: .number)
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    Text("due today")
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
                Spacer(minLength: 0)
                Text("\(progress.learned) / \(progress.total) learned")
                    .font(.subheadline)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            ProgressBar(fraction: progress.fraction, color: palette.accent)
            Button(action: play) {
                Label("Play", systemImage: "play.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(CatalogStyle.onAccent)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .tint(palette.accent)
            .accessibilityIdentifier(AccessibilityID.FolderScreen.play)
        }
        .padding(16)
        .background { CardGlow(palette: palette).clipShape(.rect(cornerRadius: 28, style: .continuous)) }
        .shadow(color: Color(rgb: 0x1E2350, opacity: 0.08), radius: 15, y: 12)
    }
}

private struct ProgressBar: View {
    let fraction: Double
    let color: Color

    var body: some View {
        Capsule()
            .fill(Color.primary.opacity(0.07))
            .overlay(alignment: .leading) {
                GeometryReader { proxy in
                    Capsule()
                        .fill(color)
                        .frame(width: proxy.size.width * fraction)
                }
            }
            .frame(height: 6)
            .accessibilityHidden(true)
    }
}
