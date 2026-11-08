import SwiftUI
import UIKit

/// One card in review: the front, its context with the front highlighted and the screenshot;
/// after the flip the back's source and text below them, before it a hint to tap.
struct ReviewCardView: View {
    let card: Card
    let palette: FolderPalette
    let isFlipped: Bool
    /// Decoded once per card, off the main actor, so the flip doesn't decode it again.
    @State private var screenshot: UIImage?
    @ScaledMetric(relativeTo: .largeTitle) private var frontSize = 40
    @ScaledMetric(relativeTo: .title) private var backSize = 26

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(card.front)
                .font(.system(size: frontSize, weight: .bold))
            if let context = card.context, !context.isEmpty {
                Text(highlighted(context))
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            if let screenshot {
                Image(uiImage: screenshot)
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: 20, style: .continuous))
                    .accessibilityHidden(true)
            }
            if isFlipped {
                Divider()
                    .padding(.top, 6)
                Text(card.source.title)
                    .font(.caption.weight(.semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(palette.accent)
                Text(card.back)
                    .font(.system(size: backSize, weight: .semibold))
                    .accessibilityIdentifier(AccessibilityID.Review.back)
            } else {
                Spacer(minLength: 16)
                Text("Tap to show the answer")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 20)
        .padding(.vertical, 22)
        .task(id: card.id) {
            screenshot = await card.screenshot.flatMap(UIImage.init(data:))?.byPreparingForDisplay()
        }
    }

    /// The context with the front's first occurrence in the accent; unchanged when it's absent.
    private func highlighted(_ context: String) -> AttributedString {
        var text = AttributedString(context)
        if let range = ContextHighlight.range(of: card.front, in: context),
           let match = Range(range, in: text)
        {
            text[match].foregroundColor = palette.accent
            text[match].font = .body.weight(.semibold)
        }
        return text
    }
}
