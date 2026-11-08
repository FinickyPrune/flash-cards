import SwiftUI

/// A thin capsule filled to `fraction` in `color`: folder progress, the review session and its
/// summary.
struct ProgressBar: View {
    let fraction: Double
    let color: Color
    var height: CGFloat = 6
    var track = Color.primary.opacity(0.07)

    var body: some View {
        Capsule()
            .fill(track)
            .overlay(alignment: .leading) {
                GeometryReader { proxy in
                    Capsule()
                        .fill(color)
                        .frame(width: proxy.size.width * min(max(fraction, 0), 1))
                }
            }
            .frame(height: height)
            .accessibilityHidden(true)
    }
}
