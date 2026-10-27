import Observation

/// Play, rename, move and delete for the folder rows of one list (home or a folder screen).
@MainActor
@Observable
final class FolderRowActionsModel {
    var renaming: Folder?
    var moving: Folder?
    var deleting: Folder?
    var saveError: String?
    /// The open review; built and started once when Play is tapped.
    var review: ReviewViewModel?
    private let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    /// Starts the session before presenting, so the cover never slides up empty.
    func play(_ folder: Folder) {
        let model = ReviewViewModel(folder: folder, service: dependencies.review)
        model.start()
        review = model
    }

    func renameModel(for folder: Folder) -> FolderNameViewModel {
        FolderNameViewModel(mode: .rename(folder), service: dependencies.catalog)
    }

    func moveModel(for folder: Folder) -> MoveFolderViewModel {
        MoveFolderViewModel(folder: folder, service: dependencies.catalog)
    }

    /// Deletes `folder` after the user confirmed. Clears `deleting` first so the dialog never reads
    /// a deleted model.
    func confirmDelete(_ folder: Folder) {
        deleting = nil
        do {
            try dependencies.catalog.delete(folder)
        } catch {
            saveError = error.localizedDescription
        }
    }
}
