import SwiftData
import SwiftUI

@main
struct FlashCardsApp: App {
    private let container: ModelContainer

    init() {
        do {
            container = try AppModelContainer.make()
        } catch {
            // Without a store the app can't show anything; there is nothing to recover to.
            fatalError("Cannot open the data store: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
