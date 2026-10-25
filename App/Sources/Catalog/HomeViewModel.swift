import Observation

/// Home: the root folders' actions and creating a root folder.
@MainActor
@Observable
final class HomeViewModel {
    var isCreatingFolder = false
    let rowActions: FolderRowActionsModel
    private let service: any CatalogServicing
    private let cardService: any CardServicing

    init(service: any CatalogServicing, cardService: any CardServicing) {
        self.service = service
        self.cardService = cardService
        rowActions = FolderRowActionsModel(service: service)
    }

    func newRootFolderModel() -> NewRootFolderViewModel {
        NewRootFolderViewModel(service: service)
    }

    /// Every pushed folder screen, at any depth: Home owns the navigation stack.
    func folderModel(for folder: Folder) -> FolderViewModel {
        FolderViewModel(folder: folder, service: service, cardService: cardService)
    }
}
