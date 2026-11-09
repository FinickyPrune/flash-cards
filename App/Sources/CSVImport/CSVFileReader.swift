import FlashCore
import Foundation

/// Reads and parses a CSV file off the main actor (`swift-conventions` → heavy work).
actor CSVFileReader {
    /// Over this, the file isn't read: parsing holds several copies of it in memory.
    static let maxBytes = 10_000_000

    /// `url` may come from the file importer: outside the sandbox, or in iCloud Drive and not
    /// downloaded yet, which a coordinated read fetches first.
    func document(at url: URL) throws(CSVImportError) -> CSVDocument {
        let isScoped = url.startAccessingSecurityScopedResource()
        defer {
            if isScoped {
                url.stopAccessingSecurityScopedResource()
            }
        }
        var result = Result<Data, CSVImportError>.failure(.unreadable)
        var coordinationError: NSError?
        NSFileCoordinator().coordinate(readingItemAt: url, options: .withoutChanges, error: &coordinationError) { url in
            if let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize, size > Self.maxBytes {
                result = .failure(.tooLarge)
            } else if let data = try? Data(contentsOf: url) {
                result = .success(data)
            }
        }
        let data = try result.get()
        do {
            return try CSVDocument(data: data)
        } catch {
            throw .notUTF8
        }
    }
}
