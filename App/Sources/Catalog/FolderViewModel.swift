import Observation

/// One folder screen: its subfolders' actions, creating a subfolder, and its cards.
@MainActor
@Observable
final class FolderViewModel {
    let folder: Folder
    var isCreatingSubfolder = false
    /// The open card editor; built once when it opens, so it never re-reads a card it deleted.
    var editor: CardEditorViewModel?
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

    func addCard() {
        editor = CardEditorViewModel(adding: folder, service: cardService)
    }

    func edit(_ card: Card) {
        editor = CardEditorViewModel(editing: card, fallbackFolder: folder, service: cardService)
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
