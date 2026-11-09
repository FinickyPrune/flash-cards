import Foundation
import Observation

/// One folder screen: its subfolders' actions (Play of the folder itself goes through them too),
/// creating a subfolder, and its cards.
@MainActor
@Observable
final class FolderViewModel {
    let folder: Folder
    var isCreatingSubfolder = false
    /// The open card editor; built once when it opens, so it never re-reads a card it deleted.
    var editor: CardEditorViewModel?
    var isPickingCSVFile = false
    /// The open CSV import preview.
    var csvImport: CSVImportViewModel?
    var saveError: String?
    /// The folder itself, while its delete from the More menu waits for confirmation.
    var deleting: Folder?
    /// Set once the folder is deleted; the screen stops reading it and leaves.
    private(set) var isDeleted = false
    let rowActions: FolderRowActionsModel
    private let dependencies: AppDependencies

    init(folder: Folder, dependencies: AppDependencies) {
        self.folder = folder
        self.dependencies = dependencies
        rowActions = FolderRowActionsModel(dependencies: dependencies)
    }

    func addCard() {
        editor = CardEditorViewModel(adding: folder, service: dependencies.cardService)
    }

    func edit(_ card: Card) {
        editor = CardEditorViewModel(editing: card, fallbackFolder: folder, service: dependencies.cardService)
    }

    /// Import CSV on the More menu: the file importer, or the UI tests' file.
    func startCSVImport() {
        if let file = LaunchOptions.csvFile {
            importCSV(from: file)
        } else {
            isPickingCSVFile = true
        }
    }

    /// `url` is nil when the file importer failed.
    func importCSV(from url: URL?) {
        csvImport = CSVImportViewModel(url: url, folder: folder, dependencies: dependencies)
    }

    /// Swipe to delete in the folder list; no confirmation there (`card-editor.md`).
    func deleteCard(_ card: Card) {
        do {
            try dependencies.cardService.delete(card)
        } catch {
            saveError = error.localizedDescription
        }
    }

    /// Deletes the folder after the user confirmed; returns whether the screen should leave. Marks
    /// it deleted first so the screen never reads a deleted model.
    func confirmDelete() -> Bool {
        deleting = nil
        isDeleted = true
        do {
            try dependencies.catalogService.delete(folder)
            return true
        } catch {
            isDeleted = false
            saveError = error.localizedDescription
            return false
        }
    }

    func subfolderModel(for subfolder: Folder) -> FolderViewModel {
        FolderViewModel(folder: subfolder, dependencies: dependencies)
    }

    func newSubfolderModel() -> FolderNameViewModel {
        FolderNameViewModel(mode: .newSubfolder(in: folder), service: dependencies.catalogService)
    }
}
