import FlashCore
import SwiftUI

/// The four glass rating buttons under a flipped card, each a coloured dot and its label.
struct RatingButtons: View {
    let rate: (Rating) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Rating.allCases, id: \.self) { rating in
                Button { rate(rating) } label: {
                    VStack(spacing: 5) {
                        Circle()
                            .fill(rating.tint)
                            .frame(width: 8, height: 8)
                            .accessibilityHidden(true)
                        Text(rating.title)
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .foregroundStyle(rating.tint)
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.roundedRectangle(radius: 22))
                .accessibilityIdentifier(AccessibilityID.Review.rating(rating))
            }
        }
    }
}
