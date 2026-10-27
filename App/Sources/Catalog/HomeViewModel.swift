import Observation

/// Home: the root folders' actions and creating a root folder.
@MainActor
@Observable
final class HomeViewModel {
    var isCreatingFolder = false
    let rowActions: FolderRowActionsModel
    private let service: any CatalogServicing
    private let cardService: any CardServicing
    private let reviewService: any ReviewServicing

    init(service: any CatalogServicing, cardService: any CardServicing, reviewService: any ReviewServicing) {
        self.service = service
        self.cardService = cardService
        self.reviewService = reviewService
        rowActions = FolderRowActionsModel(service: service, reviewService: reviewService)
    }

    func newRootFolderModel() -> NewRootFolderViewModel {
        NewRootFolderViewModel(service: service)
    }

    /// Every pushed folder screen, at any depth: Home owns the navigation stack.
    func folderModel(for folder: Folder) -> FolderViewModel {
        FolderViewModel(folder: folder, service: service, cardService: cardService, reviewService: reviewService)
    }
}
