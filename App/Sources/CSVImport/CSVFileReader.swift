import FlashCore
import Foundation

/// Reads and parses a CSV file off the main actor (`swift-conventions` → heavy work).
actor CSVFileReader {
    /// `url` may come from the file importer, outside the sandbox.
    func document(at url: URL) throws(CSVImportError) -> CSVDocument {
        let isScoped = url.startAccessingSecurityScopedResource()
        defer {
            if isScoped {
                url.stopAccessingSecurityScopedResource()
            }
        }
        guard let data = try? Data(contentsOf: url) else {
            throw .unreadable
        }
        do {
            return try CSVDocument(data: data)
        } catch {
            throw .notUTF8
        }
    }
}
