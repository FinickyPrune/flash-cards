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
    var saveError: String?
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

    /// Swipe to delete in the folder list; no confirmation there (`card-editor.md`).
    func deleteCard(_ card: Card) {
        do {
            try dependencies.cardService.delete(card)
        } catch {
            saveError = error.localizedDescription
        }
    }

    func newSubfolderModel() -> FolderNameViewModel {
        FolderNameViewModel(mode: .newSubfolder(in: folder), service: dependencies.catalogService)
    }
}
