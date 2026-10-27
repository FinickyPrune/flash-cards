import SwiftData

/// The app's services, built once by the composition root (`FlashCardsApp`). Presenters take it
/// whole and pass it on; leaf view models get only the one service they use
/// (`docs/architecture.md` → Layers).
@MainActor
struct AppDependencies {
    let catalogService: any CatalogServicing
    let cardService: any CardServicing
    let reviewService: any ReviewServicing

    /// The real services, all on one context.
    static func live(context: ModelContext) -> AppDependencies {
        AppDependencies(
            catalogService: CatalogService(context: context),
            cardService: CardService(context: context),
            reviewService: ReviewService(context: context)
        )
    }
}
