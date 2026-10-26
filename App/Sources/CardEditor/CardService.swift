import FlashCore
import Foundation
import SwiftData

/// Card changes (`card-editor.md` → Rules). Every change is saved right away; a failed save rolls
/// the context back. Saving remembers the back source on the root folder.
@MainActor
struct CardService: CardServicing {
    let context: ModelContext

    func duplicate(of front: String, in folder: Folder, excluding card: Card?) throws -> Card? {
        let key = FrontKey.make(from: front)
        let root = folder.root
        let descriptor = FetchDescriptor<Card>(predicate: #Predicate { $0.frontKey == key })
        return try context.fetch(descriptor).first { $0 !== card && $0.folder?.root === root }
    }

    @discardableResult
    func create(_ draft: CardDraft) throws -> Card {
        guard draft.isComplete else { throw CardError.incomplete }
        let card = Card(
            front: draft.front.trimmed,
            back: draft.back.trimmed,
            backSource: draft.backSource.rawValue,
            folder: draft.folder,
            context: draft.context.trimmed.isEmpty ? nil : draft.context.trimmed
        )
        context.insert(card)
        draft.folder.root.lastBackSource = draft.backSource.rawValue
        try context.saveOrRollback()
        return card
    }

    /// Remembers the back source only when the edit picks another one or moves the card to another
    /// root folder; fixing a typo in an old card doesn't change the next card's default tile.
    func update(_ card: Card, with draft: CardDraft) throws {
        guard draft.isComplete else { throw CardError.incomplete }
        let remembers = card.source != draft.backSource || card.folder?.root !== draft.folder.root
        card.setFront(draft.front.trimmed)
        card.back = draft.back.trimmed
        card.backSource = draft.backSource.rawValue
        card.context = draft.context.trimmed.isEmpty ? nil : draft.context.trimmed
        card.folder = draft.folder
        card.updatedAt = .now
        if remembers {
            draft.folder.root.lastBackSource = draft.backSource.rawValue
        }
        try context.saveOrRollback()
    }

    func delete(_ card: Card) throws {
        context.delete(card)
        try context.saveOrRollback()
    }
}
