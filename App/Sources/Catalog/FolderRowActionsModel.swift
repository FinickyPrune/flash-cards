import Observation

/// Rename, move and delete for the folder rows of one list (home or a folder screen).
@MainActor
@Observable
final class FolderRowActionsModel {
    var renaming: Folder?
    var moving: Folder?
    var deleting: Folder?
    var saveError: String?
    private let service: any CatalogServicing

    init(service: any CatalogServicing) {
        self.service = service
    }

    func renameModel(for folder: Folder) -> FolderNameViewModel {
        FolderNameViewModel(mode: .rename(folder), service: service)
    }

    func moveModel(for folder: Folder) -> MoveFolderViewModel {
        MoveFolderViewModel(folder: folder, service: service)
    }

    /// Deletes the folder awaiting confirmation. Clears it first so the dialog never reads a deleted model.
    func confirmDelete() {
        guard let folder = deleting else { return }
        deleting = nil
        do {
            try service.delete(folder)
        } catch {
            saveError = error.localizedDescription
        }
    }
}
