import FlashCore
import Foundation
import Mockable
import SwiftData
import Testing
@testable import FlashCards

@MainActor
@Suite("CSVImportViewModel")
struct CSVImportViewModelTests {
    private let container: ModelContainer
    private let service = MockCSVImportServicing()
    private let serbian: Folder
    private let english: Folder
    private let url = URL(filePath: "/cards.csv")

    init() throws {
        container = try AppModelContainer.make(inMemory: true)
        let serbian = Folder(name: "Serbian", learningLanguage: "sr-Latn", backLanguage: "ru")
        let english = Folder(name: "English", learningLanguage: "en", backLanguage: "ru")
        container.mainContext.insert(serbian)
        container.mainContext.insert(english)
        self.serbian = serbian
        self.english = english
        given(service).existingFrontKeys(in: .matching { $0 === serbian }).willReturn(["kuca"])
        given(service).existingFrontKeys(in: .matching { $0 === english }).willReturn([])
    }

    private func model(_ text: String) throws -> CSVImportViewModel {
        try given(service).readDocument(at: .any).willReturn(CSVDocument(data: Data(text.utf8)))
        return CSVImportViewModel(url: url, folder: serbian, service: service)
    }

    private struct Counts: Equatable {
        var toImport: Int
        var duplicates: Int
        var skipped: Int
    }

    private func counts(_ model: CSVImportViewModel) -> Counts {
        Counts(toImport: model.rowsToImport.count, duplicates: model.plan.duplicateCount, skipped: model.skippedCount)
    }

    // Catches: ignoring the header guess, counts not following the header toggle or the folder
    // (stale duplicate keys after picking another root folder), or skipping duplicates when off.
    @Test("Counts follow the header guess, the header toggle, the folder and Skip duplicates")
    func counts() async throws {
        let model = try model("front;back\nkuća;дом\npas;собака\n;prazno")
        await model.load()
        #expect(model.phase == .ready)
        #expect(model.firstRowIsHeader)
        #expect(counts(model) == Counts(toImport: 1, duplicates: 1, skipped: 1))

        model.firstRowIsHeader = false
        #expect(counts(model) == Counts(toImport: 2, duplicates: 1, skipped: 1))

        model.folder = english
        #expect(counts(model) == Counts(toImport: 3, duplicates: 0, skipped: 1))

        model.folder = serbian
        model.skipsDuplicates = false
        #expect(counts(model) == Counts(toImport: 3, duplicates: 1, skipped: 1))
    }

    // Catches: an empty preview with a disabled Import instead of saying why, or a raw error text.
    @Test("A file without cards or a read error shows a message")
    func failures() async throws {
        let empty = try model("only a front\n\n")
        await empty.load()
        #expect(empty.phase == .failed(CSVImportError.noCards.localizedDescription))
        #expect(!empty.canImport)

        // A fresh mock: Mockable answers with the first matching `given`.
        let failing = MockCSVImportServicing()
        given(failing).readDocument(at: .any).willThrow(CSVImportError.notUTF8)
        let unreadable = CSVImportViewModel(url: url, folder: serbian, service: failing)
        await unreadable.load()
        #expect(unreadable.phase == .failed(CSVImportError.notUTF8.localizedDescription))
    }

    // Catches: importing the duplicates Skip left out, or closing the sheet when the save failed.
    @Test("Import saves the rows left after skipping; a failed save keeps the sheet open")
    func importCards() async throws {
        let model = try model("kuća;дом\npas;собака")
        await model.load()
        given(service).importRows(.any, into: .any).willReturn()

        #expect(model.importCards())
        verify(service)
            .importRows(.value([CSVRow(front: "pas", back: "собака")]), into: .matching { $0 === serbian })
            .called(.once)

        let failing = MockCSVImportServicing()
        try given(failing).readDocument(at: .any).willReturn(CSVDocument(data: Data("pas;собака".utf8)))
        given(failing).existingFrontKeys(in: .any).willReturn([])
        given(failing).importRows(.any, into: .any).willThrow(CocoaError(.fileWriteUnknown))
        let failed = CSVImportViewModel(url: url, folder: serbian, service: failing)
        await failed.load()
        #expect(!failed.importCards())
        #expect(failed.saveError != nil)
    }
}
