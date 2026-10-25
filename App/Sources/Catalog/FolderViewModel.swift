import Observation

/// One folder screen: its subfolders' actions and creating a subfolder.
@MainActor
@Observable
final class FolderViewModel {
    let folder: Folder
    var isCreatingSubfolder = false
    let rowActions: FolderRowActionsModel
    private let service: any CatalogServicing

    init(folder: Folder, service: any CatalogServicing) {
        self.folder = folder
        self.service = service
        rowActions = FolderRowActionsModel(service: service)
    }

    func newSubfolderModel() -> FolderNameViewModel {
        FolderNameViewModel(mode: .newSubfolder(in: folder), service: service)
    }
}
