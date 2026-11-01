import Foundation
import SwiftData
import Testing
@testable import FlashCards

@MainActor
@Suite("Migration")
struct MigrationTests {
    /// Locates the test bundle's resources.
    private final class BundleToken {}

    // Each fixture holds the same data: English > Season 1 > card "run" (back "бежать", context
    // "Run!", screenshot [1, 2, 3]), a review state of 6 days and two ratings, Good and Easy.
    // `store-v1.sqlite` was written by the shipped version 1 models (main at 63ecf56 + #29), on
    // iOS 27; `store-v2.sqlite` by version 2 (main at 1cde752), on iOS 26.2.
    // Catches: a frozen copy that no longer matches real stores of its version (they would fail
    // to open), a migration stage that breaks the data, `kind` without a default for V1 rows, or
    // old folders without a palette not resolving to one.
    // Not caught: a missing stage, since SwiftData infers lightweight ones. Not covered: external
    // blob files; the fixture's screenshot is small enough to be stored inline.
    @Test(
        "A store written by an earlier version opens with the current schema and keeps its data",
        arguments: ["store-v1", "store-v2"]
    )
    func fromEarlierVersion(fixtureName: String) throws {
        let fixture = try #require(Bundle(for: BundleToken.self).url(forResource: fixtureName, withExtension: "sqlite"))
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
        let root = try #require(card.folder?.root)
        #expect(root.palette == nil)
        #expect(root.resolvedPalette == .derived(from: root.id))
    }
}
