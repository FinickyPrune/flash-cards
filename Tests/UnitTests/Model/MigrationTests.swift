import Foundation
import SwiftData
import Testing
@testable import FlashCards

@MainActor
@Suite("Migration")
struct MigrationTests {
    /// Locates the test bundle's resources.
    private final class BundleToken {}

    // `Fixtures/store-v1.sqlite` was written by the shipped version 1 models (main at 63ecf56 + #29):
    // English > Season 1 > card "run" (back "бежать", context "Run!", screenshot [1, 2, 3]),
    // a review state of 6 days and two ratings, Good and Easy.
    // Catches: a frozen V1 copy that no longer matches real version 1 stores (they would fail to
    // open), a broken migration plan, or `kind` without a default for old rows.
    @Test("A store written by version 1 opens with the current schema and keeps its data")
    func fromV1() throws {
        let fixture = try #require(Bundle(for: BundleToken.self).url(forResource: "store-v1", withExtension: "sqlite"))
        let directory = URL.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appending(path: "store.sqlite")
        try FileManager.default.copyItem(at: fixture, to: url)

        // Keep the container: a context doesn't retain it, and fetching after it's gone traps.
        let container = try AppModelContainer.make(url: url)
        let context = container.mainContext

        let logs = try context.fetch(FetchDescriptor<ReviewLog>(sortBy: [SortDescriptor(\.reviewedAt)]))
        #expect(logs.map(\.rating) == [2, 3])
        #expect(logs.map(\.kind) == ["review", "review"])
        let card = try #require(logs.first?.card)
        #expect([card.front, card.back, card.context, card.folder?.name, card.folder?.root.name] == [
            "run", "бежать", "Run!", "Season 1", "English",
        ])
        #expect(card.screenshot == Data([1, 2, 3]))
        #expect(card.forwardReviewState?.schedulingState.intervalDays == 6)
    }
}
