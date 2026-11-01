import Mockable

/// Folder tree changes; `CatalogService` saves them with SwiftData. View models depend on this.
@Mockable
@MainActor
protocol CatalogServicing {
    @discardableResult
    func createRootFolder(
        name: String,
        learningLanguage: String,
        backLanguage: String,
        palette: FolderPalette
    ) throws -> Folder
    /// What a new root folder starts with, given the root folders that exist.
    func paletteForNewRoot() -> FolderPalette
    @discardableResult
    func createSubfolder(name: String, in parent: Folder) throws -> Folder
    func rename(_ folder: Folder, to name: String) throws
    /// `nil` makes the folder follow its parent.
    func setPalette(_ palette: FolderPalette?, of folder: Folder) throws
    func moveCheck(_ folder: Folder, to destination: Folder?) -> MoveCheck
    func move(_ folder: Folder, to destination: Folder?) throws
    func delete(_ folder: Folder) throws
}
