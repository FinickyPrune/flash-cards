import Observation

/// Play, rename, move and delete for the folder rows of one list (home or a folder screen).
@MainActor
@Observable
final class FolderRowActionsModel {
    var renaming: Folder?
    var moving: Folder?
    var deleting: Folder?
    var saveError: String?
    /// The open review; built once when Play is tapped.
    var review: ReviewViewModel?
    private let service: any CatalogServicing
    private let reviewService: any ReviewServicing

    init(service: any CatalogServicing, reviewService: any ReviewServicing) {
        self.service = service
        self.reviewService = reviewService
    }

    func play(_ folder: Folder) {
        review = ReviewViewModel(folder: folder, service: reviewService)
    }

    func renameModel(for folder: Folder) -> FolderNameViewModel {
        FolderNameViewModel(mode: .rename(folder), service: service)
    }

    func moveModel(for folder: Folder) -> MoveFolderViewModel {
        MoveFolderViewModel(folder: folder, service: service)
    }

    /// Deletes `folder` after the user confirmed. Clears `deleting` first so the dialog never reads
    /// a deleted model.
    func confirmDelete(_ folder: Folder) {
        deleting = nil
        do {
            try service.delete(folder)
        } catch {
            saveError = error.localizedDescription
        }
    }
}
