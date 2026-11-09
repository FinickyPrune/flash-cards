import FlashCore
import Foundation
import SwiftData

/// Imported cards are new, with back source custom and no screenshot; the root folder's last back
/// source stays as it was. A failed save rolls the context back, so no card is half imported.
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

    /// Creation times a millisecond apart follow the file's order, so its last row is the newest.
    func importRows(_ rows: [CSVRow], into folder: Folder) throws {
        let start = Date.now
        for (index, row) in rows.enumerated() {
            context.insert(Card(
                front: row.front,
                back: row.back,
                backSource: BackSource.custom.rawValue,
                folder: folder,
                context: row.context,
                createdAt: start.addingTimeInterval(Double(index) / 1000)
            ))
        }
        try context.saveOrRollback()
    }
}
