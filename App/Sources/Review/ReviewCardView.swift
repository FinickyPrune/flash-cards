import SwiftUI
import UIKit

/// One card in review: the front, its context and screenshot; after the flip the back below them.
struct ReviewCardView: View {
    let card: Card
    let isFlipped: Bool
    /// Decoded once per card, off the main actor, so the flip doesn't decode it again.
    @State private var screenshot: UIImage?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(card.front)
                .font(.largeTitle.bold())
            if let context = card.context, !context.isEmpty {
                Text(context)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            if let screenshot {
                Image(uiImage: screenshot)
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: 12))
                    .accessibilityHidden(true)
            }
            if isFlipped {
                Divider()
                Text(card.back)
                    .font(.title2)
                    .accessibilityIdentifier(AccessibilityID.Review.back)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .task(id: card.id) {
            screenshot = await card.screenshot.flatMap(UIImage.init(data:))?.byPreparingForDisplay()
        }
    }
}
