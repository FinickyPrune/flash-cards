import Observation

/// One folder screen: its subfolders' actions, creating a subfolder, and its cards.
@MainActor
@Observable
final class FolderViewModel {
    let folder: Folder
    var isCreatingSubfolder = false
    var isCreatingCard = false
    var editingCard: Card?
    var saveError: String?
    let rowActions: FolderRowActionsModel
    private let service: any CatalogServicing
    private let cardService: any CardServicing

    init(folder: Folder, service: any CatalogServicing, cardService: any CardServicing) {
        self.folder = folder
        self.service = service
        self.cardService = cardService
        rowActions = FolderRowActionsModel(service: service)
    }

    func newCardModel() -> CardEditorViewModel {
        CardEditorViewModel(adding: folder, service: cardService)
    }

    func editModel(for card: Card) -> CardEditorViewModel {
        CardEditorViewModel(editing: card, fallbackFolder: folder, service: cardService)
    }

    /// Swipe to delete in the folder list; no confirmation there (`card-editor.md`).
    func deleteCard(_ card: Card) {
        do {
            try cardService.delete(card)
        } catch {
            saveError = error.localizedDescription
        }
    }

    func newSubfolderModel() -> FolderNameViewModel {
        FolderNameViewModel(mode: .newSubfolder(in: folder), service: service)
    }
}
