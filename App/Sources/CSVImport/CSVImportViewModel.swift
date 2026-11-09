import FlashCore
import Foundation
import Observation

/// The import preview (`csv.md` → Import): reads the file, counts what an import would create
/// in the chosen folder, and imports it. Counts follow the header toggle and the folder.
@MainActor
@Observable
final class CSVImportViewModel: Identifiable {
    enum Phase: Equatable {
        case loading
        case failed(String)
        case ready
        /// Saved; the sheet is closing and Import must not run again.
        case imported
    }

    private(set) var phase = Phase.loading
    var folder: Folder {
        didSet { recount() }
    }

    var firstRowIsHeader = false {
        didSet { recount() }
    }

    var skipsDuplicates = true {
        didSet { rowsToImport = plan.rows(skippingDuplicates: skipsDuplicates) }
    }

    var saveError: String?
    private(set) var plan = CSVImportPlan(rows: [], existingKeys: [])
    private(set) var rowsToImport: [CSVRow] = []
    /// Rows left out for an empty front or back.
    private(set) var skippedCount = 0
    private var document: CSVDocument?
    /// The front keys of the last root folder counted against; a header toggle doesn't refetch them.
    private var existingKeys: (root: Folder, keys: Set<String>)?
    /// Nil when the file importer failed.
    private let url: URL?
    private let service: any CSVImportServicing

    init(url: URL?, folder: Folder, service: any CSVImportServicing) {
        self.url = url
        self.folder = folder
        self.service = service
    }

    var canImport: Bool {
        phase == .ready && !rowsToImport.isEmpty
    }

    /// Runs once; the sheet's `.task` may start it again when the sheet reappears.
    func load() async {
        guard phase == .loading, document == nil else {
            return
        }
        do {
            guard let url else {
                throw CSVImportError.unreadable
            }
            let document = try await service.readDocument(at: url)
            let firstRowIsHeader = document.firstRowLooksLikeHeader
            guard !document.rows(firstRowIsHeader: firstRowIsHeader).rows.isEmpty else {
                throw CSVImportError.noCards
            }
            self.document = document
            // `didSet` recounts even when the value doesn't change.
            self.firstRowIsHeader = firstRowIsHeader
            phase = .ready
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }

    /// Returns whether the sheet should close.
    func importCards() -> Bool {
        guard canImport else {
            return false
        }
        do {
            try service.importRows(rowsToImport, into: folder)
            phase = .imported
            return true
        } catch {
            saveError = error.localizedDescription
            return false
        }
    }

    private func recount() {
        guard let document else {
            return
        }
        let result = document.rows(firstRowIsHeader: firstRowIsHeader)
        skippedCount = result.skippedCount
        plan = CSVImportPlan(rows: result.rows, existingKeys: keys(for: folder))
        rowsToImport = plan.rows(skippingDuplicates: skipsDuplicates)
    }

    private func keys(for folder: Folder) -> Set<String> {
        if let existingKeys, existingKeys.root === folder.root {
            return existingKeys.keys
        }
        let keys = service.existingFrontKeys(in: folder)
        existingKeys = (folder.root, keys)
        return keys
    }
}
