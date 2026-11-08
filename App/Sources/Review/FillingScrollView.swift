import SwiftUI

/// A vertical scroll view whose content is at least as tall as the visible area, so a short card
/// still reaches the bottom bar and a long one scrolls.
struct FillingScrollView<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        // The reader's size is the area left between the bars, which the content should fill.
        GeometryReader { proxy in
            ScrollView {
                MinHeightLayout(minHeight: proxy.size.height) {
                    content
                }
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }
}

/// Gives its content its own height or `minHeight`, whichever is taller. A scroll view proposes
/// no height, and `.frame(minHeight:)` passes that on, so flexible content wouldn't stretch.
private struct MinHeightLayout: Layout {
    let minHeight: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout Void) -> CGSize {
        let width = proposal.width
        let height = subviews.map { $0.sizeThatFits(ProposedViewSize(width: width, height: nil)).height }.max() ?? 0
        return CGSize(width: width ?? 0, height: max(height, minHeight))
    }

    func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout Void) {
        for subview in subviews {
            subview.place(at: bounds.origin, proposal: ProposedViewSize(bounds.size))
        }
    }
}
