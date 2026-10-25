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
