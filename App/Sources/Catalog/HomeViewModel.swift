import Observation

/// Home: the root folders' actions and creating a root folder.
@MainActor
@Observable
final class HomeViewModel {
    var isCreatingFolder = false
    let rowActions: FolderRowActionsModel
    private let service: any CatalogServicing

    init(service: any CatalogServicing) {
        self.service = service
        rowActions = FolderRowActionsModel(service: service)
    }

    func newRootFolderModel() -> NewRootFolderViewModel {
        NewRootFolderViewModel(service: service)
    }

    func folderModel(for folder: Folder) -> FolderViewModel {
        FolderViewModel(folder: folder, service: service)
    }
}
