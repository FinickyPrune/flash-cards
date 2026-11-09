import FlashCore
import Foundation
import SwiftData
import Testing
@testable import FlashCards

@MainActor
@Suite("CSVImportService")
struct CSVImportServiceTests {
    private let container: ModelContainer
    private let service: CSVImportService
    private let serbian: Folder
    private let words: Folder
    private let phrases: Folder
    private let english: Folder

    init() throws {
        container = try AppModelContainer.make(inMemory: true)
        service = CSVImportService(context: container.mainContext)
        serbian = Folder(name: "Serbian", learningLanguage: "sr-Latn", backLanguage: "ru")
        serbian.lastBackSource = BackSource.translation.rawValue
        words = Folder(name: "Words", parent: serbian)
        phrases = Folder(name: "Phrases", parent: serbian)
        english = Folder(name: "English", learningLanguage: "en", backLanguage: "ru")
        for folder in [serbian, words, phrases, english] {
            container.mainContext.insert(folder)
        }
    }

    // Catches: a back source other than custom, a lost context, cards in the root instead of the
    // chosen subfolder, file order reversed, or the root's remembered back source overwritten.
    @Test("Each row becomes a new custom card in the folder, in file order")
    func importRows() throws {
        try service.importRows(
            [CSVRow(front: "kuća", back: "дом", context: "Moja kuća."), CSVRow(front: "pas", back: "собака")],
            into: words
        )

        let cards = try container.mainContext.fetch(FetchDescriptor<Card>(sortBy: [SortDescriptor(\.createdAt)]))
        #expect(cards.map { [$0.front, $0.back, $0.context, $0.backSource, $0.folder?.name] } == [
            ["kuća", "дом", "Moja kuća.", "custom", "Words"],
            ["pas", "собака", nil, "custom", "Words"],
        ])
        #expect(cards.allSatisfy { $0.forwardReviewState == nil })
        #expect(serbian.lastBackSource == "translation")
    }

    // Catches: collecting keys from the folder alone instead of its whole root, or across roots.
    @Test("Existing front keys cover the whole root folder and nothing else")
    func existingFrontKeys() {
        for (front, folder) in [("Kuća", phrases), ("hvala", serbian), ("house", english)] {
            container.mainContext.insert(Card(front: front, back: "x", backSource: "custom", folder: folder))
        }

        #expect(service.existingFrontKeys(in: words) == ["kuca", "hvala"])
    }

    // Catches: a read failure or non-UTF-8 text surfacing as a raw system error, or the other's message.
    @Test("Unreadable and non-UTF-8 files fail with their own errors")
    func readErrors() async throws {
        let missing = URL.temporaryDirectory.appending(path: "missing-\(UUID()).csv")
        await #expect(throws: CSVImportError.unreadable) { try await service.readDocument(at: missing) }

        let cp1251 = URL.temporaryDirectory.appending(path: "cp1251-\(UUID()).csv")
        // "дом;a" in Windows-1251.
        try Data([0xE4, 0xEE, 0xEC, 0x3B, 0x61]).write(to: cp1251)
        defer { try? FileManager.default.removeItem(at: cp1251) }
        await #expect(throws: CSVImportError.notUTF8) { try await service.readDocument(at: cp1251) }
    }
}
