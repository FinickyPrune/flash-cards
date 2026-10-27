import FlashCore
import SwiftUI

/// The end of a session: how many cards were reviewed and how many went well; More starts the
/// next session when there is one.
struct ReviewSummaryView: View {
    let summary: ReviewSession.Summary
    let canContinue: Bool
    let onDone: () -> Void
    let onMore: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label {
                Text("Reviewed \(summary.reviewed)")
                    .accessibilityIdentifier(AccessibilityID.Review.reviewed)
            } icon: {
                Image(systemName: "checkmark.circle")
                    .accessibilityHidden(true)
            }
        } description: {
            Text("Good or Easy \(summary.goodOrEasy)")
        } actions: {
            Button("Done", action: onDone)
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier(AccessibilityID.Review.done)
            if canContinue {
                Button("More", action: onMore)
                    .accessibilityIdentifier(AccessibilityID.Review.more)
            }
        }
    }
}
