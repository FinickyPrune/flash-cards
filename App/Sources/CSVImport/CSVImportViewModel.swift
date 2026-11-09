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
    }

    private(set) var phase = Phase.loading
    var folder: Folder {
        didSet { recount() }
    }

    var firstRowIsHeader = false {
        didSet { recount() }
    }

    var skipsDuplicates = true
    var saveError: String?
    private(set) var plan = CSVImportPlan(rows: [], existingKeys: [])
    /// Rows left out for an empty front or back.
    private(set) var skippedCount = 0
    private var document: CSVDocument?
    private let url: URL
    private let service: any CSVImportServicing

    init(url: URL, folder: Folder, service: any CSVImportServicing) {
        self.url = url
        self.folder = folder
        self.service = service
    }

    var rowsToImport: [CSVRow] {
        plan.rows(skippingDuplicates: skipsDuplicates)
    }

    var canImport: Bool {
        phase == .ready && !rowsToImport.isEmpty
    }

    func load() async {
        do {
            let document = try await service.readDocument(at: url)
            // Even the first row counted as a card leaves none: nothing to preview.
            guard !document.rows(firstRowIsHeader: false).rows.isEmpty else {
                throw CSVImportError.noCards
            }
            firstRowIsHeader = document.firstRowLooksLikeHeader
            self.document = document
            recount()
            phase = .ready
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }

    /// Returns whether the sheet should close.
    func importCards() -> Bool {
        do {
            try service.importRows(rowsToImport, into: folder)
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
        plan = CSVImportPlan(rows: result.rows, existingKeys: service.existingFrontKeys(in: folder))
    }
}
