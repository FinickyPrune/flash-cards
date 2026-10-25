import Mockable

/// Card changes; `CardService` saves them with SwiftData. The card editor depends on this.
@Mockable
@MainActor
protocol CardServicing {
    /// Another card with the same front key in the same root folder as `folder`, if any.
    func duplicate(of front: String, in folder: Folder, excluding card: Card?) throws -> Card?
    @discardableResult
    func create(_ draft: CardDraft) throws -> Card
    func update(_ card: Card, with draft: CardDraft) throws
    func delete(_ card: Card) throws
}
