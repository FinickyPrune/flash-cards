import SwiftData

/// The app's services, built once by the composition root (`FlashCardsApp`). Presenters take it
/// whole and pass it on; leaf view models get only the one service they use
/// (`docs/architecture.md` → Layers).
@MainActor
struct AppDependencies {
    let catalog: any CatalogServicing
    let cards: any CardServicing
    let review: any ReviewServicing

    /// The real services, all on one context.
    static func live(context: ModelContext) -> AppDependencies {
        AppDependencies(
            catalog: CatalogService(context: context),
            cards: CardService(context: context),
            review: ReviewService(context: context)
        )
    }
}
