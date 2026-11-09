import FlashCore
import Foundation
import SwiftData

/// Imported cards are new, with back source custom and no screenshot; the root folder's last back
/// source stays as it was. A failed save creates no card.
@MainActor
struct CSVImportService: CSVImportServicing {
    let context: ModelContext
    let reader = CSVFileReader()

    func readDocument(at url: URL) async throws -> CSVDocument {
        try await reader.document(at: url)
    }

    func existingFrontKeys(in folder: Folder) -> Set<String> {
        Set(folder.root.subtreeCards.map(\.frontKey))
    }

    /// Creation times a millisecond apart, ending now, follow the file's order: its last row is
    /// the newest, and none is dated after a card added right after the import.
    func importRows(_ rows: [CSVRow], into folder: Folder) throws {
        let end = Date.now
        let cards = rows.enumerated().map { index, row in
            Card(
                front: row.front,
                back: row.back,
                backSource: BackSource.custom.rawValue,
                folder: nil,
                context: row.context,
                createdAt: end.addingTimeInterval(Double(index - rows.count + 1) / 1000)
            )
        }
        cards.forEach(context.insert)
        let before = folder.cards ?? []
        // Attached in one go: setting each card's folder updates the inverse array once per card,
        // which took 5 s instead of 0.5 s for 5,000 cards.
        folder.cards = before + cards
        do {
            try context.saveOrRollback()
        } catch {
            // A rollback drops the cards from the store but not from the folder's array.
            folder.cards = before
            throw error
        }
    }
}
