import FlashCore
import Foundation
import Mockable

/// CSV import (`csv.md` → Import); `CSVImportService` reads files and saves cards with SwiftData.
@Mockable
@MainActor
protocol CSVImportServicing {
    /// Throws `CSVImportError`.
    func readDocument(at url: URL) async throws -> CSVDocument
    /// Front keys of every card in `folder`'s root folder, for the duplicate count.
    func existingFrontKeys(in folder: Folder) -> Set<String>
    /// Creates one card per row in `folder`, in file order, in one save.
    func importRows(_ rows: [CSVRow], into folder: Folder) throws
}
