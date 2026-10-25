import Foundation
import SwiftData
import Testing
@testable import FlashCards

@MainActor
@Suite("CatalogService")
struct CatalogServiceTests {
    private let container: ModelContainer
    private let service: CatalogService

    init() throws {
        container = try AppModelContainer.make(inMemory: true)
        service = CatalogService(context: container.mainContext)
    }

    // Catches: the pair not being stored on the root, or a subfolder storing (and so not inheriting) one.
    @Test("A root folder stores the chosen pair and its subfolder reports it")
    func createWithPair() throws {
        let root = try service.createRootFolder(name: " English ", learningLanguage: "en", backLanguage: "ru")
        let sub = try service.createSubfolder(name: "Season 1", in: root)

        #expect(root.name == "English")
        #expect(sub.learningLanguage == nil)
        #expect(sub.resolvedLearningLanguage == "en")
        #expect(sub.resolvedBackLanguage == "ru")
    }

    // Catches: only checking the folder itself, not deeper descendants, or treating a same-pair root as a warning.
    @Test(
        "Move check by destination",
        arguments: [
            ("self", MoveCheck.notAllowed),
            ("grandchild", .notAllowed),
            ("current parent", .notAllowed),
            ("same-pair root", .allowed),
            ("other-pair root", .allowedAfterWarning),
            ("top level", .allowed),
        ]
    )
    func moveCheck(destination: String, expected: MoveCheck) throws {
        let english = try service.createRootFolder(name: "English", learningLanguage: "en", backLanguage: "ru")
        let shows = try service.createRootFolder(name: "Shows", learningLanguage: "en", backLanguage: "ru")
        let serbian = try service.createRootFolder(name: "Serbian", learningLanguage: "sr-Latn", backLanguage: "ru")
        let folder = try service.createSubfolder(name: "Season 1", in: english)
        let grandchild = try service.createSubfolder(
            name: "Episode 2",
            in: service.createSubfolder(name: "Episode 1", in: folder)
        )
        let destinations: [String: Folder?] = [
            "self": folder, "grandchild": grandchild, "current parent": english,
            "same-pair root": shows, "other-pair root": serbian, "top level": nil,
        ]

        #expect(try service.moveCheck(folder, to: #require(destinations[destination])) == expected)
    }

    // Catches: a moved folder keeping its old pair under the new root, or losing it when it becomes a root.
    @Test("Moving takes the new root's pair; moving to the top level keeps the old one")
    func movePair() throws {
        let english = try service.createRootFolder(name: "English", learningLanguage: "en", backLanguage: "ru")
        let serbian = try service.createRootFolder(name: "Serbian", learningLanguage: "sr-Latn", backLanguage: "ru")
        let words = try service.createSubfolder(name: "Words", in: english)

        try service.move(words, to: nil)
        #expect(words.parent == nil)
        #expect(words.learningLanguage == "en")
        #expect(words.backLanguage == "ru")

        try service.move(words, to: serbian)
        #expect(words.parent === serbian)
        #expect(words.learningLanguage == nil)
        #expect(words.resolvedLearningLanguage == "sr-Latn")
        #expect(throws: CatalogError.moveNotAllowed) { try service.move(serbian, to: words) }
    }

    // Catches: deleting through the parent (cascade on the wrong side) or not saving the delete.
    @Test("Deleting a folder removes its subtree only")
    func deleteSubtreeOnly() throws {
        let context = container.mainContext
        let root = try service.createRootFolder(name: "English", learningLanguage: "en", backLanguage: "ru")
        let doomed = try service.createSubfolder(name: "Season 1", in: root)
        try service.createSubfolder(name: "Episode 1", in: doomed)
        let sibling = try service.createSubfolder(name: "Season 2", in: root)
        context.insert(Card(front: "run", back: "x", backSource: "custom", folder: doomed))
        context.insert(Card(front: "see", back: "y", backSource: "custom", folder: sibling))

        try service.delete(doomed)

        let folders = try context.fetch(FetchDescriptor<Folder>(sortBy: [SortDescriptor(\.name)]))
        #expect(folders.map(\.name) == ["English", "Season 2"])
        #expect(try context.fetch(FetchDescriptor<Card>()).map(\.front) == ["see"])
        #expect(root.children?.map(\.name) == ["Season 2"])
    }
}
