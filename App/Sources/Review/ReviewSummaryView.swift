import FlashCore
import SwiftUI

/// The end of a session on a card: how many cards were reviewed and how many went well on the
/// first try; More starts the next session when there is one.
struct ReviewSummaryView: View {
    let summary: ReviewSession.Summary
    let folderName: String
    let palette: FolderPalette
    let canContinue: Bool
    let onDone: () -> Void
    let onMore: () -> Void

    var body: some View {
        FillingScrollView {
            card
                .reviewCardStyle(palette)
                .padding(16)
        }
        .safeAreaInset(edge: .bottom) { buttons }
    }

    private var card: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark")
                .font(.system(.title, weight: .bold))
                .foregroundStyle(palette.accent)
                .frame(width: 72, height: 72)
                .background(palette.accent.opacity(0.12), in: .circle)
                .accessibilityHidden(true)
            Text("Session done")
                .font(.title.bold())
                .padding(.top, 8)
            Text(folderName)
                .foregroundStyle(.secondary)
            HStack(spacing: 12) {
                tile(
                    summary.reviewed,
                    label: "Reviewed",
                    spoken: Text("Reviewed \(summary.reviewed)"),
                    color: .primary,
                    id: AccessibilityID.Review.reviewed
                )
                tile(
                    summary.goodOrEasy,
                    label: "Good or Easy",
                    spoken: Text("Good or Easy \(summary.goodOrEasy)"),
                    color: palette.accent,
                    id: AccessibilityID.Review.goodOrEasy
                )
            }
            .padding(.top, 28)
            firstTry
                .padding(.top, 8)
            Spacer(minLength: 0)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
        .padding(.top, 40)
        .padding(.bottom, 24)
    }

    /// A number over its label. VoiceOver reads the number as `spoken` and skips the label.
    private func tile(
        _ value: Int,
        label: LocalizedStringKey,
        spoken: Text,
        color: Color,
        id: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value, format: .number)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(color)
                .accessibilityLabel(spoken)
                .accessibilityIdentifier(id)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            Color(light: .white.opacity(0.85), dark: .white.opacity(0.06)),
            in: .rect(cornerRadius: 22, style: .continuous)
        )
    }

    /// Good or Easy out of reviewed, as a bar, a percentage and the rest as Again or Hard.
    private var firstTry: some View {
        let fraction = summary.reviewed > 0 ? Double(summary.goodOrEasy) / Double(summary.reviewed) : 0
        return VStack(spacing: 8) {
            ProgressBar(fraction: fraction, color: palette.accent, height: 8)
            HStack(alignment: .firstTextBaseline) {
                Text("\(fraction, format: .percent.precision(.fractionLength(0))) on the first try")
                Spacer(minLength: 8)
                Text("\(summary.reviewed - summary.goodOrEasy) Again or Hard")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
    }

    private var buttons: some View {
        HStack(spacing: 10) {
            if canContinue {
                Button(action: onMore) {
                    Text("More")
                        .font(.headline)
                        .foregroundStyle(palette.accent)
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.capsule)
                .accessibilityIdentifier(AccessibilityID.Review.more)
            }
            Button(action: onDone) {
                Text("Done")
                    .font(.headline)
                    .foregroundStyle(CatalogStyle.onAccent)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .tint(palette.accent)
            .accessibilityIdentifier(AccessibilityID.Review.done)
        }
        .controlSize(.large)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}
