import Mockable

/// Folder tree changes; `CatalogService` saves them with SwiftData. View models depend on this.
@Mockable
@MainActor
protocol CatalogServicing {
    @discardableResult
    func createRootFolder(name: String, learningLanguage: String, backLanguage: String) throws -> Folder
    @discardableResult
    func createSubfolder(name: String, in parent: Folder) throws -> Folder
    func rename(_ folder: Folder, to name: String) throws
    func moveCheck(_ folder: Folder, to destination: Folder?) -> MoveCheck
    func move(_ folder: Folder, to destination: Folder?) throws
    func delete(_ folder: Folder) throws
}
