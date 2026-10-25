import SwiftData
import SwiftUI

@main
struct FlashCardsApp: App {
    private let container: ModelContainer

    init() {
        do {
            container = try AppModelContainer.make(inMemory: LaunchOptions.inMemoryStore)
        } catch {
            // Without a store the app can't show anything; there is nothing to recover to.
            fatalError("Cannot open the data store: \(error)")
        }
        if LaunchOptions.seed {
            SampleData.insert(into: container.mainContext)
        }
    }

    var body: some Scene {
        WindowGroup {
            HomeView(model: HomeViewModel(service: CatalogService(context: container.mainContext)))
        }
        .modelContainer(container)
    }
}
