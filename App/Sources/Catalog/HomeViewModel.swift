import Observation

/// Home: the root folders' actions and creating a root folder.
@MainActor
@Observable
final class HomeViewModel {
    var isCreatingFolder = false
    let rowActions: FolderRowActionsModel
    private let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        rowActions = FolderRowActionsModel(dependencies: dependencies)
    }

    func newRootFolderModel() -> NewRootFolderViewModel {
        NewRootFolderViewModel(service: dependencies.catalogService)
    }

    /// Every pushed folder screen, at any depth: Home owns the navigation stack.
    func folderModel(for folder: Folder) -> FolderViewModel {
        FolderViewModel(folder: folder, dependencies: dependencies)
    }
}
