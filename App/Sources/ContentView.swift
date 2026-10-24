import SwiftUI

/// Placeholder root screen. Replaced once the first feature lands.
struct ContentView: View {
    var body: some View {
        Text("Flash Cards")
            .font(.largeTitle)
            .accessibilityIdentifier(AccessibilityID.rootTitle)
    }
}

enum AccessibilityID {
    static let rootTitle = "root.title"
}

#Preview {
    ContentView()
}
