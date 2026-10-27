import Foundation
import SwiftData
import Testing
@testable import FlashCards

@MainActor
@Suite("Migration")
struct MigrationTests {
    // Catches: a missing or wrong migration stage, a frozen V1 copy that no longer matches
    // version 1 stores (the store would fail to open), or `kind` without a default.
    @Test("A version 1 store opens with the current schema and keeps its data")
    func fromV1() throws {
        let directory = URL.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "store.sqlite")

        try writeV1Store(at: url)

        let container = try AppModelContainer.make(url: url)
        let logs = try container.mainContext.fetch(FetchDescriptor<ReviewLog>())
        #expect(logs.map(\.rating) == [2])
        #expect(logs.map(\.kind) == ["review"])
        #expect(logs.first?.card?.front == "run")
        #expect(logs.first?.card?.folder?.name == "English")
    }

    /// A store as version 1 of the app wrote it: a folder, a card and one rating.
    private func writeV1Store(at url: URL) throws {
        let schema = Schema(versionedSchema: SchemaV1.self)
        let container = try ModelContainer(
            for: schema,
            configurations: ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
        )
        let context = container.mainContext
        let folder = SchemaV1.Folder()
        folder.name = "English"
        let card = SchemaV1.Card()
        card.front = "run"
        card.folder = folder
        let log = SchemaV1.ReviewLog()
        log.card = card
        log.rating = 2
        context.insert(folder)
        context.insert(card)
        context.insert(log)
        try context.save()
    }
}
