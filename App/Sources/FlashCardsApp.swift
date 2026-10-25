import SwiftData
import SwiftUI

@main
struct FlashCardsApp: App {
    private let container: ModelContainer
    private let homeModel: HomeViewModel

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
        homeModel = HomeViewModel(
            service: CatalogService(context: container.mainContext),
            cardService: CardService(context: container.mainContext)
        )
    }

    var body: some Scene {
        WindowGroup {
            HomeView(model: homeModel)
        }
        .modelContainer(container)
    }
}
