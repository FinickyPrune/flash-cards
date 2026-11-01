import SwiftUI

/// One hue fading out from a point, the building block of the wash and the card glow. Sizes are
/// fractions of the view it fills, so the spot keeps its shape on any screen.
struct SoftSpot: View {
    let rgb: UInt32
    /// Centre, as a fraction of the view's size; may lie outside it.
    let center: UnitPoint
    /// Horizontal and vertical radius, as fractions of the view's width and height.
    let radius: CGSize
    /// Opacity at each location from the centre (0) to the radius (1).
    let stops: [(location: Double, opacity: Double)]

    var body: some View {
        GeometryReader { proxy in
            EllipticalGradient(
                stops: stops.map { Gradient.Stop(color: Color(rgb: rgb, opacity: $0.opacity), location: $0.location) },
                center: .center,
                startRadiusFraction: 0,
                endRadiusFraction: 0.5
            )
            .frame(width: 2 * radius.width * proxy.size.width, height: 2 * radius.height * proxy.size.height)
            .position(x: center.x * proxy.size.width, y: center.y * proxy.size.height)
        }
    }
}
