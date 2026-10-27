import Foundation
import SwiftData
import Testing
@testable import FlashCards

@MainActor
@Suite("Folder")
struct FolderTests {
    private let container: ModelContainer
    private var context: ModelContext {
        container.mainContext
    }

    init() throws {
        container = try AppModelContainer.make(inMemory: true)
    }

    // Catches: a missing or `.nullify` delete rule on children, cards, review states or logs,
    // and a cascade on the wrong side that takes unrelated folders down too.
    @Test("Deleting a root folder deletes its whole subtree and nothing else")
    func deleteSubtree() throws {
        let root = Folder(name: "Root", learningLanguage: "en", backLanguage: "ru")
        let sub = Folder(name: "Sub", parent: root)
        let other = Folder(name: "Other", learningLanguage: "sr", backLanguage: "ru")
        context.insert(root)
        context.insert(sub)
        context.insert(other)
        for (front, folder) in [("run", root), ("see", sub)] {
            let card = Card(front: front, back: "x", backSource: "custom", folder: folder)
            context.insert(card)
            context.insert(ReviewState(card: card))
            context.insert(ReviewLog(card: card, rating: 2))
        }
        let kept = Card(front: "kuća", back: "дом", backSource: "translation", folder: other)
        context.insert(kept)
        context.insert(ReviewState(card: kept))
        context.insert(ReviewLog(card: kept, rating: 3))
        try context.save()

        context.delete(root)
        try context.save()

        #expect(try context.fetch(FetchDescriptor<Folder>()).map(\.name) == ["Other"])
        #expect(try context.fetch(FetchDescriptor<Card>()).map(\.front) == ["kuća"])
        #expect(try context.fetch(FetchDescriptor<ReviewState>()).map(\.card?.front) == ["kuća"])
        #expect(try context.fetch(FetchDescriptor<ReviewLog>()).map(\.card?.front) == ["kuća"])
    }

    // Catches: counting only the folder's own cards, counting a sibling's, an off-by-one or
    // rounding at 21 days, reading the reverse direction, or progress cached past a lapse.
    @Test("Progress counts learned cards over all cards in the subtree")
    func progress() throws {
        let root = Folder(name: "Root", learningLanguage: "en", backLanguage: "ru")
        let child = Folder(name: "Child", parent: root)
        let grandchild = Folder(name: "Grandchild", parent: child)
        let sibling = Folder(name: "Sibling", parent: root)
        context.insert(root)
        func card(in folder: Folder, interval: Double?, direction: String = "forward") -> Card {
            let card = Card(front: "w", back: "x", backSource: "custom", folder: folder)
            context.insert(card)
            if let interval {
                let state = ReviewState(card: card, direction: direction)
                state.intervalDays = interval
                context.insert(state)
            }
            return card
        }
        let learned = card(in: child, interval: 21)
        // Just under 21 days: rounding the stored interval would wrongly count it.
        _ = card(in: grandchild, interval: 20.5)
        _ = card(in: grandchild, interval: nil)
        _ = card(in: grandchild, interval: 30, direction: "reverse")
        _ = card(in: sibling, interval: 40)
        try context.save()

        #expect(child.progress == FolderProgress(learned: 1, total: 4))
        #expect(root.progress == FolderProgress(learned: 2, total: 5))

        // A lapse resets the interval to 1 day.
        learned.forwardReviewState?.intervalDays = 1
        #expect(child.progress == FolderProgress(learned: 0, total: 4))
    }

    // Catches: resolving from the direct parent only, or reading the subfolder's own (empty) fields.
    @Test("A subfolder at any depth reports its root folder's language pair")
    func subfolderLanguagePair() {
        let root = Folder(name: "Root", learningLanguage: "en", backLanguage: "ru")
        let grandchild = Folder(name: "Grandchild", parent: Folder(name: "Child", parent: root))
        context.insert(root)

        #expect(grandchild.resolvedLearningLanguage == "en")
        #expect(grandchild.resolvedBackLanguage == "ru")
    }
}
