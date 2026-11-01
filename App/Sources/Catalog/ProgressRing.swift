import SwiftUI

/// Learned / all as a ring in the accent, with the percentage inside.
struct ProgressRing: View {
    let progress: FolderProgress
    let accent: Color
    @ScaledMetric private var size = 44.0

    var body: some View {
        let fraction = Double(progress.learned) / Double(max(progress.total, 1))
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.09), lineWidth: size * 0.09)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(accent, style: StrokeStyle(lineWidth: size * 0.09, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text(fraction, format: .percent.precision(.fractionLength(0)))
                .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .padding(size * 0.05)
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(progress.learned) / \(progress.total) learned"))
    }
}
