import SwiftUI

/// A card in a folder: the front, with the back below it.
struct CardRow: View {
    let card: Card

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(card.front)
            Text(card.back)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .accessibilityElement(children: .combine)
    }
}
